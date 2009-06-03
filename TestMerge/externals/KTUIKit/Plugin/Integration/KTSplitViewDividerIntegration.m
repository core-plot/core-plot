//
//  KTSplitViewDividerIntegration.m
//  KTUIKit
//
//  Created by Cathy on 14/05/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

// Import your framework view and your inspector 
// #import <MyFramework/MyView.h>
#import "KTSplitViewDivider.h"
#import "KTSplitView.h"

@implementation KTSplitViewDivider ( KTSplitViewDividerIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];

	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
	// Replace "KTSplitViewDividerIntegrationInspector" with the name of your inspector class.
//    [classes addObject:[KTSplitViewDividerIntegrationInspector class]];
}


- (void)drawInContext:(CGContextRef)theContext
{
	if([[self styleManager] backgroundColor] == [NSColor clearColor] 
		&&	[[self styleManager] backgroundGradient] == nil)
	{
		[[NSColor colorWithDeviceRed:103.0/255.0 green:154.0/255.0 blue:255.0/255.0 alpha:.2] set];
		[NSBezierPath fillRect:[self bounds]];
//		NSRect aFirstViewRect = NSInsetRect([self bounds], 1.5, 1.5);
//		[[NSColor colorWithCalibratedWhite:1 alpha:1] set];
//		[NSBezierPath strokeRect:aFirstViewRect];
	}
}

//
//- (NSView*)hitTest:(NSPoint)thePoint
//{
//	if(NSPointInRect([self convertPoint:thePoint fromView:nil], [self bounds]))
//	{
//		if([[NSApp currentEvent] type]==NSLeftMouseDown)
//			[self mouseDown:[NSApp currentEvent]];
//		return self;
//	}
//	else
//		return [super hitTest:thePoint];
//}
//

- (void) mouseDown:(NSEvent *)theEvent
{		


	
   NSEvent * aNextEvent = nil;
   while ((aNextEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSMouseMovedMask
												   untilDate:[NSDate distantFuture] 
													  inMode:NSDefaultRunLoopMode dequeue:YES]))
   {
       switch ([aNextEvent type])
       {
			case NSLeftMouseDragged:
			  [self mouseDragged:aNextEvent];
			break;
			
			case NSMouseMovedMask:
			break;
					   
			case NSLeftMouseUp:
				[self mouseUp:aNextEvent];
//				[[NSCursor arrowCursor] set];
			return;
			

			
			default:
			return;
       }
   }
}

@end
