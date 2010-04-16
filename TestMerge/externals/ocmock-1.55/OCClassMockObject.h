//---------------------------------------------------------------------------------------
//  $Id: OCClassMockObject.h 44 2009-05-08 23:20:16Z erik $
//  Copyright (c) 2005-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMockObject.h>

@interface OCClassMockObject : OCMockObject 
{
	Class	mockedClass;
}

- (id)initWithClass:(Class)aClass;

- (Class)mockedClass;

@end
