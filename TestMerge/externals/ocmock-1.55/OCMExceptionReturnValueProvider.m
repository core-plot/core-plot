//---------------------------------------------------------------------------------------
//  $Id: OCMExceptionReturnValueProvider.m 50 2009-07-16 06:48:19Z erik $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMExceptionReturnValueProvider.h"


@implementation OCMExceptionReturnValueProvider

- (void)handleInvocation:(NSInvocation *)anInvocation
{
	@throw returnValue;
}

@end
