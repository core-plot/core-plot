//---------------------------------------------------------------------------------------
//  $Id: OCMReturnValueProvider.m 52 2009-08-14 07:21:10Z erik $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "NSMethodSignature+OCMAdditions.h"
#import "OCMReturnValueProvider.h"


@implementation OCMReturnValueProvider

- (id)initWithValue:(id)aValue
{
	[super init];
	returnValue = [aValue retain];
	return self;
}

- (void)dealloc
{
	[returnValue release];
	[super dealloc];
}

- (void)handleInvocation:(NSInvocation *)anInvocation
{
	const char *returnType = [[anInvocation methodSignature] methodReturnTypeWithoutQualifiers];
	if(strcmp(returnType, @encode(id)) != 0)
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Expected invocation with object return type." userInfo:nil];
	[anInvocation setReturnValue:&returnValue];	
}

@end
