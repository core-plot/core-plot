//---------------------------------------------------------------------------------------
//  $Id: OCMIndirectReturnValueProvider.m 54 2009-08-18 06:27:36Z erik $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "NSMethodSignature+OCMAdditions.h"
#import "OCMIndirectReturnValueProvider.h"


@implementation OCMIndirectReturnValueProvider

- (id)initWithProvider:(id)aProvider andSelector:(SEL)aSelector
{
	[super init];
	provider = [aProvider retain];
	selector = aSelector;
	return self;
}

- (void)dealloc
{
	[provider release];
	[super dealloc];
}

- (void)handleInvocation:(NSInvocation *)anInvocation
{
	[anInvocation setTarget:provider];
	[anInvocation setSelector:selector];
	[anInvocation invoke];
}

@end
