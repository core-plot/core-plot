//
//  KTViewIntegration.m
//  KTUIKit
//
//  Created by Cathy Shive on 5/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

// Import your framework view and your inspector 
 #import <KTUIKit/KTView.h>
 #import "KTLayoutManagerInspector.h"
// #import "KTViewInspector.h"
 #import "KTStyleInspector.h"
 #import "KTGradientPicker.h"
 #import "KTSplitView.h"
 #import "KTSplitViewDivider.h"
 #import "KTSplitViewInspector.h"
 


@implementation KTView ( KTViewIntegration )
//=========================================================== 
// - ibPopulateKeyPaths:
//=========================================================== 
- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths 
{
    [super ibPopulateKeyPaths:keyPaths];
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

//=========================================================== 
// - ibPopulateAttributeInspectorClasses:
//=========================================================== 
- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes 
{
    [super ibPopulateAttributeInspectorClasses:classes];
	// style inspector
	if(		[self isKindOfClass:[KTGradientPicker class]] == NO
		&&	[self isKindOfClass:[KTSplitView class]] == NO
		&&	[[self parent] isKindOfClass:[KTSplitView class]] == NO)
		[classes addObject:[KTStyleInspector class]];
		
	// layout inspector	
	if(		[self isKindOfClass:[KTSplitViewDivider class]] == NO
		&&	[[self parent] isKindOfClass:[KTSplitView class]] == NO)
		[classes addObject:[KTLayoutManagerInspector class]];
		
	if([[self parent] isKindOfClass:[KTSplitView class]])
	{
		[classes removeAllObjects];
//		[classes addObject:[KTSplitViewInspector class]];
	}
}

//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(CGContextRef)theContext
{
	NSWindow * aWindow = [self window];
	if(self == [aWindow contentView]
		&& (	[[self styleManager] backgroundColor] == [NSColor clearColor] 
			&&	[[self styleManager] backgroundGradient] == nil))
	{
		NSRect aViewBounds = [self bounds];
		[[NSColor colorWithCalibratedWhite:.9 alpha:1] set];
		NSRectFill(aViewBounds);
//		CGFloat aCheckerSize = 50;
//		NSInteger aNumCols = ceil(aViewBounds.size.width / aCheckerSize);
//		NSInteger aNumRows = ceil(aViewBounds.size.height / aCheckerSize);
//		NSInteger i, j;
//		NSPoint aMovingOrigin = NSMakePoint(0, 0);//aViewBounds.size.height-aCheckerSize);
//		for(i = 0; i < aNumCols; i++)
//		{
//			for(j = 0; j < aNumRows; j++)
//			{
//				NSColor * aCheckerColor = nil;
//				if(j % 2 == 0 && i % 2 == 0)
//					aCheckerColor = [NSColor colorWithCalibratedWhite:.95 alpha:1];
//				else if( j % 2 == 1 && i % 2 == 1)
//					aCheckerColor = [NSColor colorWithCalibratedWhite:.95 alpha:1];
//				else
//					aCheckerColor = [NSColor colorWithCalibratedWhite:1 alpha:1];
//				
//				NSRect aCheckerRect;
//				aCheckerRect.origin = aMovingOrigin;
//				aCheckerRect.size = NSMakeSize(aCheckerSize, aCheckerSize);
//				[aCheckerColor set];
//				NSRectFill(aCheckerRect);
//				aMovingOrigin.y+=aCheckerSize;
//			}
//			aMovingOrigin.y = 0;//aViewBounds.size.height-aCheckerSize;
//			aMovingOrigin.x+=aCheckerSize;
//		}
	
	}
	else if([[self styleManager] backgroundColor] == [NSColor clearColor] 
		&&	[[self styleManager] backgroundGradient] == nil)
	{
		[[NSColor colorWithDeviceRed:103.0/255.0 green:154.0/255.0 blue:255.0/255.0 alpha:.2] set];
		[NSBezierPath fillRect:[self bounds]];
//		NSRect aFirstViewRect = NSInsetRect([self bounds], 1.5, 1.5);
//		[[NSColor colorWithCalibratedWhite:1 alpha:1] set];
//		[NSBezierPath strokeRect:aFirstViewRect];
	}
}

//=========================================================== 
// - ibDesignableContentView
//=========================================================== 
- (NSView*)ibDesignableContentView
{
	return self;
}
//
- (IBInset)ibLayoutInset
{
	IBInset anInsetToReturn;
	anInsetToReturn.top = 0;
	anInsetToReturn.right = 0;
	anInsetToReturn.bottom = 0;
	anInsetToReturn.left = 0;
	if(		[[self parent] isKindOfClass:[KTSplitView class]]
		&&	[[NSApp currentEvent] type] == NSLeftMouseUp)
	{	
		anInsetToReturn.top = NSWidth([self frame])*.5;
		anInsetToReturn.right = NSWidth([self frame])*.5;
		anInsetToReturn.bottom = NSWidth([self frame])*.5;
		anInsetToReturn.left = NSWidth([self frame])*.5;
	}
	return anInsetToReturn;
}
//
//- (BOOL)ibIsChildInitiallySelectable:(id)theChild
//{
//	if([[self parent] isKindOfClass:[KTSplitView class]])
//	{
//		return YES;
//	}
//	return NO;
//}

@end



