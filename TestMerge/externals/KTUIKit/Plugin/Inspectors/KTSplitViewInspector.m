//
//  KTSplitViewInspector.m
//  KTUIKit
//
//  Created by Cathy on 15/05/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSplitViewInspector.h"
#import <KTUIKit/KTUIKit.h>

@interface KTSplitViewInspector (Private)
- (KTSplitView*)inspectedSplitView;
@end

@implementation KTSplitViewInspector

- (NSString *)viewNibName 
{
    return @"KTSplitViewInspector";
}

+ (BOOL)supportsMultipleObjectInspection
{
	return NO;
}

- (void)refresh 
{
	KTSplitView * anInspectedSplitView = [self inspectedSplitView];
	[oDividerThicknessTextField setIntValue:[anInspectedSplitView dividerThickness]];
	[oOrientationPopUpButton selectItemWithTag:[anInspectedSplitView dividerOrientation]];
	[oResizeBehaviorPopUpButton selectItemWithTag:[anInspectedSplitView resizeBehavior]];
	
//	[oBackgroundColorWell setColor:[anInspectedSplitView fillColor]];
	[super refresh];
}

- (IBAction)setOrientation:(id)theSender
{
	[[self inspectedSplitView] setDividerOrientation:[[theSender selectedItem] tag]];
}

- (IBAction)setDividerThickness:(id)theSender
{
	[[self inspectedSplitView] setDividerThickness:[theSender floatValue]];
}

- (IBAction)setDividerBackgroundColor:(id)theSender
{
	[[self inspectedSplitView] setDividerFillColor:[oBackgroundColorWell color]];
}

- (IBAction)setDividerFirstBorderColor:(id)theSender
{
	[[self inspectedSplitView] setDividerFirstStrokeColor:[oFirstStrokeColorWell color] secondColor:[oSecondStrokeColorWell color]];
}

- (IBAction)setDividerSecondBorderColor:(id)theSender
{
	[[self inspectedSplitView] setDividerFirstStrokeColor:[oFirstStrokeColorWell color] secondColor:[oSecondStrokeColorWell color]];
}

- (IBAction)setResizeBehavior:(id)theSender
{
	[[self inspectedSplitView] setResizeBehavior:[[theSender selectedItem] tag]];	
}

- (KTSplitView*)inspectedSplitView
{
	KTSplitView * aSplitViewToReturn = nil;
	if([[self inspectedObjects] count] > 0)
	{
		id anInspectedView = [[self inspectedObjects] objectAtIndex:0];
		if([anInspectedView isKindOfClass:[KTSplitView class]])
			aSplitViewToReturn = anInspectedView;
//		else if([[anInspectedView superview] isKindOfClass:[KTSplitView class]])
//			aSplitViewToReturn = (KTSplitView*)[anInspectedView superview];
	}
	return aSplitViewToReturn;
}

@end
