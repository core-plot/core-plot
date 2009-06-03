//
//  KTSplitView.m
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSplitView.h"
#import "KTSplitViewDivider.h"



@interface KTSplitView ()
@property (nonatomic, readwrite, retain) KTSplitViewDivider * divider;
@end

@interface KTSplitView (Private)
- (KTView*)firstView;
- (KTView*)secondView;
- (void)animateDividerToPosition:(float)thePosition time:(float)theTimeInSeconds;
@end

@implementation KTSplitView
//=========================================================== 
// - synths
//===========================================================
@synthesize delegate = wDelegate;
@synthesize dividerOrientation = mDividerOrientation;
@synthesize resizeBehavior = mResizeBehavior;
@synthesize userInteractionEnabled = mUserInteractionEnabled;
@synthesize divider = mDivider;


//=========================================================== 
// - initWithFrame:dividerOrientation
//===========================================================
- (id)initWithFrame:(NSRect)theFrame dividerOrientation:(KTSplitViewDividerOrientation)theDividerOrientation
{
	if(self = [self initWithFrame:theFrame])
	{
		[self setDividerOrientation:theDividerOrientation];
	}
	return self;
}


//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
//	NSLog(@"Split View initWithFrame:%@", NSStringFromRect(theFrame));
	if(self = [super initWithFrame:theFrame])
	{
		mFirstView = [[KTView alloc] initWithFrame:NSZeroRect];
		[self addSubview:mFirstView];
		mSecondView = [[KTView alloc] initWithFrame:NSZeroRect];
		[self addSubview:mSecondView];
		mDivider = [[KTSplitViewDivider alloc] initWithSplitView:self];
		[self addSubview:mDivider];
		
		//	This flag won't change until the first time the split view has a width/height.
		//	If the position is set before the flag changes, we'll cache the value and apply it later.
		mCanSetDividerPosition = NO; 
		[self setUserInteractionEnabled:YES];
	}
	return self;
}


//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{

	if (![super initWithCoder:theCoder])
		return nil;

	mCanSetDividerPosition = NO; 
	mFirstView = [[theCoder decodeObjectForKey:@"firstView"] retain];
	[mFirstView removeFromSuperview];
	mSecondView = [[theCoder decodeObjectForKey:@"secondView"] retain];
	[mSecondView removeFromSuperview];
	mDivider = [[theCoder decodeObjectForKey:@"divider"] retain];
	[mDivider setSplitView:self];
	[mDivider removeFromSuperview];
	
	[self addSubview:mFirstView];
	[self addSubview:mSecondView];
	[self addSubview:mDivider];
	[self setDividerOrientation:[[theCoder decodeObjectForKey:@"dividerOrienation"] intValue]];	
	[self setUserInteractionEnabled:[[theCoder decodeObjectForKey:@"userInteractionEnabled"] boolValue]];
	
			
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:mFirstView forKey:@"firstView"];
	[theCoder encodeObject:mSecondView forKey:@"secondView"];
	[theCoder encodeObject:mDivider forKey:@"divider"];
	[theCoder encodeObject:[NSNumber numberWithBool:[self userInteractionEnabled]] forKey:@"userInteractionEnabled"];
	[theCoder encodeObject:[NSNumber numberWithInt:[self dividerOrientation]] forKey:@"dividerOrientation"];
}



//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mFirstView release];
	[mSecondView release];
	[mDivider release];
	[mAnimator release];
	[super dealloc];
}




#pragma mark -
#pragma mark Resizing 
//=========================================================== 
// - setFrameSize
//===========================================================
- (void)setFrame:(NSRect)theFrame
{
	mCachedFrame = [self frame];
	[super setFrame:theFrame];
}

//=========================================================== 
// - setFrameSize
//===========================================================
- (void)setFrameSize:(NSSize)theSize
{
//	NSLog(@"%@ setFrame", self);
	// when the split view's frame is set, we need to 
	// check the desired resizing behavior to determine where to position the divider
	// after the frame is set, we'll refresh our layout so that all the views are sized/positioned correctly

	// Save old dimensions first
	NSRect anOldViewFrame = [self bounds];
	NSRect anOldDividerFrame = [[self divider] frame];
	
	// We need to have a width and height to do this
	if(		theSize.width <= 0
		||	theSize.height <= 0 
		||	anOldViewFrame.size.width <= 0
		||	anOldViewFrame.size.height <= 0)
	{
		[super setFrameSize:theSize];
		return;
	}
	
	// if we've been waiting to set the divider position, do it now
	if(	mCanSetDividerPosition == NO )
	{
		mCanSetDividerPosition = YES;
		[self setDividerPosition:mDividerPositionToSet relativeToView:mPositionRelativeToViewFlag];
		anOldDividerFrame = [[self divider] frame];
	}
	

	// Now check the resize behavior and the orientation of the divider to set the divider's position within our new frame
	switch([self resizeBehavior])
	{
		case KTSplitViewResizeBehavior_MaintainProportions:
		{
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				// if this is the first resize after the divider last moved, we need to cache the information
				// we need to calculate the position of the divider during a live resize
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = anOldDividerFrame.origin.y / anOldViewFrame.size.height;
					mResetResizeInformation = NO;
				}
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, theSize.height * mResizeInformation, theSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = anOldDividerFrame.origin.x / anOldViewFrame.size.width;
					mResetResizeInformation = NO;
				}
				[[self divider]  setFrame:NSMakeRect(theSize.width * mResizeInformation, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theSize.height)];
			}
		}
		break;
		
		
		case KTSplitViewResizeBehavior_MaintainFirstViewSize:
		{
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self firstView] frame].size.height;
					mResetResizeInformation = NO;
				}
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, theSize.height-mResizeInformation, theSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self firstView] frame].origin.x+[[self firstView]  frame].size.width;
					mResetResizeInformation = NO;
				}
				[[self divider] setFrame:NSMakeRect(mResizeInformation, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theSize.height)];
			}
		}		
		break;
		
		case KTSplitViewResizeBehavior_MaintainSecondViewSize:
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self secondView] frame].size.height;
					mResetResizeInformation = NO;
				}
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, mResizeInformation, theSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self secondView] frame].size.width;
					mResetResizeInformation = NO;
				}
				[[self divider] setFrame:NSMakeRect(theSize.width-mResizeInformation-anOldDividerFrame.size.width, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theSize.height)];
			}		
		
		break;
		
		default:
		break;
	}
	
	[super setFrameSize:theSize];	
}



//=========================================================== 
// - layoutViews
//===========================================================
- (void)layoutViews
{
	NSRect aSplitViewBounds = [self bounds];
	NSRect aDividerFrame = [[self divider] frame];
	NSRect aFirstViewFrame;
	NSRect aSecondViewFrame;
	if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
				
		aFirstViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									 aDividerFrame.origin.y + aDividerFrame.size.height,
									 aSplitViewBounds.size.width,
									 aSplitViewBounds.size.height - aDividerFrame.origin.y);
		
		
		aSecondViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									  aSplitViewBounds.origin.y,
									  aSplitViewBounds.size.width,
									  aDividerFrame.origin.y);
	
	}
	else
	{
		CGFloat aHeight = aSplitViewBounds.size.height;
		CGFloat aWidth = aDividerFrame.origin.x;

		
		aFirstViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									 aSplitViewBounds.origin.y,
									 aWidth,
									 aHeight);
										 
		aSecondViewFrame = NSMakeRect(aWidth+aDividerFrame.size.width,
									  aSplitViewBounds.origin.y,
									  aSplitViewBounds.size.width - NSMaxX(aDividerFrame),
									  aSplitViewBounds.size.height);
	}
	
	if(NSEqualRects(aFirstViewFrame, [[self firstView] frame]) == NO)
		[[self firstView] setFrame:aFirstViewFrame];
	if(NSEqualRects(aSecondViewFrame, [[self secondView] frame]) == NO)
		[[self secondView] setFrame:aSecondViewFrame];
}


//=========================================================== 
// - resetResizeInformation
//===========================================================
- (void)resetResizeInformation
{
	mResetResizeInformation = YES;
	mResizeInformation = 0;
}


#pragma mark -
#pragma mark Divider Position
/*
	The divider position must be set with a "focused view". 
	This allows users to specify a divider position relative to any side of the split view
	We'll take care of calculating what that position is really
*/

//=========================================================== 
// - setDividerPosition:relativeToView
//===========================================================
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView
{
	if(mCanSetDividerPosition == NO) // we can't set the divider's position until the split view has a width & height
	{
		// save the position and the relative view so that we can set it 
		// when we are certain that the split view has dimensions
		mDividerPositionToSet = thePosition;
		mPositionRelativeToViewFlag = theView;
	}	
	else // we have a width & height, so we are free to update the divider's position
	{
		NSRect aDividerFrame = [[self divider] frame];
		if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
		{
			if(theView == KTSplitViewFocusedViewFlag_FirstView)
					thePosition = [self bounds].size.height - thePosition;
			
			[[self divider] setFrame:NSMakeRect(aDividerFrame.origin.x, thePosition, aDividerFrame.size.width, aDividerFrame.size.height)];
		}
		else
		{
			if(theView == KTSplitViewFocusedViewFlag_SecondView)
					thePosition = [self bounds].size.width - thePosition;
			[[self divider] setFrame:NSMakeRect(thePosition, aDividerFrame.origin.y, aDividerFrame.size.width, aDividerFrame.size.height)];
		}
		
		[self resetResizeInformation];
	}
}


//=============================================================== 
// - setDividerPosition:relativeToView:animate:animationDuration
//===============================================================
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView animate:(BOOL)theBool animationDuration:(float)theTimeInSeconds;
{
	if(theBool == NO)
		[self setDividerPosition:thePosition relativeToView:theView];
	else
	{
		if(mCanSetDividerPosition == NO) // we can't set the divider's position until the split view has a width & height
		{
			// save the position and the relative view so that we can set it 
			// when we are certain that the split view has dimensions
			mDividerPositionToSet = thePosition;
			mPositionRelativeToViewFlag = theView;
			[self resetResizeInformation];
		}
		else // we have a width & height, so we are free to update the divider's position
		{	
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(theView == KTSplitViewFocusedViewFlag_FirstView)
					thePosition = [self bounds].size.height - thePosition;
					
				[self animateDividerToPosition:thePosition time:theTimeInSeconds];
			}
			else
			{
				if(theView == KTSplitViewFocusedViewFlag_SecondView)
					thePosition = [self bounds].size.width - thePosition;
				[self  animateDividerToPosition:thePosition time:theTimeInSeconds];
			}
		}
	}
}


//=============================================================== 
// - dividerPositionRelativeToView
//===============================================================
- (CGFloat)dividerPositionRelativeToView:(KTSplitViewFocusedViewFlag)theFocusedViewFlag
{
	float aDividerPosition = 0;
	
	if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
		if(theFocusedViewFlag == KTSplitViewFocusedViewFlag_FirstView)
			aDividerPosition = [self bounds].size.height - [[self divider]  frame].origin.y;
		else
			aDividerPosition = [[self divider] frame].origin.y;
	}
	else
	{
		if(theFocusedViewFlag == KTSplitViewFocusedViewFlag_FirstView)
			aDividerPosition = [[self divider]  frame].origin.x;
		else
			aDividerPosition = [self bounds].size.width - [[self divider]  frame].origin.x;
	}
	return aDividerPosition;	
}


//=========================================================== 
// - animateDividerToPosition:time
//===========================================================
- (void)animateDividerToPosition:(float)thePosition time:(float)theTimeInSeconds
{		
	if(mAnimator == nil)
	{
		CGPoint aPositionToSet = NSPointToCGPoint([mDivider frame].origin);
		if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			aPositionToSet.y = thePosition;
		else
			aPositionToSet.x = thePosition;
		NSRect aNewFrame = [mDivider frame];
		aNewFrame.origin = NSPointFromCGPoint(aPositionToSet);
											
		NSArray * anAnimationArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:mDivider, NSViewAnimationTargetKey,
																										 [NSValue valueWithRect:[mDivider frame]], NSViewAnimationStartFrameKey,
																										 [NSValue valueWithRect:aNewFrame], NSViewAnimationEndFrameKey, nil]];
		mAnimator = [[NSViewAnimation alloc] initWithViewAnimations:anAnimationArray];			
		[mAnimator setDelegate:self];																						
		[mAnimator setDuration: theTimeInSeconds];
		[mAnimator setAnimationCurve:NSAnimationEaseInOut];
		[mAnimator setAnimationBlockingMode: NSAnimationBlocking];
		[mAnimator startAnimation];
	}
}


//=========================================================== 
// - animationDidEnd
//===========================================================
- (void)animationDidEnd:(NSAnimation *)theAnimation
{
	if(theAnimation == mAnimator)
	{
		[mAnimator release];
		mAnimator = nil;	
		[self resetResizeInformation];	
		if([[self delegate] respondsToSelector:@selector(splitViewDivderAnimationDidEnd:)])
			[[self delegate] splitViewDivderAnimationDidEnd:self];
	}
}

//=========================================================== 
// - dividerAnimationDidEnd
//===========================================================
- (void)dividerAnimationDidEnd
{
	if([[self delegate] respondsToSelector:@selector(splitViewDivderAnimationDidEnd:)])
		[[self delegate] splitViewDivderAnimationDidEnd:self];
}



#pragma mark -
#pragma mark Building the SplitView

//=========================================================== 
// - setFirstView
//===========================================================
- (void)setFirstView:(NSView<KTView>*)theView
{
	[[self firstView] setSubviews:[NSArray array]];
	if(theView!=nil)
	[[self firstView] addSubview:theView];
	[self layoutViews];
}

//=========================================================== 
// - setSecondView
//===========================================================
- (void)setSecondView:(NSView<KTView>*)theView
{
	[[self secondView] setSubviews:[NSArray array]];
	if(theView!=nil)
		[[self secondView] addSubview:theView];	
	[self layoutViews];
}

//=========================================================== 
// - setFirstView:secondView:
//===========================================================
- (void)setFirstView:(NSView<KTView>*)theFirstView secondView:(NSView<KTView>*)theSecondView
{
	[self setFirstView:theFirstView];
	[self setSecondView:theSecondView];
	[self layoutViews];
}

//=========================================================== 
// - firstView
//===========================================================
- (KTView*)firstView
{
	return mFirstView;
}

//=========================================================== 
// - secondView
//===========================================================
- (KTView*)secondView
{
	return mSecondView;
}

//=========================================================== 
// - setDivider:
//===========================================================
- (void)setDivider:(KTSplitViewDivider*)theDivider
{
	if(theDivider != mDivider)
	{
		[theDivider retain];
		[mDivider removeFromSuperview];
		[mDivider release];
		mDivider = theDivider;
		[self addSubview:mDivider];
	}
}



#pragma mark -
#pragma mark Configuring the Divider
//=========================================================== 
// - setDividerOrientation
//===========================================================
- (void)setDividerOrientation:(KTSplitViewDividerOrientation)theOrientation
{
	CGFloat aCurrentDividerThickness = [self dividerThickness];
	mDividerOrientation = theOrientation;
	if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
	{
		NSRect aFrame = NSMakeRect(0, [self frame].size.height*.5, [self frame].size.width, aCurrentDividerThickness);
		[[self divider] setFrame:aFrame];
	}
	else if(mDividerOrientation==KTSplitViewDividerOrientation_Vertical)
	{
		NSRect aFrame = NSMakeRect([self frame].size.width*.5, 0, aCurrentDividerThickness, [self frame].size.height);
		[[self divider] setFrame:aFrame];
	}
	[self resetResizeInformation];
	[self setNeedsDisplay:YES];
}


//=========================================================== 
// - setDividerThickness
//===========================================================
- (void)setDividerThickness:(CGFloat)theThickness
{
	NSRect aDividerFrame = [mDivider frame];
	if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
		aDividerFrame.size.height = theThickness;
	else
		aDividerFrame.size.width = theThickness;
	[mDivider setFrame:aDividerFrame];	
	[self resetResizeInformation];
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - dividerThickness
//===========================================================
- (CGFloat)dividerThickness
{
	CGFloat aThicknessToReturn = 0;
	if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
		aThicknessToReturn = [mDivider frame].size.height;
	else
		aThicknessToReturn = [mDivider frame].size.width;
	return aThicknessToReturn;
}

//=========================================================== 
// - setDividerFillColor
//===========================================================
- (void)setDividerFillColor:(NSColor*)theColor
{
	[[[self divider] styleManager] setBackgroundColor:theColor];
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerBackgroundGradient
//===========================================================
- (void)setDividerBackgroundGradient:(NSGradient*)theGradient
{
	[[[self divider] styleManager] setBackgroundGradient:theGradient angle:180];	
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerStrokeColor
//===========================================================
- (void)setDividerStrokeColor:(NSColor*)theColor
{
	KTStyleManager * aDividerStyleManager = [mDivider styleManager];
	if(mDividerOrientation == KTSplitViewDividerOrientation_Horizontal)
	{
		[aDividerStyleManager setBorderWidthTop:1 right:0 bottom:1 left:0];
		[aDividerStyleManager setBorderColorTop:theColor right:nil bottom:theColor left:nil];
	}
	else
	{
		[aDividerStyleManager setBorderWidthTop:0 right:1 bottom:0 left:1];
		[aDividerStyleManager setBorderColorTop:nil right:theColor bottom:nil left:theColor];	
	}
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerFirstStrokeColor
//===========================================================
- (void)setDividerFirstStrokeColor:(NSColor*)theFirstColor secondColor:(NSColor*)theSecondColor
{
	KTStyleManager * aDividerStyleManager = [mDivider styleManager];
	if(mDividerOrientation == KTSplitViewDividerOrientation_Horizontal)
	{
		[aDividerStyleManager setBorderWidthTop:1 right:0 bottom:1 left:0];
		[aDividerStyleManager setBorderColorTop:theFirstColor right:nil bottom:theSecondColor left:nil];
	}
	else
	{
		[aDividerStyleManager setBorderWidthTop:0 right:1 bottom:0 left:1];
		[aDividerStyleManager setBorderColorTop:nil right:theFirstColor bottom:nil left:theSecondColor];	
	}
	[self setNeedsDisplay:YES];
}
@end
