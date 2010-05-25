//---------------------------------------------------------------------------------------
//  $Id: OCMIndirectReturnValueProvider.h 54 2009-08-18 06:27:36Z erik $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface OCMIndirectReturnValueProvider : NSObject 
{
	id	provider;
	SEL	selector;
}

- (id)initWithProvider:(id)aProvider andSelector:(SEL)aSelector;

@end
