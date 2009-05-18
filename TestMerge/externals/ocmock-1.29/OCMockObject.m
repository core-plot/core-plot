//---------------------------------------------------------------------------------------
//  $Id: OCMockObject.m 21 2008-01-24 18:59:39Z erik $
//  Copyright (c) 2004-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMockObject.h>
#import "OCClassMockObject.h"
#import "OCProtocolMockObject.h"
#import <OCMock/OCMockRecorder.h>
#import "NSInvocation+OCMAdditions.h"

@interface OCMockObject(Private)
+ (id)_makeNice:(OCMockObject *)mock;
- (NSString *)_recorderDescriptions:(BOOL)onlyExpectations;
@end

@implementation OCMockObject

//---------------------------------------------------------------------------------------
//  factory methods
//---------------------------------------------------------------------------------------

+ (id)mockForClass:(Class)aClass
{
	return [[[OCClassMockObject alloc] initWithClass:aClass] autorelease];
}


+ (id)mockForProtocol:(Protocol *)aProtocol
{
	return [[[OCProtocolMockObject alloc] initWithProtocol:aProtocol] autorelease];
}


+ (id)niceMockForClass:(Class)aClass
{
	return [self _makeNice:[self mockForClass:aClass]];
}

+ (id)niceMockForProtocol:(Protocol *)aProtocol
{
	return [self _makeNice:[self mockForProtocol:aProtocol]];
}


+ (id)_makeNice:(OCMockObject *)mock
{
	mock->isNice = YES;
	return mock;
}


//---------------------------------------------------------------------------------------
//  init and dealloc
//---------------------------------------------------------------------------------------

- (id)init
{
	recorders = [[NSMutableArray alloc] init];
	expectations = [[NSMutableSet alloc] init];
	exceptions = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc
{
	[recorders release];
	[expectations release];
	[exceptions release];
	[super dealloc];
}

//---------------------------------------------------------------------------------------
// description override
//---------------------------------------------------------------------------------------

- (NSString *)description
{
	return @"OCMockObject";
}


//---------------------------------------------------------------------------------------
//  public api
//---------------------------------------------------------------------------------------

- (id)stub
{
	OCMockRecorder *recorder = [[[OCMockRecorder alloc] initWithSignatureResolver:self] autorelease];
	[recorders addObject:recorder];
	return recorder;
}


- (id)expect
{
	OCMockRecorder *recorder = [self stub];
	[expectations addObject:recorder];
	return recorder;
}


- (void)verify
{
	if([expectations count] == 1)
	{
		[NSException raise:NSInternalInconsistencyException format:@"%@: expected method was not invoked: %@", 
			[self description], [[expectations anyObject] description]];
	}
	if([expectations count] > 0)
	{
		[NSException raise:NSInternalInconsistencyException format:@"%@ : %d expected methods were not invoked: %@", 
			[self description], [expectations count], [self _recorderDescriptions:YES]];
	}
	if([exceptions count] > 0)
	{
		[[exceptions objectAtIndex:0] raise];
	}
}


//---------------------------------------------------------------------------------------
//  proxy api
//---------------------------------------------------------------------------------------

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	OCMockRecorder *recorder = nil;
	int			   i;

	for(i = 0; i < [recorders count]; i++)
	{
		recorder = [recorders objectAtIndex:i];
		if([recorder matchesInvocation:anInvocation])
			break;
	}
	
	if(i < [recorders count]) 
	{
		if ([expectations containsObject:recorder])
		{
			[expectations removeObject:recorder];
			[recorders removeObjectAtIndex:i];
		}
		[recorder setUpReturnValue:anInvocation];
	}
	else if(isNice == NO)
	{
		NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:
			[NSString stringWithFormat:@"%@: unexpected method invoked: %@ %@",  [self description], 
			[anInvocation invocationDescription], [self _recorderDescriptions:NO]] userInfo:nil];
		[exceptions addObject:exception];
		[exception raise];
	}
	
}


//---------------------------------------------------------------------------------------
//  descriptions
//---------------------------------------------------------------------------------------

- (NSString *)_recorderDescriptions:(BOOL)onlyExpectations
{
	NSMutableString *outputString = [NSMutableString string];
	
	OCMockRecorder *currentObject;
	NSEnumerator *recorderEnumerator = [recorders objectEnumerator];
	while((currentObject = [recorderEnumerator nextObject]) != nil)
	{
		NSString *prefix;
		
		if(onlyExpectations)
		{
			if(![expectations containsObject:currentObject])
				continue;
			prefix = @" ";
		}
		else
		{
			if ([expectations containsObject:currentObject])
				prefix = @"expected: ";
			else
				prefix = @"stubbed: ";
		}
		[outputString appendFormat:@"\n\t%@\t%@", prefix, [currentObject description]];
	}
	
	return outputString;
}


@end
