//---------------------------------------------------------------------------------------
//  $Id: OCProtocolMockObject.m 22 2008-03-18 07:06:17Z erik $
//  Copyright (c) 2005-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <objc/runtime.h>
#import "NSMethodSignature+Private.h"
#import "OCProtocolMockObject.h"


@implementation OCProtocolMockObject

//---------------------------------------------------------------------------------------
//  init and dealloc
//---------------------------------------------------------------------------------------

- (id)initWithProtocol:(Protocol *)aProtocol
{
	[super init];
	mockedProtocol = aProtocol;
	return self;
}


//---------------------------------------------------------------------------------------
// description override
//---------------------------------------------------------------------------------------

- (NSString *)description
{
	return [NSString stringWithFormat:@"OCMockObject[%s]", [mockedProtocol name]];
}


//---------------------------------------------------------------------------------------
//  proxy api
//---------------------------------------------------------------------------------------

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	struct objc_method_description methodDescription = protocol_getMethodDescription(mockedProtocol, aSelector, YES, YES);
    if(methodDescription.name == NULL) 
	{
        methodDescription = protocol_getMethodDescription(mockedProtocol, aSelector, NO, YES);
    }
    if(methodDescription.name == NULL) 
	{
        return nil;
    }
	return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return protocol_conformsToProtocol(mockedProtocol, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)selector
{
    return ([self methodSignatureForSelector:selector] != nil);
}


@end
