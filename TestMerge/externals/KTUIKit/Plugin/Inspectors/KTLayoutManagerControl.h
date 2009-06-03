//
//  KTLayoutManagerUI.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <KTUIKit/KTViewControl.h>
#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

typedef enum
{
	KTLayoutControlStrutState_Fixed = 0,
	KTLayoutControlStrutState_Flexible,
	KTLayoutControlStrutState_Mixed
	
}KTLayoutControlStrutState;

@protocol KTLayoutManagerControlDelegate
- (NSArray*)inspectedViews;	
@end

@interface KTLayoutManagerControl : KTView 
{
	IBInspector	*				wDelegate;
	BOOL						mIsEnabled;
	
	NSTextField *				wTopMarginTextField;
	NSTextField *				wRightMarginTextField;
	NSTextField *				wBottomMarginTextField;
	NSTextField *				wLeftMarginTextField;
	
	NSRect						mCenterRect;
	NSRect						mTopMarginRect;
	NSRect						mRightMarginRect;
	NSRect						mBottomMarginRect;
	NSRect						mLeftMarginRect;
	NSRect						mCenterHorizontalRect;
	NSRect						mCenterVerticalRect;
	
	NSNumber *					mMarginTop;
	NSNumber *					mMarginRight;
	NSNumber *					mMarginBottom;
	NSNumber *					mMarginLeft;
	
	KTLayoutControlStrutState	mTopStrutState;
	KTLayoutControlStrutState	mRightStrutState;
	KTLayoutControlStrutState	mBottomStrutState;
	KTLayoutControlStrutState	mLeftStrutState;
	KTLayoutControlStrutState	mHeightStrutState;
	KTLayoutControlStrutState	mWidthStrutState;
}

@property (nonatomic, readwrite,assign) IBInspector * delegate;
@property (nonatomic, readwrite,assign) BOOL isEnabled;
@property (nonatomic, readwrite, retain) NSNumber * marginTop;
@property (nonatomic, readwrite, retain) NSNumber * marginRight;
@property (nonatomic, readwrite, retain) NSNumber * marginBottom;
@property (nonatomic, readwrite, retain) NSNumber * marginLeft;
- (void)refresh;

@end
