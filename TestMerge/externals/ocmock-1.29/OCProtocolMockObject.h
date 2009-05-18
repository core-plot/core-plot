//---------------------------------------------------------------------------------------
//  $Id: OCProtocolMockObject.h 21 2008-01-24 18:59:39Z erik $
//  Copyright (c) 2005-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMockObject.h>

@interface OCProtocolMockObject : OCMockObject 
{
	Protocol	*mockedProtocol;
}

- (id)initWithProtocol:(Protocol *)aProtocol;

@end

