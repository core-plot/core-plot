//
//  KTSplitView.h
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTView.h"


@class KTSplitView;

@protocol KTSplitView
- (void)layoutViews;
- (void)resetResizeInformation;
@end

@protocol KTSplitViewDelegate <NSObject>
@optional
- (void)splitViewDivderAnimationDidEnd:(KTSplitView*)theSplitView;
- (void)dividerPositionDidChangeForSplitView:(KTSplitView*)theSplitView;
@end
//animationDidEndForSplitView
typedef enum
{
	KTSplitViewResizeBehavior_MaintainProportions = 0,
	KTSplitViewResizeBehavior_MaintainFirstViewSize,
	KTSplitViewResizeBehavior_MaintainSecondViewSize,
	
}KTSplitViewResizeBehavior;

typedef enum
{	
	KTSplitViewDividerOrientation_NoSet = 0,
	KTSplitViewDividerOrientation_Horizontal,
	KTSplitViewDividerOrientation_Vertical
	
}KTSplitViewDividerOrientation;

typedef enum
{
	KTSplitViewFocusedViewFlag_FirstView = 0,
	KTSplitViewFocusedViewFlag_SecondView
	
}KTSplitViewFocusedViewFlag;

@class KTSplitViewDivider;

@interface KTSplitView : KTView <KTSplitView>
{
	@private
	id<KTSplitViewDelegate>				wDelegate;
	
	KTSplitViewDivider *				mDivider;
	KTView *							mFirstView;
	KTView *							mSecondView;
	
	KTSplitViewDividerOrientation		mDividerOrientation;
	KTSplitViewResizeBehavior			mResizeBehavior;
	BOOL								mAdjustable;
	BOOL								mUserInteractionEnabled;
	
	KTSplitViewFocusedViewFlag			mPositionRelativeToViewFlag;
	BOOL								mCanSetDividerPosition;
	CGFloat								mDividerPositionToSet;
	BOOL								mResetResizeInformation;
	CGFloat								mResizeInformation;
	NSRect								mCachedFrame;
	NSViewAnimation *					mAnimator;
}

@property (nonatomic, readwrite, assign) IBOutlet id <KTSplitViewDelegate> delegate;
@property (nonatomic, readwrite, assign) KTSplitViewDividerOrientation dividerOrientation;
@property (nonatomic, readwrite, assign) KTSplitViewResizeBehavior resizeBehavior;
@property (nonatomic, readwrite, assign) BOOL userInteractionEnabled;
@property (nonatomic, readwrite, assign) CGFloat dividerThickness;

- (id)initWithFrame:(NSRect)theFrame dividerOrientation:(KTSplitViewDividerOrientation)theDividerOrientation;
- (void)setFirstView:(NSView<KTView>*)theView;
- (void)setSecondView:(NSView<KTView>*)theView;
- (void)setFirstView:(NSView<KTView>*)theFirstView secondView:(NSView<KTView>*)theSecondView;
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView;
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView animate:(BOOL)theBool animationDuration:(float)theTimeInSeconds;
- (CGFloat)dividerPositionRelativeToView:(KTSplitViewFocusedViewFlag)theFocusedViewFlag;
- (void)setDividerFillColor:(NSColor*)theColor;
- (void)setDividerBackgroundGradient:(NSGradient*)theGradient;
- (void)setDividerStrokeColor:(NSColor*)theColor;
- (void)setDividerFirstStrokeColor:(NSColor*)theFirstColor secondColor:(NSColor*)theSecondColor;
- (void)setDivider:(KTSplitViewDivider*)theDivider;

@end
