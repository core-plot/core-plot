//
//  KTWebView.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "KTViewLayout.h"

@class KTLayoutManager;

@interface KTWebView : WebView <KTViewLayout>
{
	KTLayoutManager *		mLayoutManager;
}
@end
