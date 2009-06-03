//
//  KTSplitViewDivider.m
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSplitViewDivider.h"
#import "KTSplitView.h"
#import <Quartz/Quartz.h>

@interface NSObject (KTSplitViewDividerSplitView)
- (void)dividerAnimationDidEnd;

@end

@interface KTSplitViewDivider (Private)
- (void)_resetTrackingArea;
@end

@implementation KTSplitViewDivider
@synthesize splitView = wSplitView;
@synthesize isInDrag = mIsInDrag;

//=========================================================== 
// - initWithSplitView
//===========================================================
- (id)initWithSplitView:(KTSplitView*)theSplitView
{
	if(self = [self initWithFrame:NSZeroRect])
	{
		wSplitView = theSplitView;
		[self _resetTrackingArea];
	}
	return self;
}


//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
	if(self = [super initWithFrame:theFrame])
	{
		[self _resetTrackingArea];
	}
	return self;
}

//=========================================================== 
// - initWithCoder
//===========================================================
- (id)initWithCoder:(NSCoder*)theCoder
{
	if(self = [super initWithCoder:theCoder])
	{
		[self _resetTrackingArea];
	}
	return self;
}

//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mTrackingArea release];
	[super dealloc];
}


//=========================================================== 
// - _resetTrackingArea
//===========================================================
- (void)_resetTrackingArea
{
	if(mTrackingArea)
	{
		[self removeTrackingArea:mTrackingArea];
		[mTrackingArea release];
	}
	NSRect	aTrackingRect = [self bounds];
	CGFloat	aPadding = 10;
	if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
		if(aTrackingRect.size.height < aPadding)
		{
			CGFloat aCenterY = NSMidY(aTrackingRect);
			aTrackingRect.size.height = aPadding;
			aTrackingRect.origin.y = aCenterY - aPadding*.5;
		}
	}
	else
	{
		if(aTrackingRect.size.width < aPadding)
		{
			CGFloat aCenterX = NSMidX(aTrackingRect);
			aTrackingRect.size.width = aPadding;
			aTrackingRect.origin.x = aCenterX - aPadding*.5;
		}
	}
	mTrackingArea = [[NSTrackingArea alloc] initWithRect:aTrackingRect
												 options:(NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside | NSTrackingEnabledDuringMouseDrag) 
												   owner:self userInfo:nil];
	[self addTrackingArea:mTrackingArea];	
}


//=========================================================== 
// - setFrame:time
//===========================================================
- (void)setFrame:(NSRect)theFrame
{	
//	//NSLog(@"%@ setFrame:", self);
//	if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Vertical)
//	{
//		// clip min & max positions
//		float aPositionToCheck = 0;//[self minPosition];
//		
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.x <= aPositionToCheck)
//		{
//			theFrame.origin.x = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeRightCursor] set];
//		}
//		
//		aPositionToCheck = 0;//[self maxPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.x >= aPositionToCheck)
//		{
//			theFrame.origin.x = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeLeftCursor] set];
//		}
//	}
//	else if([[self splitView] dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
//	{
//		float aPositionToCheck = 0;//[self minPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.y < aPositionToCheck)
//		{
//			theFrame.origin.y = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeUpCursor] set];
//		}	
//		
//		aPositionToCheck = 0;//[self maxPosition];
//		if(		aPositionToCheck > 0
//			&&	theFrame.origin.y >= aPositionToCheck)
//		{
//			theFrame.origin.y = aPositionToCheck;
//			if(mIsInDrag == YES)
//				[[NSCursor resizeDownCursor] set];
//		}
//	}

	[super setFrame:theFrame];
	[[self splitView] resetResizeInformation];
	[[self splitView] layoutViews];
}

//=========================================================== 
// - hitTest
//===========================================================
- (NSView*)hitTest:(NSPoint)thePoint
{
	if(NSPointInRect([self convertPoint:thePoint fromView:nil], [mTrackingArea rect]))
		return self;
	else
		return [super hitTest:thePoint];
}


//=========================================================== 
// - mouseDown
//===========================================================
- (void)mouseDown:(NSEvent*)theEvent
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
}


//=========================================================== 
// - mouseDragged
//===========================================================
- (void)mouseDragged:(NSEvent*)theEvent
{
	if([[self splitView] userInteractionEnabled] == NO)
		return;
		
	NSPoint	aMousePoint = [[self splitView] convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect	aSplitViewBounds = [[self splitView] bounds];
	NSRect	aSplitViewFrame = [[self splitView] frame];
	NSRect	aDividerBounds = [self bounds];
	NSRect	aDividerFrame = [self frame];
	
	if([[self splitView] dividerOrientation]  == KTSplitViewDividerOrientation_Horizontal)
	{
		float aPoint = floor(aMousePoint.y - aDividerBounds.size.height*.5);
		
		if(		aPoint >= aSplitViewBounds.origin.x 
			&&	aPoint <= aSplitViewFrame.size.height-aDividerBounds.size.height )
		{
//			[[NSCursor resizeUpDownCursor] set];
			NSRect aRect = aDividerFrame;
			[self setFrame:NSMakeRect(aRect.origin.x, aPoint,
									  aRect.size.width, aRect.size.height) ];
		}
	}
	else 
	{
		float aPoint = floor(aMousePoint.x-aDividerBounds.size.width*.5);
		if(aPoint >= aSplitViewBounds.origin.y && aPoint <= aSplitViewFrame.size.width-aDividerBounds.size.width)
		{
//			[[NSCursor resizeLeftRightCursor] set];
			NSRect aRect = aDividerFrame;
			[self setFrame:NSMakeRect(aPoint, aRect.origin.y,
									  aRect.size.width, aRect.size.height) ];
			
		}
	}
	mIsInDrag = YES;
}



//=========================================================== 
// - mouseUp
//===========================================================
- (void)mouseUp:(NSEvent*)theEvent
{
//	NSLog(@"%@ mouseUP", self);
	mIsInDrag = NO;
	[self _resetTrackingArea];
	[[self splitView] resetResizeInformation];
}


//=========================================================== 
// - mouseEntered
//===========================================================
- (void)mouseEntered:(NSEvent*)theEvent
{
//	if([[self splitView] dividerOrientation]  == KTSplitViewDividerOrientation_Horizontal)
//	{
//		[[NSCursor resizeUpDownCursor] set];
//	}
//	else
//	{
//		[[NSCursor resizeLeftRightCursor] set];
//	}
//	NSLog(@"%@ mouseEntered", self);
}


//=========================================================== 
// - mouseExited
//===========================================================
- (void)mouseExited:(NSEvent*)theEvent
{
//	NSLog(@"%@ mouseExited", self);
//	[[NSCursor arrowCursor] set];
}


//=========================================================== 
// - cursorUpdate
//===========================================================
- (void)cursorUpdate:(NSEvent *)theEvent
{
//	NSLog(@"%@ cursorUpdate", self);
}
@end
