//---------------------------------------------------------------------------------------
//  $Id: OCMockRecorder.m 29 2008-07-07 07:27:23Z erik $
//  Copyright (c) 2004-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <objc/runtime.h>
#import <OCMock/OCMockRecorder.h>
#import <OCMock/OCMConstraint.h>
#import "NSInvocation+OCMAdditions.h"

@interface NSObject(HCMatcherDummy)
- (BOOL) matches:(id)item;
@end


@implementation OCMockRecorder

//---------------------------------------------------------------------------------------
//  init and dealloc
//---------------------------------------------------------------------------------------

- (id)initWithSignatureResolver:(id)anObject
{
	signatureResolver = anObject;
	return self;
}


- (void)dealloc
{
	[recordedInvocation release];
	[returnValue release];
	[super dealloc];
}


//---------------------------------------------------------------------------------------
//  description
//---------------------------------------------------------------------------------------

- (NSString *)description
{
	return [recordedInvocation invocationDescription];
}


//---------------------------------------------------------------------------------------
//  recording
//---------------------------------------------------------------------------------------

- (id)andReturn:(id)anObject
{
	[returnValue autorelease];
	returnValue = [anObject retain];
	returnValueIsBoxed = NO;
	returnValueShouldBeThrown = NO;
	return self;
}

- (id)andReturnValue:(NSValue *)aValue
{
	[self andReturn:aValue];
	returnValueIsBoxed = YES;
	return self;
}

- (id)andThrow:(NSException *)anException
{
	[self andReturn:anException];
	returnValueShouldBeThrown = YES;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [signatureResolver methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if(recordedInvocation != nil)
		[NSException raise:NSInternalInconsistencyException format:@"Recorder received two methods to record."];
	[anInvocation setTarget:nil];
	[anInvocation retainArguments];
	recordedInvocation = [anInvocation retain];
}


//---------------------------------------------------------------------------------------
//  verification and return values
//---------------------------------------------------------------------------------------

- (id)_extractArgument: (NSInvocation*)anInvocation atIndex:(int)index
{
	const char* argType;
	
	argType = [[anInvocation methodSignature] getArgumentTypeAtIndex:index];
	if(strchr("rnNoORV", argType[0]) != NULL)
		argType += 1;
	
	if((strlen(argType) > 1) && (strchr("{^", argType[0]) == NULL))
		[NSException raise:NSInvalidArgumentException format:@"Cannot handle argument type '%s'.", argType];
			
	switch (argType[0]) 
	{
		case '#':
		case ':':
		case '@': 
		{
			id value;
			[anInvocation getArgument:&value atIndex:index];
			return value;
		}
		case 'i': 
		{
			int value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithInt:value];
		}	
		case 's':
		{
			short value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithShort:value];
		}	
		case 'l':
		{
			long value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithLong:value];
		}	
		case 'q':
		{
			long long value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithLongLong:value];
		}	
		case 'c':
		{
			char value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithChar:value];
		}	
		case 'C':
		{
			unsigned char value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithUnsignedChar:value];
		}	
		case 'I':
		{
			unsigned int value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithUnsignedInt:value];
		}	
		case 'S':
		{
			unsigned short value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithUnsignedShort:value];
		}	
		case 'L':
		{
			unsigned long value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithUnsignedLong:value];
		}	
		case 'Q':
		{
			unsigned long long value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithUnsignedLongLong:value];
		}	
		case 'f':
		{
			float value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithFloat:value];
		}	
		case 'd':
		{
			double value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithDouble:value];
		}	
		case 'B':
		{
			bool value;
			[anInvocation getArgument:&value atIndex:index];
			return [NSNumber numberWithBool:value];
		}
		case '^':
        {
            void *value = NULL;
            [anInvocation getArgument:&value atIndex:index];
            return [NSValue valueWithPointer:value];
        }
		case '{': // structure
		{
			unsigned maxSize = [[signatureResolver methodSignatureForSelector:[anInvocation selector]] frameLength];
			NSMutableData *argumentData = [[[NSMutableData alloc] initWithLength:maxSize] autorelease];
			[anInvocation getArgument:[argumentData mutableBytes] atIndex:index];
			return [NSValue valueWithBytes:[argumentData bytes] objCType:argType];
		}       
			
	}
	[NSException raise:NSInvalidArgumentException format:@"Argument type '%s' not supported", argType];
	return nil;
}


- (BOOL)matchesInvocation:(NSInvocation *)anInvocation
{
	id  recordedArg, passedArg;
	int i, n;
	
	if([anInvocation selector] != [recordedInvocation selector])
		return NO;
	
	n = [[recordedInvocation methodSignature] numberOfArguments];
	for(i = 2; i < n; i++)
	{
		recordedArg = [self _extractArgument:recordedInvocation atIndex:i];
		passedArg = [self _extractArgument:anInvocation atIndex:i];
		if([recordedArg isKindOfClass:[OCMConstraint class]])
		{	
			if([recordedArg evaluate:passedArg] == NO)
				return NO;
		}
		else if([recordedArg conformsToProtocol:objc_getProtocol("HCMatcher")])
		{
			if([recordedArg matches:passedArg] == NO)
				return NO;
		}
		else
		{
			if([recordedArg class] != [passedArg class])
				return NO;
			if(([recordedArg class] == [NSNumber class]) && 
				([(NSNumber*)recordedArg compare:(NSNumber*)passedArg] != NSOrderedSame))
				return NO;
			if(([recordedArg isEqual:passedArg] == NO) &&
				!((recordedArg == nil) && (passedArg == nil)))
				return NO;
		}
	}
	return YES;
}

- (void)setUpReturnValue:(NSInvocation *)anInvocation
{
	if(returnValueShouldBeThrown)
	{
		@throw returnValue;
	}
	else if(returnValueIsBoxed)
	{
		if(strcmp([[anInvocation methodSignature] methodReturnType], [(NSValue *)returnValue objCType]) != 0)
			[NSException raise:NSInvalidArgumentException format:@"Return value does not match method signature."];
		void *buffer = malloc([[anInvocation methodSignature] methodReturnLength]);
		[returnValue getValue:buffer];
		[anInvocation setReturnValue:buffer];
		free(buffer);
	}
	else
	{
		const char *returnType = [[anInvocation methodSignature] methodReturnType];
		const char *returnTypeWithoutQualifiers = returnType + (strlen(returnType) - 1);
		if(strcmp(returnTypeWithoutQualifiers, @encode(id)) == 0)
			[anInvocation setReturnValue:&returnValue];	
	}
}


//---------------------------------------------------------------------------------------
// House-keeping
//---------------------------------------------------------------------------------------

- (void)releaseInvocation
{
	[recordedInvocation release];
	recordedInvocation = nil;
}

@end
