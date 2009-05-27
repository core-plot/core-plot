//
//  BWAnchoredButton.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWAnchoredButton.h"
#import "BWAnchoredButtonBar.h"
#import "NSView+BWAdditions.h"

@implementation BWAnchoredButton

@synthesize isAtLeftEdgeOfBar;
@synthesize isAtRightEdgeOfBar;

+ (Class)cellClass
{
	return [BWAnchoredButtonCell class];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	// Fail gracefully on non-keyed coders
	if (![decoder isKindOfClass:[NSKeyedUnarchiver class]])
		return [super initWithCoder:decoder];
	
	NSKeyedUnarchiver *coder = (NSKeyedUnarchiver *)decoder;
	Class oldClass = [[self superclass] cellClass];
	Class newClass = [[self class] cellClass];
	
	[coder setClass:newClass forClassName:NSStringFromClass(oldClass)];
	self = [super initWithCoder:coder];
	
	if ([BWAnchoredButtonBar wasBorderedBar])
		topAndLeftInset = NSMakePoint(0, 0);
	else
		topAndLeftInset = NSMakePoint(1, 1);
	
	[coder setClass:oldClass forClassName:NSStringFromClass(oldClass)];
	
	return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self bringToFront];
	[super mouseDown:theEvent];
}

- (NSRect)frame
{
	NSRect frame = [super frame];
	frame.size.height = 24;
	return frame;
}

@end
