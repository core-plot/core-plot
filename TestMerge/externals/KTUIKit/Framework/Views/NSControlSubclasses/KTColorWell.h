//
//  KTColorWell.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewLayout.h"

extern NSString *const KTColorWellDidActivateNotification;

@class KTLayoutManager;

@interface KTColorWell : NSColorWell <KTViewLayout>
{
	KTLayoutManager *		mLayoutManager;
}

@end
