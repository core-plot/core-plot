//
//  KTLayoutManagerUI.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTLayoutManagerControl.h"
#import <KTUIKit/KTLayoutManager.h>

#define	kCenterRectSize 100
#define kStrutMarkerSize 10


@interface KTLayoutManagerControl (Private)
- (void)setUpRects;
- (void)drawStrutInRect:(NSRect)theRect state:(KTLayoutControlStrutState)theState;
- (KTLayoutControlStrutState)topStrutState;
- (BOOL)isTopStrutEnabledForView:(id<KTViewLayout>)theView;
- (KTLayoutControlStrutState)bottomStrutState;
- (BOOL)isBottomStrutEnabledForView:(id<KTViewLayout>)theView;
- (KTLayoutControlStrutState)rightStrutState;
- (BOOL)isRightStrutEnabledForView:(id<KTViewLayout>)theView;
- (KTLayoutControlStrutState)leftStrutState;
- (BOOL)isLeftStrutEnabledForView:(id<KTViewLayout>)theView;
@end



@implementation KTLayoutManagerControl

//=========================================================== 
// @synthesizers
//=========================================================== 
@synthesize delegate = wDelegate;
@synthesize isEnabled = mIsEnabled;
@synthesize marginTop = mMarginTop;
@synthesize marginRight = mMarginRight;
@synthesize marginBottom = mMarginBottom;
@synthesize marginLeft = mMarginLeft;

#pragma mark -
//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
		
	[self setUpRects];							
	[[self styleManager] setBorderColor:[NSColor colorWithDeviceWhite:.6 alpha:1]];
	[[self styleManager] setBorderWidth:1];		
	[[self styleManager] setBackgroundColor:[NSColor colorWithDeviceWhite:1 alpha:.8]];			
	return self;
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;
	
	[self setDelegate:[theCoder decodeObjectForKey:@"delegate"]];
	[self setUpRects];							
	[[self styleManager] setBorderColor:[NSColor colorWithDeviceWhite:.6 alpha:1]];
	[[self styleManager] setBorderWidth:1];		
	[[self styleManager] setBackgroundColor:[NSColor colorWithDeviceWhite:.9 alpha:.8]];	
	[self setMarginTop:[NSNumber numberWithInt:0]];
	[self setMarginRight:[NSNumber numberWithInt:0]];
	[self setMarginBottom:[NSNumber numberWithInt:0]];
	[self setMarginLeft:[NSNumber numberWithInt:0]];
	[self setCanBecomeKeyView:NO];
	[self setCanBecomeFirstResponder:YES];
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:[self delegate] forKey:@"delegate"];
}


//=========================================================== 
// - dealloc:
//=========================================================== 
- (void)dealloc
{
	[mMarginTop release];
	[mMarginRight release];
	[mMarginBottom release];
	[mMarginLeft release];
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing
//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(CGContextRef)theContext
{	
	CGFloat anEnabledAlpha = 1.0;
	if(mIsEnabled==NO)
		anEnabledAlpha = .4;
		
	NSRect aViewRect = [self bounds];
	aViewRect.origin.x+=.5;
	aViewRect.origin.y+=.5;
	
	// center rect
	[[NSColor colorWithDeviceWhite:.6 alpha:1*anEnabledAlpha] set];
	[NSBezierPath strokeRect:mCenterRect];
	[[NSColor colorWithDeviceRed:103.0/255.0 green:154.0/255.0 blue:255.0/255.0 alpha:.4*anEnabledAlpha] set];
	[NSBezierPath fillRect:mCenterRect];
	
	// Top Strut
	KTLayoutControlStrutState aTopStrutState = [self topStrutState];
	[[NSColor colorWithCalibratedWhite:0 alpha:anEnabledAlpha] set];
	if(aTopStrutState == KTLayoutControlStrutState_Flexible)
	{
		[[NSColor colorWithCalibratedWhite:.4 alpha:anEnabledAlpha] set];
		[wTopMarginTextField setTextColor:[NSColor colorWithDeviceWhite:.4 alpha:anEnabledAlpha]];
	}
	else if([mMarginTop intValue] >= 0)
		[wTopMarginTextField setTextColor:[NSColor colorWithDeviceWhite:0 alpha:anEnabledAlpha]];
	else
		[wTopMarginTextField setTextColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:anEnabledAlpha]];
	[self drawStrutInRect:mTopMarginRect state:aTopStrutState];
	
	// Bottom Strut
	KTLayoutControlStrutState aBottomStrutState = [self bottomStrutState];
	[[NSColor colorWithCalibratedWhite:0 alpha:anEnabledAlpha] set];	
	if(aBottomStrutState == KTLayoutControlStrutState_Flexible)
	{
		[wBottomMarginTextField setTextColor:[NSColor colorWithDeviceWhite:.4 alpha:anEnabledAlpha]];
		[[NSColor colorWithCalibratedWhite:.4 alpha:anEnabledAlpha] set];
	}
	else if([mMarginBottom intValue]  >= 0)
		[wBottomMarginTextField setTextColor:[NSColor colorWithDeviceWhite:0 alpha:anEnabledAlpha]];
	else
		[wBottomMarginTextField setTextColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:anEnabledAlpha]];
	[self drawStrutInRect:mBottomMarginRect state:aBottomStrutState];

	// draw the fill height indicator
	[[NSColor colorWithDeviceRed:62.0/255.0 green:93.0/255.0 blue:154.0/255.0 alpha:anEnabledAlpha] set];
	NSRect aHeightIndicatorRect = NSMakeRect(NSMidX(mCenterRect)-kStrutMarkerSize*.5, NSMinY(mCenterRect)+2, kStrutMarkerSize, mCenterRect.size.height-4);
	[self drawStrutInRect:aHeightIndicatorRect state:mHeightStrutState];


	// right Strut
	KTLayoutControlStrutState aRightStrutState = [self rightStrutState];
	[[NSColor colorWithCalibratedWhite:0 alpha:anEnabledAlpha] set];
	if(aRightStrutState == KTLayoutControlStrutState_Flexible)
	{
		[wRightMarginTextField setTextColor:[NSColor colorWithCalibratedWhite:.4 alpha:anEnabledAlpha]];
		[[NSColor colorWithCalibratedWhite:.4 alpha:anEnabledAlpha] set];
	}
	else if( [mMarginRight intValue]  >= 0)
		[wRightMarginTextField setTextColor:[NSColor colorWithDeviceWhite:0 alpha:anEnabledAlpha]];
	else
		[wRightMarginTextField setTextColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:anEnabledAlpha]];
	[self drawStrutInRect:mRightMarginRect state:aRightStrutState];
		
	
	// left Strut
	KTLayoutControlStrutState aLeftStrutState = [self leftStrutState];	
	[[NSColor colorWithCalibratedWhite:0 alpha:anEnabledAlpha] set];
	if(aLeftStrutState == KTLayoutControlStrutState_Flexible)
	{
		[wLeftMarginTextField setTextColor:[NSColor colorWithDeviceWhite:.4 alpha:anEnabledAlpha]];	
		[[NSColor colorWithCalibratedWhite:.4 alpha:anEnabledAlpha] set];
	}
	else if([mMarginLeft intValue]  >= 0)
		[wLeftMarginTextField setTextColor:[NSColor colorWithDeviceWhite:0 alpha:anEnabledAlpha]];
	else
		[wLeftMarginTextField setTextColor:[NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:anEnabledAlpha]];
	[self drawStrutInRect:mLeftMarginRect state:aLeftStrutState];

	// draw the fill width indicator
	[[NSColor colorWithDeviceRed:62.0/255.0 green:93.0/255.0 blue:154.0/255.0 alpha:anEnabledAlpha] set];
	NSRect aWidthIndicatorRect = NSMakeRect(NSMinX(mCenterRect)+2, NSMidY(mCenterRect)-kStrutMarkerSize*.5, mCenterRect.size.width-4, kStrutMarkerSize);
	[self drawStrutInRect:aWidthIndicatorRect state:mWidthStrutState];
}


//=========================================================== 
// - drawStrutInRect:state:
//=========================================================== 
- (void)drawStrutInRect:(NSRect)theRect state:(KTLayoutControlStrutState)theState
{
	NSBezierPath * aStrutPath = [NSBezierPath bezierPath];
	NSPoint aPoint;
	if(theRect.size.width > theRect.size.height)
	{
		// horizontal orientation
		
		aPoint = NSMakePoint(NSMaxX(theRect), NSMidY(theRect));
		[aStrutPath moveToPoint:aPoint];
		if(theState==KTLayoutControlStrutState_Flexible)
		{
			// go 1/4 down and stroke
			aPoint = NSMakePoint(aPoint.x-theRect.size.width*.25, aPoint.y);
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
			
			// a dashed path
			NSBezierPath * aDashedPath = [NSBezierPath bezierPath];
			[aDashedPath moveToPoint:aPoint];
			CGFloat aLineDash[1];
			aLineDash[0] = 2.0;
			[aDashedPath setLineDash:aLineDash count:1 phase:0.0];
			aPoint = NSMakePoint(aPoint.x-theRect.size.width*.5, aPoint.y);
			[aDashedPath lineToPoint:aPoint];
			[aDashedPath stroke];
			
			// regular stroke the rest of the way
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMinX(theRect), NSMidY(theRect));
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
			
			// left marker
			aPoint = NSMakePoint(NSMinX(theRect)+kStrutMarkerSize*.5, NSMidY(theRect)-kStrutMarkerSize*.5);
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMinX(theRect), NSMidY(theRect));
			[aStrutPath lineToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x+kStrutMarkerSize*.5, aPoint.y+kStrutMarkerSize*.5);
			[aStrutPath lineToPoint:aPoint];

			// right marker
			aPoint = NSMakePoint(NSMaxX(theRect)-kStrutMarkerSize*.5, NSMidY(theRect)+kStrutMarkerSize*.5);
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMaxX(theRect), NSMidY(theRect));
			[aStrutPath lineToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x-kStrutMarkerSize*.5, aPoint.y-kStrutMarkerSize*.5);
			[aStrutPath lineToPoint:aPoint];
			
			[aStrutPath stroke];
		}
		else if(theState == KTLayoutControlStrutState_Mixed)
		{
			// draw a dashed line the whole way
			CGFloat aLineDash[1];
			aLineDash[0] = 2.0;
			[aStrutPath setLineDash:aLineDash count:1 phase:0.0];
			aPoint = NSMakePoint(aPoint.x-theRect.size.width, aPoint.y);
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
		}
		else
		{
			// bottom middle
			aPoint = NSMakePoint(NSMinX(theRect), NSMidY(theRect));
			[aStrutPath lineToPoint:aPoint];
			
			// left marker
			aPoint = NSMakePoint(NSMinX(theRect), NSMidY(theRect)-kStrutMarkerSize*.5);
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x, aPoint.y+kStrutMarkerSize);
			[aStrutPath lineToPoint:aPoint];

			// bottom marker
			aPoint = NSMakePoint(NSMaxX(theRect), NSMidY(theRect)-kStrutMarkerSize*.5);		
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x, aPoint.y+kStrutMarkerSize);	
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
		}
	}
	else
	{
		// vertical orientation
		aPoint = NSMakePoint(NSMidX(theRect), NSMaxY(theRect));
		[aStrutPath moveToPoint:aPoint];
		
		if(theState==KTLayoutControlStrutState_Flexible)
		{	
			// go 1/4 down and stroke
			aPoint = NSMakePoint(aPoint.x, aPoint.y-theRect.size.height*.25);
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
			
			// a dashed path
			NSBezierPath * aDashedPath = [NSBezierPath bezierPath];
			[aDashedPath moveToPoint:aPoint];
			float aLineDash[1];
			aLineDash[0] = 2.0;
			[aDashedPath setLineDash:aLineDash count:1 phase:0.0];
			aPoint = NSMakePoint(aPoint.x, aPoint.y-theRect.size.height*.5);
			[aDashedPath lineToPoint:aPoint];
			[aDashedPath stroke];
			
			// regular stroke the rest of the way
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMidX(theRect), NSMinY(theRect));
			[aStrutPath lineToPoint:aPoint];
			[aStrutPath stroke];
			
			// top marker
			aPoint = NSMakePoint(NSMidX(theRect)-kStrutMarkerSize*.5, NSMaxY(theRect)-kStrutMarkerSize*.5);
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMidX(theRect), NSMaxY(theRect));
			[aStrutPath lineToPoint:aPoint];
			aPoint = NSMakePoint(NSMidX(theRect)+kStrutMarkerSize*.5, NSMaxY(theRect)-kStrutMarkerSize*.5);
			[aStrutPath lineToPoint:aPoint];

			// bottom marker
			aPoint = NSMakePoint(NSMidX(theRect)-kStrutMarkerSize*.5, NSMinY(theRect)+kStrutMarkerSize*.5);
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(NSMidX(theRect), NSMinY(theRect));
			[aStrutPath lineToPoint:aPoint];
			aPoint = NSMakePoint(NSMidX(theRect)+kStrutMarkerSize*.5, NSMinY(theRect)+kStrutMarkerSize*.5);
			[aStrutPath lineToPoint:aPoint];
					
			[aStrutPath stroke];

		}
		else if(theState == KTLayoutControlStrutState_Mixed)
		{
			// draw a dashed line the whole way
			CGFloat aLineDash[1];
			aLineDash[0] = 2.0;
			[aStrutPath setLineDash:aLineDash count:1 phase:0.0];
			aPoint = NSMakePoint(aPoint.x, aPoint.y-theRect.size.height);
			[aStrutPath lineToPoint:aPoint];

			[aStrutPath stroke];
		}
		else
		{
			// bottom middle
			aPoint = NSMakePoint(NSMidX(theRect), NSMinY(theRect));
			[aStrutPath lineToPoint:aPoint];
			
			// top marker
			aPoint = NSMakePoint(NSMidX(theRect)-kStrutMarkerSize*.5, NSMaxY(theRect));
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x+kStrutMarkerSize, aPoint.y);
			[aStrutPath lineToPoint:aPoint];

			// bottom marker
			aPoint = NSMakePoint(NSMidX(theRect)-kStrutMarkerSize*.5, NSMinY(theRect));
			[aStrutPath moveToPoint:aPoint];
			aPoint = NSMakePoint(aPoint.x+kStrutMarkerSize, aPoint.y);
			[aStrutPath lineToPoint:aPoint];

			[aStrutPath stroke];
		}
	}
}


#pragma mark -
#pragma mark Updating Content
//=========================================================== 
// - refresh
//=========================================================== 
- (void)refresh
{
	NSArray * anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
		
	BOOL	aFoundMultipleValuesTopMargin = NO;
	BOOL	aFoundMultipleValuesRightMargin = NO;
	BOOL	aFoundMultipleValuesBottomMargin = NO;
	BOOL	aFoundMultipleValuesLeftMargin = NO;
	BOOL	aFoundMultipleValuesWidthType = NO;
	BOOL	aFoundMultipleValuesHeightType = NO;
	
	if(		mIsEnabled
		&&	[anInspectedViewArray count] > 0)
	{
		// get the first values
		id<KTViewLayout>	aFirstView = [anInspectedViewArray objectAtIndex:0];
		KTLayoutManager *	aFirstLayoutManger = [aFirstView viewLayoutManager];
		
		// margins
		CGFloat aFirstViewMarginTop = [[aFirstView parent] frame].size.height - ([aFirstView frame].origin.y+[aFirstView frame].size.height);
		CGFloat aFirstViewMarginRight = [[aFirstView parent] frame].size.width - ([aFirstView frame].origin.x+[aFirstView frame].size.width);
		CGFloat aFirstViewMarginBottom = [aFirstView frame].origin.y;
		CGFloat aFirstViewMarginLeft = [aFirstView frame].origin.x;
		[aFirstLayoutManger setMarginTop:aFirstViewMarginTop right:aFirstViewMarginRight bottom:aFirstViewMarginBottom left:aFirstViewMarginLeft];
		
		// size types
		KTSizeType aFirstViewWidthType = [aFirstLayoutManger widthType];
		KTSizeType aFirstViewHeightType = [aFirstLayoutManger heightType];	
		
		
		if([aFirstLayoutManger verticalPositionType]==KTVerticalPositionProportional)
		{
			CGFloat aLeftOverHeight = [[aFirstView parent] frame].size.height - [aFirstView frame].size.height;
			if(aLeftOverHeight==0)
				aLeftOverHeight = 1;
			CGFloat aPercentage = [aFirstView frame].origin.y/aLeftOverHeight;
			[aFirstLayoutManger setVerticalPositionPercentage:aPercentage];
		}
		if([aFirstLayoutManger horizontalPositionType]==KTHorizontalPositionProportional)
		{
			if(NSWidth([[aFirstView parent]frame])!=0)
			{
				CGFloat aLeftOverWidth = NSWidth([[aFirstView parent]frame]) - NSWidth([aFirstView frame]);
				if(aLeftOverWidth==0)
					aLeftOverWidth = 1;
				CGFloat aPercentage = [aFirstView frame].origin.x/aLeftOverWidth;
				[aFirstLayoutManger setHorizontalPositionPercentage:aPercentage];
			}
		}
		
						
		int i;
		for(i = 1; i < [anInspectedViewArray count]; i++)
		{
			id<KTViewLayout>	aView = [anInspectedViewArray objectAtIndex:i];
			KTLayoutManager *	aLayoutManager = [aView viewLayoutManager];
			
			
			if([aLayoutManager verticalPositionType]==KTVerticalPositionProportional)
			{
				CGFloat aLeftOverHeight = [[aView parent] frame].size.height - [aView frame].size.height;
				if(aLeftOverHeight==0)
					aLeftOverHeight = 1;
				CGFloat aPercentage = [aView frame].origin.y/aLeftOverHeight;
				[aLayoutManager setVerticalPositionPercentage:aPercentage];
			}
			if([aLayoutManager horizontalPositionType]==KTHorizontalPositionProportional)
			{
				if(NSWidth([[aView parent]frame])!=0)
				{
					CGFloat aLeftOverWidth = NSWidth([[aView parent]frame]) - NSWidth([aView frame]);
					if(aLeftOverWidth==0)
						aLeftOverWidth = 1;
					CGFloat aPercentage = [aView frame].origin.x/aLeftOverWidth;
					[aLayoutManager setHorizontalPositionPercentage:aPercentage];
				}
			}
					
			// top margin
			CGFloat aViewMargin = [[aView parent] frame].size.height - ([aView frame].origin.y+[aView frame].size.height);
			[aLayoutManager setMarginTop:aViewMargin];
			if(aViewMargin!=aFirstViewMarginTop)
				aFoundMultipleValuesTopMargin = YES;
			
			// bottom margin
			aViewMargin = [aView frame].origin.y;
			[aLayoutManager setMarginBottom:aViewMargin];
			if(aViewMargin!=aFirstViewMarginBottom)
				aFoundMultipleValuesBottomMargin = YES;

			// margin left
			aViewMargin = [aView frame].origin.x;
			[aLayoutManager setMarginLeft:aViewMargin];
			if(aViewMargin!=aFirstViewMarginLeft)
				aFoundMultipleValuesLeftMargin = YES;
			
			// margin right
			aViewMargin = [[aView parent] frame].size.width - ([aView frame].origin.x+[aView frame].size.width);
			[aLayoutManager setMarginRight:aViewMargin];
			if(aViewMargin!=aFirstViewMarginRight)
				aFoundMultipleValuesRightMargin = YES;
			
			// width type	
			if(		aFoundMultipleValuesWidthType == NO
				&&	aFirstViewWidthType != [aLayoutManager widthType])
				aFoundMultipleValuesWidthType = YES;
			// height type
			if(		aFoundMultipleValuesHeightType == NO
				&&	aFirstViewHeightType != [aLayoutManager heightType])
				aFoundMultipleValuesHeightType = YES;	
		}
		
		// set margin values
		if(aFoundMultipleValuesTopMargin)
			[self setMarginTop:[NSNumber numberWithInt:NSNotFound]];
		else
			[self setMarginTop:[NSNumber numberWithInt:aFirstViewMarginTop]];

		if(aFoundMultipleValuesRightMargin)
			[self setMarginRight:[NSNumber numberWithInt:NSNotFound]];
		else
			[self setMarginRight:[NSNumber numberWithInt:aFirstViewMarginRight]];
		
		if(aFoundMultipleValuesBottomMargin)
			[self setMarginBottom:[NSNumber numberWithInt:NSNotFound]];
		else
			[self setMarginBottom:[NSNumber numberWithInt:aFirstViewMarginBottom]];
	
		if(aFoundMultipleValuesLeftMargin)
			[self setMarginLeft:[NSNumber numberWithInt:NSNotFound]];
		else
			[self setMarginLeft:[NSNumber numberWithInt:aFirstViewMarginLeft]];
			
			
		if(aFoundMultipleValuesWidthType)
			mWidthStrutState = KTLayoutControlStrutState_Mixed;
		else if(aFirstViewWidthType == KTSizeFill)
			mWidthStrutState = KTLayoutControlStrutState_Flexible;
		else
			mWidthStrutState = KTLayoutControlStrutState_Fixed;
			
		if(aFoundMultipleValuesHeightType)
			mHeightStrutState = KTLayoutControlStrutState_Mixed;
		else if(aFirstViewHeightType == KTSizeFill)
			mHeightStrutState = KTLayoutControlStrutState_Flexible;
		else
			mHeightStrutState = KTLayoutControlStrutState_Fixed;
			
			
		mTopStrutState = [self topStrutState];
		if(mTopStrutState == KTLayoutControlStrutState_Flexible)
		{
			[wTopMarginTextField setStringValue:@"Flexible"];
			[wTopMarginTextField setEditable:NO];
			[wTopMarginTextField setSelectable:NO];
		}
		else
		{
			[wTopMarginTextField setEditable:YES];
			[wTopMarginTextField setSelectable:YES];
		}
		
		mRightStrutState = [self rightStrutState];
		if(mRightStrutState == KTLayoutControlStrutState_Flexible)
		{
			[wRightMarginTextField setStringValue:@"Flexible"];
			[wRightMarginTextField setEditable:NO];
			[wRightMarginTextField setSelectable:NO];
		}
		else
		{
			[wRightMarginTextField setEditable:YES];
			[wRightMarginTextField setSelectable:YES];
		}
		
		mBottomStrutState = [self bottomStrutState];
		if(mBottomStrutState == KTLayoutControlStrutState_Flexible)
		{
			[wBottomMarginTextField setStringValue:@"Flexible"];
			[wBottomMarginTextField setEditable:NO];
			[wBottomMarginTextField setSelectable:NO];
		}
		else
		{
			[wBottomMarginTextField setEditable:YES];
			[wBottomMarginTextField setSelectable:YES];
		}
		
		mLeftStrutState = [self leftStrutState];
		if(mLeftStrutState == KTLayoutControlStrutState_Flexible)
		{
			[wLeftMarginTextField setStringValue:@"Flexible"];
			[wLeftMarginTextField setEditable:NO];
			[wLeftMarginTextField setSelectable:NO];
		}
		else
		{
			[wLeftMarginTextField setEditable:YES];
			[wLeftMarginTextField setSelectable:YES];
		}
	}
	
	
	
	
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setIsEnabled
//=========================================================== 
- (void)setIsEnabled:(BOOL)theBool
{
	mIsEnabled = theBool;
	if(mIsEnabled==NO)
	{
		NSArray *	anInspectedViewArray = nil;
		if([wDelegate respondsToSelector:@selector(inspectedObjects)])
			anInspectedViewArray = [wDelegate inspectedObjects];
		{
			for(id<KTViewLayout> aView in anInspectedViewArray)
			{
				[[aView viewLayoutManager] setMargin:0];
			}
		}
		[self setMarginTop:[NSNumber numberWithInt:0]];
		[self setMarginRight:[NSNumber numberWithInt:0]];
		[self setMarginBottom:[NSNumber numberWithInt:0]];
		[self setMarginLeft:[NSNumber numberWithInt:0]];
		[self setNeedsDisplay:YES];
	}
}


//=========================================================== 
// - setMarginTop
//=========================================================== 
- (void)setMarginTop:(NSNumber*)theNumber
{
	[theNumber retain];
	[mMarginTop release];
	mMarginTop = theNumber;
	if([theNumber intValue] == NSNotFound)
		[wTopMarginTextField setStringValue:@"Mixed"];
	else
		[wTopMarginTextField setIntValue:[theNumber intValue]];
}

//=========================================================== 
// - setMarginRight
//=========================================================== 
- (void)setMarginRight:(NSNumber*)theNumber
{
	[theNumber retain];
	[mMarginRight release];
	mMarginRight = theNumber;
	if([theNumber intValue] == NSNotFound)
		[wRightMarginTextField setStringValue:@"Mixed"];
	else
		[wRightMarginTextField setIntValue:[theNumber intValue]];
}

//=========================================================== 
// - setMarginBottom
//=========================================================== 
- (void)setMarginBottom:(NSNumber*)theNumber
{
	[theNumber retain];
	[mMarginBottom release];
	mMarginBottom = theNumber;
	if([theNumber intValue] == NSNotFound)
		[wBottomMarginTextField setStringValue:@"Mixed"];
	else
		[wBottomMarginTextField setIntValue:[theNumber intValue]];
}

//=========================================================== 
// - setMarginLeft
//=========================================================== 
- (void)setMarginLeft:(NSNumber*)theNumber
{
	[theNumber retain];
	[mMarginLeft release];
	mMarginLeft = theNumber;
	if([theNumber intValue] == NSNotFound)
		[wLeftMarginTextField setStringValue:@"Mixed"];
	else
		[wLeftMarginTextField setIntValue:[theNumber intValue]];
}



#pragma mark -
#pragma mark Actions
//=========================================================== 
// - setTopMargin
//=========================================================== 
- (IBAction)setTopMargin:(id)theSender
{
	CGFloat aMarginToSet = [theSender floatValue];
	NSArray *	anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	if([anInspectedViewArray count] > 0)
	{
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			NSRect	aViewFrame = [aView frame];
			CGFloat aParentHeight = [[aView parent] frame].size.height;
			
			// if the bottom strut is fixed, adjust the height of the view as well
			if([self isBottomStrutEnabledForView:aView])
				aViewFrame.size.height = aParentHeight- aMarginToSet - aViewFrame.origin.y;
			aViewFrame.origin.y = aParentHeight - aMarginToSet - aViewFrame.size.height;
			[aView setFrame:aViewFrame];
		}
	}
	[self refresh];
}

//=========================================================== 
// - setRightMargin
//=========================================================== 
- (IBAction)setRightMargin:(id)theSender
{
	CGFloat aRightMarginToSet = [theSender floatValue];
	NSArray *	anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	if([anInspectedViewArray count] > 0)
	{
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			NSRect	aViewFrame = [aView frame];
			CGFloat aParentWidth = [[aView parent] frame].size.width;
			
			// if the left strut is fixed, adjust the width of the view as well
			if([self isLeftStrutEnabledForView:aView])
				aViewFrame.size.width = aParentWidth - aRightMarginToSet - aViewFrame.origin.x;
			aViewFrame.origin.x = aParentWidth - aRightMarginToSet - aViewFrame.size.width;
			[aView setFrame:aViewFrame];
		}
	}
	[self refresh];
}

//=========================================================== 
// - setBottomMargin
//=========================================================== 
- (IBAction)setBottomMargin:(id)theSender
{
	CGFloat aMarginToSet = [theSender floatValue];
	NSArray *	anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	if([anInspectedViewArray count] > 0)
	{
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			NSRect	aViewFrame = [aView frame];
			// if the top strut is fixed, adjust the height of the view
			if([self isTopStrutEnabledForView:aView])
			{
				CGFloat aTopMargin = [[aView parent] frame].size.height - (aViewFrame.origin.y+aViewFrame.size.height);
				aViewFrame.size.height = [[aView parent] frame].size.height - aTopMargin - aMarginToSet;
			}
			aViewFrame.origin.y = aMarginToSet;
			[aView setFrame:aViewFrame];
		}
	}
	[self refresh];
}

//=========================================================== 
// - setLeftMargin
//=========================================================== 
-(IBAction)setLeftMargin:(id)theSender
{
	CGFloat aMarginToSet = [theSender floatValue];
	NSArray *	anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	if([anInspectedViewArray count] > 0)
	{
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			NSRect	aViewFrame = [aView frame];
			// if the right strut is fixed, adjust the width of the view
			if([self isRightStrutEnabledForView:aView])
			{
				CGFloat aRightMargin = [[aView parent] frame].size.width - (aViewFrame.origin.x+aViewFrame.size.width);
				aViewFrame.size.width = [[aView parent] frame].size.width - aRightMargin - aMarginToSet;
			}
			aViewFrame.origin.x = aMarginToSet;
			[aView setFrame:aViewFrame];
		}
	}
	[self refresh];
}


#pragma mark -
#pragma mark Events 
//=========================================================== 
// - acceptsFirstMouse
//=========================================================== 
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

//=========================================================== 
// - becomeFirstResponder
//=========================================================== 
- (void)becomeFirstResponder
{
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - mouseDown:
//=========================================================== 
- (void)mouseDown:(NSEvent*)theEvent
{
	if(mIsEnabled==NO)
		return;
		
	NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// Top Strut hit
	NSRect aTopStrutHitArea = NSMakeRect(NSMinX(mCenterRect), NSMaxY(mCenterRect), NSWidth(mCenterRect), NSHeight(mTopMarginRect));
	if(NSPointInRect(aMousePoint, aTopStrutHitArea))
	{
		KTLayoutControlStrutState aTopStrutState = [self topStrutState];
		NSArray *	anInspectedViewArray = nil;
		if([wDelegate respondsToSelector:@selector(inspectedObjects)])
			anInspectedViewArray = [wDelegate inspectedObjects];
		if([anInspectedViewArray count] > 0)
		{
			for(id<KTViewLayout> aView in anInspectedViewArray)
			{
				KTLayoutManager * aViewLayoutManager = [aView viewLayoutManager];

				// check if it's enabled
			
				// enabled
				if(aTopStrutState == KTLayoutControlStrutState_Fixed)
				{
					// if the bottom is Flexible - we'll put it in proportional mode
					if([self isBottomStrutEnabledForView:aView] == NO)
					{
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionProportional];
						if(NSHeight([[aView parent]frame])!=0)
						{
							CGFloat aLeftOverHeight = [[aView parent] frame].size.height - [aView frame].size.height;
							if(aLeftOverHeight==0)
								aLeftOverHeight = 1;
							CGFloat aPercentage = [aView frame].origin.y/aLeftOverHeight;
							[aViewLayoutManager setVerticalPositionPercentage:aPercentage];
						}
					}
					else // bottom is fixed, so set it to 'stick' to the bottom margin
					{
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionStickBottom];
						[aViewLayoutManager setMarginTop:0];
						CGFloat aBottomMargin = [aView frame].origin.y;
						[aViewLayoutManager setMarginBottom:aBottomMargin];
						[aViewLayoutManager setHeightType:KTSizeAbsolute];
					}
				}
				else if(	aTopStrutState == KTLayoutControlStrutState_Flexible
						||	aTopStrutState == KTLayoutControlStrutState_Mixed)
				{						
					// if the bottom strut is fixed, set view to maintain margins and fill its height
					if([self isBottomStrutEnabledForView:aView])
					{
						CGFloat aTopMargin = [[aView parent] frame].size.height - ([aView frame].origin.y+[aView frame].size.height);
						CGFloat aBottomMargin = [aView frame].origin.y;
						[aViewLayoutManager setMarginTop:aTopMargin];
						[aViewLayoutManager setMarginBottom:aBottomMargin];
						[aViewLayoutManager setHeightType:KTSizeFill];
					}
					else // otherwise, set it to stick to the top margin
					{
						CGFloat aTopMargin = [[aView parent] frame].size.height - ([aView frame].origin.y+[aView frame].size.height);
						[aViewLayoutManager setMarginTop:aTopMargin];
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionStickTop];
					}
				}
			}
			[self refresh];
			[self setNeedsDisplay:YES];
			return;
		}
	}
	// Bottom strut hit
	NSRect aBottomStrutHitArea = NSMakeRect(NSMinX(mCenterRect), NSMinY([self bounds]), NSWidth(mCenterRect), NSMinY(mCenterRect));
	if(NSPointInRect(aMousePoint, aBottomStrutHitArea))
	{
		KTLayoutControlStrutState aBottomStrutState = [self bottomStrutState];
		NSArray *	anInspectedViewArray = nil;
		if([wDelegate respondsToSelector:@selector(inspectedObjects)])
			anInspectedViewArray = [wDelegate inspectedObjects];
			
		if([anInspectedViewArray count] > 0)
		{
			for(id<KTViewLayout> aView in anInspectedViewArray)
			{
				KTLayoutManager * aViewLayoutManager = [aView viewLayoutManager];
				
				// check if the strut is enabled
				if(aBottomStrutState == KTLayoutControlStrutState_Fixed)
				{
					// disable the bottom strut
					
					// if the top strut is enabled, set the view to stick to the top margin
					if([self isTopStrutEnabledForView:aView])
					{
						CGFloat aTopMargin = [[aView parent] frame].size.height - ([aView frame].origin.y+[aView frame].size.height);
						[aViewLayoutManager setMarginTop:aTopMargin];
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionStickTop];
						[aViewLayoutManager setMarginBottom:0];
						[aViewLayoutManager setHeightType:KTSizeAbsolute];
					}
					else //otherwise we'll set both margins Flexible
					{
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionProportional];
						if(NSHeight([[aView parent]frame])!=0)
						{
							CGFloat aLeftOverHeight = [[aView parent] frame].size.height - [aView frame].size.height;
							if(aLeftOverHeight==0)
								aLeftOverHeight = 1;
							CGFloat aPercentage = [aView frame].origin.y/aLeftOverHeight;
							[aViewLayoutManager setVerticalPositionPercentage:aPercentage];
						}
					}
				}
				else if(	aBottomStrutState == KTLayoutControlStrutState_Flexible
						||	aBottomStrutState == KTLayoutControlStrutState_Mixed)
				{
					// enable it
					
					// if the top strut is enabled
					if([self isTopStrutEnabledForView:aView])
					{
						// set both margins and fill height
						CGFloat aTopMargin = [[aView parent] frame].size.height - ([aView frame].origin.y+[aView frame].size.height);
						CGFloat aBottomMargin = [aView frame].origin.y;
						[aViewLayoutManager setMarginTop:aTopMargin];
						[aViewLayoutManager setMarginBottom:aBottomMargin];
						[aViewLayoutManager setHeightType:KTSizeFill];
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionAbsolute];
					}
					else // set bottom margin and reset the height type 
					{
						CGFloat aBottomMargin = [aView frame].origin.y;
						[aViewLayoutManager setMarginBottom:aBottomMargin];
						[aViewLayoutManager setVerticalPositionType:KTVerticalPositionStickBottom];
						[aViewLayoutManager setHeightType:KTSizeAbsolute];
					}
				}
			}
			[self refresh];
			[self setNeedsDisplay:YES];
			return;
		}
		
	}
	// Left strut hit
	NSRect aLeftStrutHitArea = NSMakeRect(NSMinX([self bounds]), NSMinY(mCenterRect), NSMinX(mCenterRect), NSHeight(mCenterRect));
	if(NSPointInRect(aMousePoint, aLeftStrutHitArea))
	{
		KTLayoutControlStrutState aLeftStrutState = [self leftStrutState];
		NSArray *	anInspectedViewArray = nil;
		if([wDelegate respondsToSelector:@selector(inspectedObjects)])
			anInspectedViewArray = [wDelegate inspectedObjects];
			
		if([anInspectedViewArray count] > 0)
		{
			for(id<KTViewLayout> aView in anInspectedViewArray)
			{
				KTLayoutManager * aViewLayoutManager = [aView viewLayoutManager];
				
				// Left strut is enabled
				if(aLeftStrutState == KTLayoutControlStrutState_Fixed)
				{
					// disable it
					if([self isRightStrutEnabledForView:aView])
					{
						// if the right strut is enabled
						// set view to stick to the right margin
						[aViewLayoutManager setMarginLeft:0];
						[aViewLayoutManager setWidthType:KTSizeAbsolute];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionStickRight];
					}
					else
					{
						// set both margins to be Flexible
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionProportional];
						if(NSWidth([[aView parent]frame])!=0)
						{
							CGFloat aLeftOverWidth = NSWidth([[aView parent]frame]) - NSWidth([aView frame]);
							if(aLeftOverWidth==0)
								aLeftOverWidth = 1;
							CGFloat aPercentage = [aView frame].origin.x/aLeftOverWidth;
							[aViewLayoutManager setHorizontalPositionPercentage:aPercentage];
							[aViewLayoutManager setWidthType:KTSizeAbsolute];
						}
					}
				}
				else if(	aLeftStrutState == KTLayoutControlStrutState_Flexible
						||	aLeftStrutState == KTLayoutControlStrutState_Mixed)
				{
					// enable it
					
					// if right strut is enabled
					if([self isRightStrutEnabledForView:aView])
					{
						// set view left & right margins and fill width
						KTLayoutManager * aViewLayoutManager = [aView viewLayoutManager];
						CGFloat aRightMargin = [[aView parent] frame].size.width - ([aView frame].origin.x+[aView frame].size.width);
						CGFloat aLeftMargin = [aView frame].origin.x;
						[aViewLayoutManager setMarginRight:aRightMargin];
						[aViewLayoutManager setMarginLeft:aLeftMargin];
						[aViewLayoutManager setWidthType:KTSizeFill];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionAbsolute];
					}
					else
					{
						// just the left strut enabled
						// set view to stick to the left
						CGFloat aLeftMargin = [aView frame].origin.x;
						[aViewLayoutManager setMarginLeft:aLeftMargin];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionStickLeft];
						[aViewLayoutManager setWidthType:KTSizeAbsolute];
					}	
				}
			}
			[self refresh];
			[self setNeedsDisplay:YES];
			return;
		}
	}
	// Right strut hit
	NSRect aRighStrutHitArea = NSMakeRect(NSMaxX(mCenterRect), NSMinY(mCenterRect), NSWidth([self bounds])-NSMaxX(mCenterRect), NSHeight(mCenterRect));
	if(NSPointInRect(aMousePoint, aRighStrutHitArea))
	{
		KTLayoutControlStrutState aRightStrutState = [self rightStrutState];	
		NSArray *	anInspectedViewArray = nil;
		if([wDelegate respondsToSelector:@selector(inspectedObjects)])
			anInspectedViewArray = [wDelegate inspectedObjects];
		if([anInspectedViewArray count] > 0)
		{
			for(id<KTViewLayout> aView in anInspectedViewArray)
			{
				KTLayoutManager * aViewLayoutManager = [aView viewLayoutManager];

				// the right struct is enabled
				if(aRightStrutState == KTLayoutControlStrutState_Fixed)
				{
					// disable it
					
					if([self isLeftStrutEnabledForView:aView])
					{
						// if the left strut is enabled
						// set to stick left
						CGFloat aLeftMargin = [aView frame].origin.x;
						[aViewLayoutManager setMarginLeft:aLeftMargin];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionStickLeft];
						[aViewLayoutManager setWidthType:KTSizeAbsolute];
					}
					else
					{
						// set margins Flexible
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionProportional];
						if(NSWidth([[aView parent]frame])!=0)
						{
							CGFloat aLeftOverWidth = NSWidth([[aView parent]frame]) - NSWidth([aView frame]);
							if(aLeftOverWidth==0)
								aLeftOverWidth = 1;
							CGFloat aPercentage = [aView frame].origin.x/aLeftOverWidth;
							[aViewLayoutManager setHorizontalPositionPercentage:aPercentage];
							[aViewLayoutManager setWidthType:KTSizeAbsolute];
						}
					}
				}
				// the right strut is disabled
				else if(	aRightStrutState == KTLayoutControlStrutState_Flexible
						||	aRightStrutState == KTLayoutControlStrutState_Mixed)
				{
					// enable it
					if([self isLeftStrutEnabledForView:aView])
					{
						// if the left strut is also enabled, fill width
						CGFloat aRightMargin = [[aView parent] frame].size.width - ([aView frame].origin.x+[aView frame].size.width);
						CGFloat aLeftMargin = [aView frame].origin.x;
						[aViewLayoutManager setMarginRight:aRightMargin];
						[aViewLayoutManager setMarginLeft:aLeftMargin];
						[aViewLayoutManager setWidthType:KTSizeFill];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionAbsolute];
					}
					else
					{	
						// stick to the right
						CGFloat aRightMargin = [[aView parent] frame].size.width - ([aView frame].origin.x+[aView frame].size.width);
						[aViewLayoutManager setMarginRight:aRightMargin];
						[aViewLayoutManager setHorizontalPositionType:KTHorizontalPositionStickRight];
						[aViewLayoutManager setWidthType:KTSizeAbsolute];
					}
				}
			}
		}
		[self refresh];
		[self setNeedsDisplay:YES];
		return;
	}
}



#pragma mark -
#pragma mark Managing The Struts
//=========================================================== 
// - topStrutState
//=========================================================== 
- (KTLayoutControlStrutState)topStrutState
{
	KTLayoutControlStrutState aStateToReturn;
	NSArray * anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	
	BOOL aFoundMultipleValuesForEnabled = NO;
	BOOL anIsTopStrutEnabled;
	
	if([anInspectedViewArray count] > 0)
	{
		id <KTViewLayout> aFirstView = [anInspectedViewArray objectAtIndex:0];
		anIsTopStrutEnabled = [self isTopStrutEnabledForView:aFirstView];
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			BOOL anIsTopStrutEnabledForOtherView = [self isTopStrutEnabledForView:aView];
			if(anIsTopStrutEnabled != anIsTopStrutEnabledForOtherView)
			{
				aFoundMultipleValuesForEnabled = YES;
				break;
			}
		}
	}
	
	if(aFoundMultipleValuesForEnabled)
		aStateToReturn = KTLayoutControlStrutState_Mixed;
	else if(anIsTopStrutEnabled)
		aStateToReturn = KTLayoutControlStrutState_Fixed;
	else
		aStateToReturn = KTLayoutControlStrutState_Flexible;
		
	return aStateToReturn;
}


//=========================================================== 
// - isTopStrutEnabledForView
//=========================================================== 
- (BOOL)isTopStrutEnabledForView:(id<KTViewLayout>)theView
{
	BOOL	aReturnValue = NO;
	
	KTLayoutManager *		aLayoutManger = [theView viewLayoutManager];
	KTVerticalPositionType	aViewVPosType = [aLayoutManger verticalPositionType];
	KTSizeType				aViewHeightType = [aLayoutManger heightType];
		
	if(		aViewHeightType == KTSizeFill
		||	aViewVPosType == KTVerticalPositionStickTop)
		aReturnValue = YES;
		
	return aReturnValue;
}


//=========================================================== 
// - bottomStrutState
//=========================================================== 
- (KTLayoutControlStrutState)bottomStrutState
{
	KTLayoutControlStrutState aStateToReturn;
	NSArray * anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	
	BOOL aFoundMultipleValuesForEnabled = NO;
	BOOL anIsBottomStrutEnabled;
	
	if([anInspectedViewArray count] > 0)
	{
		id <KTViewLayout> aFirstView = [anInspectedViewArray objectAtIndex:0];
		anIsBottomStrutEnabled = [self isBottomStrutEnabledForView:aFirstView];
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			BOOL anIsBottomStrutEnabledForOtherView = [self isBottomStrutEnabledForView:aView];
			if(anIsBottomStrutEnabled != anIsBottomStrutEnabledForOtherView)
			{
				aFoundMultipleValuesForEnabled = YES;
				break;
			}
		}
	}
	
	if(aFoundMultipleValuesForEnabled)
		aStateToReturn = KTLayoutControlStrutState_Mixed;
	else if(anIsBottomStrutEnabled)
		aStateToReturn = KTLayoutControlStrutState_Fixed;
	else
		aStateToReturn = KTLayoutControlStrutState_Flexible;
		
	return aStateToReturn;
}

//=========================================================== 
// - isBottomStrutEnabledForView:
//=========================================================== 
- (BOOL)isBottomStrutEnabledForView:(id<KTViewLayout>)theView
{
	BOOL aReturnValue = NO;
	KTLayoutManager * aLayoutManger = [theView viewLayoutManager];
	if(		[aLayoutManger heightType] == KTSizeFill
		||	[aLayoutManger verticalPositionType] == KTVerticalPositionStickBottom
		||	(	[aLayoutManger verticalPositionType] == KTVerticalPositionAbsolute
			&&	[aLayoutManger heightType] != KTSizeFill) )
		aReturnValue = YES;

	return aReturnValue;
}


//=========================================================== 
// - rightStrutState
//=========================================================== 
- (KTLayoutControlStrutState)rightStrutState
{
	KTLayoutControlStrutState aStateToReturn;
	NSArray * anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	
	BOOL aFoundMultipleValuesForEnabled = NO;
	BOOL anIsRightStrutEnabled;
	
	if([anInspectedViewArray count] > 0)
	{
		id <KTViewLayout> aFirstView = [anInspectedViewArray objectAtIndex:0];
		anIsRightStrutEnabled = [self isRightStrutEnabledForView:aFirstView];
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			BOOL anIsRightStrutEnabledForOtherView = [self isRightStrutEnabledForView:aView];
			if(anIsRightStrutEnabled != anIsRightStrutEnabledForOtherView)
			{
				aFoundMultipleValuesForEnabled = YES;
				break;
			}
		}
	}
	
	if(aFoundMultipleValuesForEnabled)
		aStateToReturn = KTLayoutControlStrutState_Mixed;
	else if(anIsRightStrutEnabled)
		aStateToReturn = KTLayoutControlStrutState_Fixed;
	else
		aStateToReturn = KTLayoutControlStrutState_Flexible;
		
	return aStateToReturn;
}



//=========================================================== 
// - isRightStrutEnabledForView:
//=========================================================== 
- (BOOL)isRightStrutEnabledForView:(id<KTViewLayout>)theView
{
	BOOL aReturnValue = NO;
	KTLayoutManager * aLayoutManger = [theView viewLayoutManager];
	if(		[aLayoutManger widthType] == KTSizeFill
		||	[aLayoutManger horizontalPositionType] == KTHorizontalPositionStickRight)
		aReturnValue = YES;

	return aReturnValue;
}


//=========================================================== 
// - leftStrutState
//=========================================================== 
- (KTLayoutControlStrutState)leftStrutState
{
	KTLayoutControlStrutState aStateToReturn;
	NSArray * anInspectedViewArray = nil;
	if([wDelegate respondsToSelector:@selector(inspectedObjects)])
		anInspectedViewArray = [wDelegate inspectedObjects];
	
	BOOL aFoundMultipleValuesForEnabled = NO;
	BOOL anIsLeftStrutStateEnabled;
	
	if([anInspectedViewArray count] > 0)
	{
		id <KTViewLayout> aFirstView = [anInspectedViewArray objectAtIndex:0];
		anIsLeftStrutStateEnabled = [self isLeftStrutEnabledForView:aFirstView];
		for(id<KTViewLayout> aView in anInspectedViewArray)
		{
			BOOL anIsLeftStrutEnabledForOtherView = [self isLeftStrutEnabledForView:aView];
			if(anIsLeftStrutStateEnabled != anIsLeftStrutEnabledForOtherView)
			{
				aFoundMultipleValuesForEnabled = YES;
				break;
			}
		}
	}
	
	if(aFoundMultipleValuesForEnabled)
		aStateToReturn = KTLayoutControlStrutState_Mixed;
	else if(anIsLeftStrutStateEnabled)
		aStateToReturn = KTLayoutControlStrutState_Fixed;
	else
		aStateToReturn = KTLayoutControlStrutState_Flexible;
		
	return aStateToReturn;
}


//=========================================================== 
// - isLeftStrutEnabledForView
//=========================================================== 
- (BOOL)isLeftStrutEnabledForView:(id<KTViewLayout>)theView
{
	BOOL aReturnValue = NO;
	KTLayoutManager * aLayoutManger = [theView viewLayoutManager];
	if(		[aLayoutManger widthType] == KTSizeFill
		||	[aLayoutManger horizontalPositionType] == KTHorizontalPositionStickLeft
		||	(	[aLayoutManger horizontalPositionType] == KTHorizontalPositionAbsolute
			&&	[aLayoutManger widthType] != KTSizeFill) )
		aReturnValue = YES;
		
	return aReturnValue;
}

#pragma mark -
#pragma mark Layout
//=========================================================== 
// - setUpRects
//=========================================================== 
- (void)setUpRects
{
	// right...this is unreadable, will rewrite...
	CGFloat aMarginLongSize;
	
	mCenterRect = NSMakeRect([self bounds].size.width*.5-kCenterRectSize*.5+.5, 
							 [self bounds].size.height*.5-kCenterRectSize*.5+.5, 
							 kCenterRectSize, 
							 kCenterRectSize);
							 
	aMarginLongSize = ([self bounds].size.height - kCenterRectSize)/2.0;
	
	mTopMarginRect = NSMakeRect([self bounds].size.width*.5-kStrutMarkerSize*.5+.5,
								mCenterRect.origin.y+mCenterRect.size.height+2,
								kStrutMarkerSize,
								aMarginLongSize-5);
								
	mBottomMarginRect = NSMakeRect(mTopMarginRect.origin.x, 
								   2.5, 
								   mTopMarginRect.size.width, 
								   mTopMarginRect.size.height+1);
								   
	aMarginLongSize = ([self bounds].size.width - kCenterRectSize)/2.0;
	
	mLeftMarginRect = NSMakeRect(2.5, 
								 mCenterRect.origin.y+mCenterRect.size.height*.5-kStrutMarkerSize*.5, 
								 aMarginLongSize-4, 
								 kStrutMarkerSize);
								 
	mRightMarginRect = NSMakeRect(mCenterRect.origin.x+mCenterRect.size.width+2, 
								  mLeftMarginRect.origin.y, 
								  mLeftMarginRect.size.width-1, 
								  mLeftMarginRect.size.height);
								  
	mCenterHorizontalRect = NSMakeRect(mCenterRect.origin.x+mCenterRect.size.width*.5-15, 
									   mCenterRect.origin.y+mCenterRect.size.width*.5, 
									   30, 
									   1);
									   
	mCenterVerticalRect = NSMakeRect(mCenterRect.origin.x+mCenterRect.size.width*.5, 
									 mCenterRect.origin.y+mCenterRect.size.height*.5-15, 
									 1, 
									 30);

	if(wRightMarginTextField==nil)
	{
		wRightMarginTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(mRightMarginRect.origin.x, mRightMarginRect.origin.y+mRightMarginRect.size.height, mRightMarginRect.size.width, 16)];
		[wRightMarginTextField setAlignment:NSCenterTextAlignment];
		[wRightMarginTextField setBordered:NO];
		[wRightMarginTextField setBezeled:NO];
		[wRightMarginTextField setDrawsBackground:NO];
		[wRightMarginTextField setTarget:self];
		[wRightMarginTextField setAction:@selector(setRightMargin:)];
		[wRightMarginTextField setEditable:YES];
		[wRightMarginTextField setSelectable:YES];
		[wRightMarginTextField setDelegate:self];
		[self addSubview:wRightMarginTextField];
		[wRightMarginTextField release];
	}
	if(wBottomMarginTextField==nil)
	{
		wBottomMarginTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(mBottomMarginRect.origin.x+mBottomMarginRect.size.width+.5, mBottomMarginRect.origin.y+mBottomMarginRect.size.height*.5-8, 60, 16)];
		[wBottomMarginTextField setAlignment:NSLeftTextAlignment];
		[wBottomMarginTextField setBordered:NO];
		[wBottomMarginTextField setBezeled:NO];
		[wBottomMarginTextField setDrawsBackground:NO];
		[wBottomMarginTextField setEditable:YES];
		[wBottomMarginTextField setSelectable:YES];
		[wBottomMarginTextField setTarget:self];
		[wBottomMarginTextField setAction:@selector(setBottomMargin:)];
		[wBottomMarginTextField setDelegate:self];
		[self addSubview:wBottomMarginTextField];
		[wBottomMarginTextField release];
	}
	if(wTopMarginTextField==nil)
	{
		wTopMarginTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(mTopMarginRect.origin.x+mTopMarginRect.size.width+.5, mTopMarginRect.origin.y+mTopMarginRect.size.height*.5-8, 60, 16)];
		[wTopMarginTextField setFormatter:[[[NSNumberFormatter alloc] init] autorelease]];
		[wTopMarginTextField setAlignment:NSLeftTextAlignment];
		[wTopMarginTextField setBordered:NO];
		[wTopMarginTextField setBezeled:NO];
		[wTopMarginTextField setDrawsBackground:NO];
		[wTopMarginTextField setTarget:self];
		[wTopMarginTextField setAction:@selector(setTopMargin:)];
		[wTopMarginTextField setEditable:YES];
		[wTopMarginTextField setSelectable:YES];
		[wTopMarginTextField setDelegate:self];
		[self addSubview:wTopMarginTextField];
		[wTopMarginTextField release];
	}
	if(wLeftMarginTextField==nil)
	{
		wLeftMarginTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(mLeftMarginRect.origin.x, mLeftMarginRect.origin.y+mLeftMarginRect.size.height, mLeftMarginRect.size.width, 16)];
		[wLeftMarginTextField setAlignment:NSCenterTextAlignment];
		[wLeftMarginTextField setBordered:NO];
		[wLeftMarginTextField setBezeled:NO];
		[wLeftMarginTextField setDrawsBackground:NO];
		[wLeftMarginTextField setEditable:YES];
		[wLeftMarginTextField setSelectable:YES];
		[wLeftMarginTextField setTarget:self];
		[wLeftMarginTextField setAction:@selector(setLeftMargin:)];
		[wLeftMarginTextField setDelegate:self];
		[self addSubview:wLeftMarginTextField];
		[wLeftMarginTextField release];
	}	
}



#pragma mark -
#pragma mark NSTextField Delegate Methods
//=========================================================== 
// - control:textview:doCommandBySelector:
//=========================================================== 
- (BOOL)control:(NSControl*)theControl textView:(NSTextView*)theTextView doCommandBySelector:(SEL)theCommandSelector
{
    BOOL aResult = NO;
	
	if (theCommandSelector == @selector(insertTab:))
    {
        if(		theControl == wTopMarginTextField
			||	theControl == wRightMarginTextField
			||	theControl == wLeftMarginTextField
			||	theControl == wBottomMarginTextField)
		{
			[theControl sendAction:[theControl action] to:[theControl target]];
			[[self window] makeFirstResponder:[theControl nextValidKeyView]];
		}
		aResult = YES;
    }
    return aResult;
}


//=========================================================== 
// - controlTextDidEndEditing:
//=========================================================== 
- (void)controlTextDidEndEditing:(NSNotification *)theNotification
{
	id aControl = [theNotification object];
	if(		aControl == wTopMarginTextField
		||	aControl == wRightMarginTextField
		||	aControl == wLeftMarginTextField
		||	aControl == wBottomMarginTextField)
	{
		[aControl sendAction:[aControl action] to:[aControl target]];
	}
	[[self window] makeFirstResponder:self];
}


@end
