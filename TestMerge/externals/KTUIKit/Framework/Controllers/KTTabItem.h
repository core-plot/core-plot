//
//  KTTabItem.h
//  KTUIKit
//
//  Created by Cathy on 18/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KTTabViewController;
@class KTViewController;

@interface KTTabItem : NSObject 
{
	NSString *				mLabel;
	id						mIdentifier;
	KTTabViewController *	wTabViewController;
	KTViewController *		wViewController;
}

- (id)initWithViewController:(KTViewController*)theViewController;

@property (nonatomic, readwrite, retain) NSString * label;
@property (nonatomic, readwrite, assign) id identifier;
@property (nonatomic, readwrite, assign) KTTabViewController * tabViewController;
@property (nonatomic, readwrite, assign) KTViewController * viewController;

@end
