//
//  KTViewControl.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTView.h"

@interface KTViewControl : KTView 
{
	BOOL					mIsEnabled;
	
	@private
	NSObject *				wTarget;
	SEL						wAction;
}


@property (readwrite, assign) BOOL isEnabled;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;
- (void)performAction;

@end
