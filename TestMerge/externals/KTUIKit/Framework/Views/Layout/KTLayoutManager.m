//
//  KTLayoutManager.m
//  KTUIKit
//
//  Created by Cathy Shive on 05/20/2008.
//
// Copyright (c) Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "KTUIKit" by Cathy Shive" will do.

#import "KTLayoutManager.h"

#define kKTLayoutManagerShouldDoLayoutKey @"shouldDoLayout"
#define kKTLayoutManagerWidthTypeKey @"widthType"
#define kKTLayoutManagerHeightTypeKey @"heightType"
#define kKTLayoutManagerHorizontalPositionTypeKey @"horizontalPositionType"
#define kKTLayoutManagerVerticalPositionTypeKey @"verticalPositionType"
#define kKTLayoutManagerMarginTopKey @"marginTop"
#define kKTLayoutManagerMarginRightKey @"marginRight"
#define kKTLayoutManagerMarginBottomKey @"marginBottom"
#define kKTLayoutManagerMarginLeftKey @"marginLeft"
#define kKTLayoutManagerWidthPercentageKey @"widthPercentage"
#define kKTLayoutManagerHeightPercentageKey @"heightPercentage"
#define kKTLayoutManagerHorizontalPercentageKey @"horizontalPositionPercentage"
#define kKTLayoutManagerVerticalPercentageKey @"verticalPositionPercentage"
#define kKTLayoutManagerMinWidthKey @"minWidth"
#define kKTLayoutManagerMaxWidthKey @"maxWidth"
#define kKTLayoutManagerMinHeightKey @"minHeight"
#define kKTLayoutManagerMaxHeightKey @"maxHeight"

@interface KTLayoutManager (Private)
- (NSArray*)keysForCoding;
@end

@implementation KTLayoutManager
@synthesize shouldDoLayout = mShouldDoLayout;
@synthesize widthType = mWidthType;
@synthesize heightType = mHeightType;
@synthesize horizontalPositionType = mHorizontalPositionType;
@synthesize verticalPositionType = mVerticalPositionType;
@synthesize marginTop = mMarginTop;
@synthesize marginRight = mMarginRight;
@synthesize marginBottom = mMarginBottom;
@synthesize marginLeft = mMarginLeft;
@synthesize widthPercentage = mWidthPercentage;
@synthesize heightPercentage = mHeightPercentage;
@synthesize horizontalPositionPercentage = mHorizontalPositionPercentage;
@synthesize verticalPositionPercentage = mVerticalPositionPercentage;
@synthesize minWidth = mMinWidth;
@synthesize maxWidth = mMaxWidth;
@synthesize minHeight = mMinHeight;
@synthesize maxHeight = mMaxHeight;
@synthesize view = wView;

//=========================================================== 
// - init
//=========================================================== 
- (id)init
{
	return [self initWithView:nil];
}

//=========================================================== 
// - initWithView:
//=========================================================== 
- (id)initWithView:(id<KTViewLayout>)theView
{
	if(![super init])
		return nil;
	wView = theView;
	mWidthPercentage = mHeightPercentage = 1.0;
	mShouldDoLayout = YES;
	return self;
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if ([[self superclass] instancesRespondToSelector:@selector(initWithCoder:)]) 
	{
		if (![(id)super initWithCoder:theCoder])
			return nil;
	}
	
	for (NSString * aKey in [self keysForCoding])
		[self setValue:[theCoder decodeObjectForKey:aKey] forKey:aKey];
	mShouldDoLayout = YES;	
	
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{
	if ([[self superclass] instancesRespondToSelector:@selector(encodeWithCoder:)])
		[(id)super encodeWithCoder:theCoder];
		
	for (NSString * aKey in [self keysForCoding])
		[theCoder encodeObject:[self valueForKey:aKey] forKey:aKey];
}

//=========================================================== 
// - keysForCoding
//=========================================================== 
- (NSArray *)keysForCoding
{
	return [NSArray arrayWithObjects:kKTLayoutManagerWidthTypeKey,
									 kKTLayoutManagerHeightTypeKey,
									 kKTLayoutManagerHorizontalPositionTypeKey,
									 kKTLayoutManagerVerticalPositionTypeKey,
									 kKTLayoutManagerMarginTopKey,
									 kKTLayoutManagerMarginRightKey,
									 kKTLayoutManagerMarginBottomKey,
									 kKTLayoutManagerMarginLeftKey,
									 kKTLayoutManagerWidthPercentageKey,
									 kKTLayoutManagerHeightPercentageKey,
									 kKTLayoutManagerHorizontalPercentageKey, 
									 kKTLayoutManagerVerticalPercentageKey, 
									 kKTLayoutManagerMinWidthKey,
									 kKTLayoutManagerMaxWidthKey,
									 kKTLayoutManagerMinHeightKey,
									 kKTLayoutManagerMaxHeightKey,
									 nil];
}

//=========================================================== 
// - setNilValueForKey:
//=========================================================== 
- (void)setNilValueForKey:(NSString *)theKey;
{
	if ([theKey isEqualToString:kKTLayoutManagerWidthTypeKey])
		[self setWidthType:KTSizeAbsolute];
	else if ([theKey isEqualToString:kKTLayoutManagerHeightTypeKey])
		[self setHeightType:KTSizeAbsolute];
	else if ([theKey isEqualToString:kKTLayoutManagerHorizontalPositionTypeKey])
		[self setHorizontalPositionType:KTHorizontalPositionAbsolute];
	else if ([theKey isEqualToString:kKTLayoutManagerVerticalPositionTypeKey])
		[self setVerticalPositionType:KTVerticalPositionAbsolute];
	else if ([theKey isEqualToString:kKTLayoutManagerMarginTopKey])
		[self setMarginTop:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMarginRightKey])
		[self setMarginRight:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMarginBottomKey])
		[self setMarginBottom:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMarginLeftKey])
		[self setMarginLeft:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerWidthPercentageKey])
		[self setWidthPercentage:1.0];
	else if ([theKey isEqualToString:kKTLayoutManagerHeightPercentageKey])
		[self setHeightPercentage:1.0];
	else if([theKey isEqualToString:kKTLayoutManagerHorizontalPercentageKey])
		[self setHorizontalPositionPercentage:0.0];
	else if([theKey isEqualToString:kKTLayoutManagerVerticalPercentageKey])
		[self setVerticalPositionPercentage:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMinWidthKey])
		[self setMinWidth:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMaxWidthKey])
		[self setMaxWidth:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMinHeightKey])
		[self setMinHeight:0.0];
	else if ([theKey isEqualToString:kKTLayoutManagerMaxHeightKey])
		[self setMaxHeight:0.0];
	else
		[super setNilValueForKey:theKey];
}



//=========================================================== 
// - setView:
//=========================================================== 
- (void)setView:(id<KTViewLayout>)theView
{
	wView = theView;
}

//=========================================================== 
// - refreshLayout
//=========================================================== 
- (void)refreshLayout
{

	NSRect aCurrentViewFrame = [wView frame];
	NSRect aSuperviewFrame = [[wView parent] frame];
	
	if(mShouldDoLayout == NO)
	{
		// This flag is only here so the views can be laid out in IB without any resizing
		// shouldn't call this from application code...I need to think of a better way to deal with
		// this situation strictly in IB plugin code
		aCurrentViewFrame.origin.y = NSHeight(aSuperviewFrame) - NSHeight(aCurrentViewFrame) - mMarginTop;
		[wView setFrame:aCurrentViewFrame];

		return;
	}
	
	
	//----------------------------------------------------------------------------------------
	// WIDTH
	//----------------------------------------------------------------------------------------
	switch(mWidthType)
	{
		case KTSizeFill:
			aCurrentViewFrame.size.width = NSWidth(aSuperviewFrame) - (mMarginLeft + mMarginRight);
		break;
		
		case KTSizePercentage:
			aCurrentViewFrame.size.width = NSWidth(aSuperviewFrame)*mWidthPercentage - (mMarginLeft + mMarginRight);
		break;
	}
	

	
	//----------------------------------------------------------------------------------------
	// HEIGHT
	//----------------------------------------------------------------------------------------
	switch(mHeightType)
	{
		case KTSizeFill:
			aCurrentViewFrame.size.height = aSuperviewFrame.size.height - (mMarginTop + mMarginBottom);
		break;
		
		case KTSizePercentage:
			aCurrentViewFrame.size.height = aSuperviewFrame.size.height*mHeightPercentage - (mMarginTop + mMarginBottom);
		break;
	}
	

	//----------------------------------------------------------------------------------------
	// HORIZONTAL POSITION
	//----------------------------------------------------------------------------------------
	switch(mHorizontalPositionType)
	{
		case KTHorizontalPositionAbsolute:
			if(		mMarginLeft > 0
				&&	NSMinX(aCurrentViewFrame) < mMarginLeft)
				aCurrentViewFrame.origin.x = mMarginLeft;
		break;
		
		case KTHorizontalPositionKeepCentered:
			aCurrentViewFrame.origin.x = floor(NSWidth(aSuperviewFrame)*.5) - floor(NSWidth(aCurrentViewFrame)*.5);
		break;
		
		case KTHorizontalPositionStickLeft:
			aCurrentViewFrame.origin.x = mMarginLeft;
		break;
		
		case KTHorizontalPositionStickRight:
			aCurrentViewFrame.origin.x = NSWidth(aSuperviewFrame) - NSWidth(aCurrentViewFrame) - mMarginRight;
		break;
		
		case KTHorizontalPositionProportional:
			aCurrentViewFrame.origin.x = (NSWidth(aSuperviewFrame)-NSWidth(aCurrentViewFrame))*mHorizontalPositionPercentage;
		break;
		
		case KTHorizontalPositionFloatRight:
		{
			// NOTE:
			// we're resizing and positioning sibling views in this part
			// a problem with this is that we're no longer considering the min/max sizes for the siblings
			// in the case that views are being floated and the views combine absolute and filling sizes
			// max/min sizes no longer make sense
			
			NSArray *	aSiblingList = [[wView parent] children];
			NSInteger	aCurrentViewIndex = [aSiblingList indexOfObject:wView];
			CGFloat		aWidthTakeByFixedWidthSiblings = 0;
			CGFloat		aCombinedMarginForFilledWidthSiblings = 0;
			NSInteger	aNumberOfSiblingsWithFilledWidth = 0;
			CGFloat		aWidthForFilledWidthSiblings = NSWidth(aSuperviewFrame);
			
			NSInteger i;
			for(i = 0; i <= aCurrentViewIndex; i++)
			{
				id aSibling = [aSiblingList objectAtIndex:i];
				
				// check if the sibling also floats right
				if(		[aSibling conformsToProtocol:@protocol(KTViewLayout)]
					&&	[[aSibling viewLayoutManager] horizontalPositionType] == KTHorizontalPositionFloatRight)
				{
					// does it have a fixed or filled width?
					if([[aSibling viewLayoutManager] widthType] == KTSizeFill)
					{
						// keep track of the number of siblings that are also filling width so we can distribute the left over width between them
						aNumberOfSiblingsWithFilledWidth++;
						// keep track of their margins so that we can subtract it from the left over width
						aCombinedMarginForFilledWidthSiblings+=[[aSibling viewLayoutManager] marginRight] + [[aSibling viewLayoutManager] marginLeft];
					}
					else // add up the fixed widths so that we can determine what's "left over"
						aWidthTakeByFixedWidthSiblings+=[aSibling frame].size.width + [[aSibling viewLayoutManager] marginRight] + [[aSibling viewLayoutManager] marginLeft];
				}
			}
			
			// distribute the "left over" width between the the siblings set to fill their widths
			if(aNumberOfSiblingsWithFilledWidth > 0)
			{
				CGFloat aLeftOverWidth = aSuperviewFrame.size.width - aWidthTakeByFixedWidthSiblings - aCombinedMarginForFilledWidthSiblings;
				aWidthForFilledWidthSiblings = aLeftOverWidth / aNumberOfSiblingsWithFilledWidth;
			}
			
			// resize and position each of the siblings
			
			// start at the far right of the superview
			CGFloat aCurrentXPosition = NSWidth(aSuperviewFrame);
			for(i = 0; i <=aCurrentViewIndex; i++)
			{
				id aSiblingToSizeAndPosition = [aSiblingList objectAtIndex:i];
				
				// we're only interested in other siblings that are also floating right
				if(		[aSiblingToSizeAndPosition conformsToProtocol:@protocol(KTViewLayout)]
					&&	[[aSiblingToSizeAndPosition viewLayoutManager] horizontalPositionType] == KTHorizontalPositionFloatRight)
				{
					NSRect aSiblingFrame;
					
					// we won't set the current view's frame right away
					if(i!=aCurrentViewIndex)
						aSiblingFrame = [aSiblingToSizeAndPosition frame];
					else
						aSiblingFrame = aCurrentViewFrame;
						
					if([[aSiblingToSizeAndPosition viewLayoutManager] widthType] == KTSizeFill)
					{
						// if the sibling fills it's width, give it the value we calculated
						aSiblingFrame.size.width = aWidthForFilledWidthSiblings;
						aSiblingFrame.origin.x = aCurrentXPosition - [[aSiblingToSizeAndPosition viewLayoutManager] marginRight] - aWidthForFilledWidthSiblings - [[aSiblingToSizeAndPosition viewLayoutManager] marginLeft];
					}
					else
					{
						// if the width is fixed, just position it
						aSiblingFrame.origin.x = aCurrentXPosition - [[aSiblingToSizeAndPosition viewLayoutManager] marginRight] - aSiblingFrame.size.width - [[aSiblingToSizeAndPosition viewLayoutManager] marginLeft];
					}
					
					// move the x position for the next sibling
					aCurrentXPosition = aSiblingFrame.origin.x;
					
					// set sibling's frames - the current view will be set later
					if(i!=aCurrentViewIndex)
						[aSiblingToSizeAndPosition setFrame:aSiblingFrame];
					else
						aCurrentViewFrame = aSiblingFrame;
				}
			}
		}
		break;
		
		case KTHorizontalPositionFloatLeft:
		{
			// position ourself at the left of the superview
			aCurrentViewFrame.origin.x = mMarginLeft;
				
			NSArray * aSiblingList = [[wView parent] children];
			int		  aCurrentViewIndex = [aSiblingList indexOfObject:wView];
			
			// check if we have any sibling views ahead of us
			if(aCurrentViewIndex != 0)
			{
				// we're just interested in the view in the list before 
				// ours that is also floating up, we'll position ourself underneath it
				int i;
				for(i = aCurrentViewIndex-1; i >= 0; i--)
				{
					id aSibling = [aSiblingList objectAtIndex:i];
					if(		[aSibling conformsToProtocol:@protocol(KTViewLayout)]
						&&	[[aSibling viewLayoutManager] horizontalPositionType] == KTHorizontalPositionFloatLeft)
					{
						NSRect aSiblingFrame = [aSibling frame];
						if(		NSMinY(aCurrentViewFrame) <= NSMinY(aSiblingFrame) + NSHeight(aSiblingFrame)
							&&	NSMinY(aCurrentViewFrame) + NSHeight(aCurrentViewFrame) >= NSMinY(aSiblingFrame) )
						{
							aCurrentViewFrame.origin.x = NSMinX([aSibling frame]) + NSWidth([aSibling frame]) + [[aSibling viewLayoutManager] marginRight] + mMarginLeft;
							// if the width if being filled, we need to adjust it to account for our position change
							if(mWidthType == KTSizeFill)
								aCurrentViewFrame.size.width-=(NSMinX(aCurrentViewFrame) - mMarginLeft);
							break;
						}
					}
				}
			}
		}
		break;
		
		default:
		break;

	}
	
	//----------------------------------------------------------------------------------------
	// VERTICAL POSITION
	//----------------------------------------------------------------------------------------
	switch(mVerticalPositionType)
	{
		case KTHorizontalPositionAbsolute:
			if(		mMarginBottom > 0
				&&	NSMinY(aCurrentViewFrame) < mMarginBottom)
				aCurrentViewFrame.origin.y = mMarginBottom;
		break;
		
		case KTVerticalPositionKeepCentered:
			aCurrentViewFrame.origin.y = NSHeight(aSuperviewFrame)*.5 - NSHeight(aCurrentViewFrame)*.5 + .5;
		break;
		
		case KTVerticalPositionStickTop:
			aCurrentViewFrame.origin.y = NSHeight(aSuperviewFrame) - NSHeight(aCurrentViewFrame) - mMarginTop;
		break;
		
		case KTVerticalPositionStickBottom:
			aCurrentViewFrame.origin.y = mMarginBottom;
		break;
		
		case KTVerticalPositionProportional:
			aCurrentViewFrame.origin.y = (NSHeight(aSuperviewFrame)-NSHeight(aCurrentViewFrame))*mVerticalPositionPercentage;
		break;
		
		case KTVerticalPositionFloatUp:
		{
			// position ourself at the top of the superview
			aCurrentViewFrame.origin.y = NSHeight(aSuperviewFrame) - NSHeight(aCurrentViewFrame) - mMarginTop;
				
			NSArray * aSiblingList = [[wView parent] children];
			int		  aCurrentViewIndex = [aSiblingList indexOfObject:wView];
			
			// check if we have any sibling views ahead of us
			if(aCurrentViewIndex != 0)
			{
				// we're just interested in the view in the list before 
				// ours that is also floating up and positioned above us
				// we'll position ourself underneath it
				int i;
				for(i = aCurrentViewIndex-1; i >= 0; i--)
				{
					id aSibling = [aSiblingList objectAtIndex:i];
					if(		[aSibling conformsToProtocol:@protocol(KTViewLayout)]
						&&	[[aSibling viewLayoutManager] verticalPositionType] == KTVerticalPositionFloatUp)
					{
						NSRect aSiblingFrame = [aSibling frame];
						if(		NSMinX(aCurrentViewFrame)+NSWidth(aCurrentViewFrame) >= NSMinX(aSiblingFrame)
							&&	NSMinX(aCurrentViewFrame) <= NSMinX(aSiblingFrame)+NSWidth(aSiblingFrame) )
						{							
							// if the hieght if being filled, we need to adjust it to account for the sibling's position in the superview
							if(	mHeightType == KTSizeFill)
								aCurrentViewFrame.size.height-= NSHeight(aSuperviewFrame)-NSMinY(aSiblingFrame) -[[aSibling viewLayoutManager] marginBottom];
								
							aCurrentViewFrame.origin.y = NSMinY(aSiblingFrame) -[[aSibling viewLayoutManager] marginBottom] - NSHeight(aCurrentViewFrame) - mMarginTop;
							
							break;
						}
					}
				}
			}
		}
		break;
		
		case KTVerticalPositionFloatDown:
		{
			// position ourself at the bottom of the superview
			aCurrentViewFrame.origin.y = mMarginBottom;
				
			NSArray * aSiblingList = [[wView parent] children];
			int		  aCurrentViewIndex = [aSiblingList indexOfObject:wView];
			
			// check if we have any sibling views ahead of us
			if(aCurrentViewIndex != 0)
			{
				// we're just interested in the view in the list before 
				// ours that is also floating up and is positioned below us, we'll position ourself above it
				int i;
				for(i = aCurrentViewIndex-1; i >= 0; i--)
				{
					id aSibling = [aSiblingList objectAtIndex:i];
					if(		[aSibling conformsToProtocol:@protocol(KTViewLayout)]
						&&	[[aSibling viewLayoutManager] verticalPositionType] == KTVerticalPositionFloatDown)
					{
						NSRect aSiblingFrame = [aSibling frame];
						if(		NSMinX(aCurrentViewFrame) <= NSMinX(aSiblingFrame)+NSWidth(aSiblingFrame)
							&&	NSMinX(aCurrentViewFrame)+NSWidth(aCurrentViewFrame) >= NSMinX(aSiblingFrame) )
						{
							aCurrentViewFrame.origin.y = NSMinY([aSibling frame]) +  NSHeight([aSibling frame]) + mMarginBottom;
							// if the hieght if being filled, we need to adjust it to account for our position change
							if(	mHeightType == KTSizeFill)
								aCurrentViewFrame.size.height-=NSMinY(aCurrentViewFrame);
							break;
						}
					}
				}
			}
		}
		break;
		
		default:
		break;
	}
	
	
	
	// CS: with the new floating code, it is possible that the clipping here will
	// mess everything up - 
	
	
	// clip width
	if(mMaxWidth > 0)
	{
		if(NSWidth(aCurrentViewFrame) > mMaxWidth)
			aCurrentViewFrame.size.width = mMaxWidth;
	}
	if(mMinWidth > 0)
	{
		if(NSWidth(aCurrentViewFrame) < mMinWidth)
			aCurrentViewFrame.size.width = mMinWidth;
	}
	// clip height
	if(mMaxHeight > 0)
	{
		if(NSHeight(aCurrentViewFrame) > mMaxHeight)
			aCurrentViewFrame.size.height = mMaxHeight;
	}
	if(mMinHeight > 0)
	{
		if(NSHeight(aCurrentViewFrame) < mMinHeight)
			aCurrentViewFrame.size.height = mMinHeight;
	}
		
	
	//----------------------------------------------------------------------------------------
	// SET THE FRAME
	//----------------------------------------------------------------------------------------	
	[wView setFrame:aCurrentViewFrame];
}

#pragma mark -
#pragma mark EXTRA API FOR CONFIGURATION
//=========================================================== 
// - setMargin:
//=========================================================== 
- (void)setMargin:(float)theMargin
{
	mMarginTop = theMargin;
	mMarginRight = theMargin;
	mMarginBottom = theMargin;
	mMarginLeft = theMargin;
}

//=========================================================== 
// - setMarginTop:right:bottom:left:
//=========================================================== 
- (void)setMarginTop:(float)theTopMargin 
			   right:(float)theRightMargin 
			  bottom:(float)theBottomMargin 
				left:(float)theLeftMargin
{
	mMarginTop = theTopMargin;
	mMarginRight = theRightMargin;
	mMarginBottom = theBottomMargin;
	mMarginLeft = theLeftMargin;
}



@end
