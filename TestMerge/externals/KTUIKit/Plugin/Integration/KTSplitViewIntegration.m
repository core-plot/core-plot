//
//  KTSplitViewIntegration.m
//  KTUIKit
//
//  Created by Cathy on 13/05/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <KTUIKit/KTUIKit.h>
#import <KTUIKit/KTSplitViewDivider.h>
#import "KTSplitViewInspector.h"

//[[[[NSDocumentController sharedDocumentController] documents] lastObject] editorManager]
 
@implementation KTSplitView ( KTSplitViewIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)theKeyPaths 
{
	[super ibPopulateKeyPaths:theKeyPaths];
	NSArray * aKeyPathsToAdd = [NSArray arrayWithObjects:@"dividerOrientation", 
														 @"dividerThickness", 
														 @"resizeBehavior", 
														 nil];
    [[theKeyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:aKeyPathsToAdd];
}



- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)theClasses 
{
    [theClasses addObject:[KTSplitViewInspector class]];
    [super ibPopulateAttributeInspectorClasses:theClasses];
}

- (void)ibDidAddToDesignableDocument:(IBDocument *)theDocument
{
	[self setDividerOrientation:KTSplitViewDividerOrientation_Vertical];
	[self setDividerThickness:8];
	[self setDividerPosition:[self frame].size.width*.5 relativeToView:KTSplitViewFocusedViewFlag_FirstView];
	[[mFirstView styleManager] setBorderColor:[NSColor whiteColor]];
	[[mFirstView styleManager] setBorderWidth:1];
	[[mFirstView styleManager] setBackgroundColor:[NSColor colorWithCalibratedWhite:.8 alpha:1]];
	[[mSecondView styleManager] setBorderColor:[NSColor whiteColor]];
	[[mSecondView styleManager] setBorderWidth:1];
	[[mSecondView styleManager] setBackgroundColor:[NSColor colorWithCalibratedWhite:.8 alpha:1]];
	[super ibDidAddToDesignableDocument:theDocument];
}


- (NSView*)hitTest:(NSPoint)thePoint
{
	NSPoint aMousePoint = [self convertPoint:thePoint fromView:nil];
	// if there are any split views in our subviews, we'll let them handle the hittest
	id aViewToTest = nil;
	if(NSPointInRect(aMousePoint, [mFirstView frame]))
		aViewToTest = mFirstView;
	else if(NSPointInRect(aMousePoint, [mSecondView frame]))
		aViewToTest = mSecondView;
	
	if(aViewToTest)
	{
		if([[aViewToTest subviews] count] > 0)
		{
			if([[[aViewToTest subviews] objectAtIndex:0] isKindOfClass:[KTSplitView class]])
			{
				return [[[aViewToTest subviews] objectAtIndex:0] hitTest:thePoint];
			}
		}
	}

	// if we've made it to here, we can check our divider against the point
	id aTestResult =  [super hitTest:thePoint];	
	if(aTestResult == mDivider)
	{
		if([[NSApp currentEvent] type] == NSMouseMoved)
		{
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
				[[NSCursor resizeUpDownCursor] set];
			else
				[[NSCursor resizeLeftRightCursor] set];
		}	
		if([[NSApp currentEvent] type] == NSLeftMouseDown)
		{
			[mDivider mouseDown:[NSApp currentEvent]];
		}
	}
	else if(	aTestResult==mFirstView
			||	aTestResult==mSecondView)
		aTestResult = self;
	return aTestResult;
}

- (NSView*)ibDesignableContentView
{
	return nil;
}

- (BOOL)ibIsChildViewUserMovable:(NSView *)theChildView
{
	return NO;
}

- (BOOL)ibIsChildViewUserSizable:(NSView *)theChildView
{
	return NO;
}

- (BOOL)ibIsChildInitiallySelectable:(id)child
{
	return NO;
}

- (NSArray*)ibDefaultChildren
{
	return [NSArray arrayWithObjects:mFirstView, mSecondView, nil];
}

- (void)cursorUpdate:(NSEvent*)theEvent
{
	//NSLog(@"split view UPDATE CURSOR");
	if([mDivider isInDrag])
	{
//		if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
//			[[NSCursor resizeUpDownCursor] set];
//		else
//			[[NSCursor resizeLeftRightCursor] set];
	}
	else
		[super cursorUpdate:theEvent];
}

@end
