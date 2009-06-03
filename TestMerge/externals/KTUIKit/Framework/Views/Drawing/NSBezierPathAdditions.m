//
//  NSBezierPathCategory.m
//
//  Created by Cathy Shive on 12/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSBezierPathAdditions.h"

@implementation NSBezierPath (RoundRect)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    NSBezierPath *result = [NSBezierPath bezierPath];
    [result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
    return result;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    if (!NSIsEmptyRect(rect)) {
  if (radius > 0.0) {
      // Clamp radius to be no larger than half the rect's width or height.
      float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width, rect.size.height));

      NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
      NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
      NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));

      [self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
      [self appendBezierPathWithArcFromPoint:topLeft     toPoint:rect.origin radius:clampedRadius];
      [self appendBezierPathWithArcFromPoint:rect.origin toPoint:bottomRight radius:clampedRadius];
      [self appendBezierPathWithArcFromPoint:bottomRight toPoint:topRight    radius:clampedRadius];
      [self appendBezierPathWithArcFromPoint:topRight    toPoint:topLeft     radius:clampedRadius];
      [self closePath];
  } else {
      // When radius == 0.0, this degenerates to the simple case of a plain rectangle.
      [self appendBezierPathWithRect:rect];
  }
    }
}


+ (NSBezierPath *)bezierPathWithLeftRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	NSBezierPath * aBezierPathToReturn = [NSBezierPath bezierPath];
    [aBezierPathToReturn appendBezierPathWithLeftRoundedRect:theRect cornerRadius:theCornerRadius];
    return aBezierPathToReturn;
}

- (void)appendBezierPathWithLeftRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	if (!NSIsEmptyRect(theRect)) 
	{
		if (theCornerRadius > 0.0) 
		{
			float	aClampedRadius = MIN(theCornerRadius, 0.5*MIN(theRect.size.width, theRect.size.height));
			NSPoint	aTopLeftPoint = NSMakePoint(NSMinX(theRect), NSMaxY(theRect));
			NSPoint aTopRightPoint = NSMakePoint(NSMaxX(theRect), NSMaxY(theRect));
			NSPoint aBottomRightPoint = NSMakePoint(NSMaxX(theRect), NSMinY(theRect));
			
			// start at the top middle
			[self moveToPoint:NSMakePoint(NSMidX(theRect), NSMaxY(theRect))];
			[self appendBezierPathWithArcFromPoint:aTopLeftPoint	toPoint:theRect.origin	radius:aClampedRadius];
			[self appendBezierPathWithArcFromPoint:theRect.origin	toPoint:aBottomRightPoint	radius:aClampedRadius];
			// now connect the last line

			[self lineToPoint:aBottomRightPoint];
			[self lineToPoint:aTopRightPoint];
			[self closePath];
		}
		else
			[self appendBezierPathWithRect:theRect];
	}
}

+ (NSBezierPath *)bezierPathWithRightRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	NSBezierPath * aBezierPathToReturn = [NSBezierPath bezierPath];
    [aBezierPathToReturn appendBezierPathWithRightRoundedRect:theRect cornerRadius:theCornerRadius];
    return aBezierPathToReturn;

}
- (void)appendBezierPathWithRightRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	if (!NSIsEmptyRect(theRect)) 
	{
		if (theCornerRadius > 0.0) 
		{
			float	aClampedRadius = MIN(theCornerRadius, 0.5*MIN(theRect.size.width, theRect.size.height));
			NSPoint	aTopLeftPoint = NSMakePoint(NSMinX(theRect), NSMaxY(theRect));
			NSPoint aTopRightPoint = NSMakePoint(NSMaxX(theRect), NSMaxY(theRect));
			NSPoint aBottomRightPoint = NSMakePoint(NSMaxX(theRect), NSMinY(theRect));
			
			// start at the top middle
			[self moveToPoint:NSMakePoint(NSMidX(theRect), NSMaxY(theRect))];
			[self appendBezierPathWithArcFromPoint:aTopRightPoint	toPoint:aBottomRightPoint	radius:aClampedRadius];
			[self appendBezierPathWithArcFromPoint:aBottomRightPoint	toPoint:theRect.origin	radius:aClampedRadius];
			// now connect the last line

			[self lineToPoint:theRect.origin];
			[self lineToPoint:aTopLeftPoint];
			[self closePath];
		}
		else
			[self appendBezierPathWithRect:theRect];
	}
}

+ (NSBezierPath *)bezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	NSBezierPath * aBezierPathToReturn = [NSBezierPath bezierPath];
	[aBezierPathToReturn appendBezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius];
	return aBezierPathToReturn;
}

- (void)appendBezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	if (!NSIsEmptyRect(theRect)) 
	{
		if (theCornerRadius > 0.0) 
		{
			float	aClampedRadius = MIN(theCornerRadius, 0.5*MIN(theRect.size.width, theRect.size.height));
			NSPoint	aTopLeftPoint = NSMakePoint(NSMinX(theRect), NSMaxY(theRect));
			NSPoint aTopRightPoint = NSMakePoint(NSMaxX(theRect), NSMaxY(theRect));
			NSPoint aBottomRightPoint = NSMakePoint(NSMaxX(theRect), NSMinY(theRect));
			
			// start at the bottom left
			[self moveToPoint:theRect.origin];
			[self appendBezierPathWithArcFromPoint:aTopLeftPoint	toPoint:aTopRightPoint	radius:aClampedRadius];
			[self appendBezierPathWithArcFromPoint:aTopRightPoint	toPoint:aBottomRightPoint	radius:aClampedRadius];

			[self lineToPoint:aBottomRightPoint];
			[self lineToPoint:theRect.origin];
			[self closePath];
		}
		else
			[self appendBezierPathWithRect:theRect];
	}
}

+ (NSBezierPath *)bezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	NSBezierPath * aBezierPathToReturn = [NSBezierPath bezierPath];
	[aBezierPathToReturn appendBezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius];
	return aBezierPathToReturn;
}

- (void)appendBezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius
{
	if (!NSIsEmptyRect(theRect)) 
	{
		if (theCornerRadius > 0.0) 
		{
			float	aClampedRadius = MIN(theCornerRadius, 0.5*MIN(theRect.size.width, theRect.size.height));
			NSPoint	aTopLeftPoint = NSMakePoint(NSMinX(theRect), NSMaxY(theRect));
			NSPoint aTopRightPoint = NSMakePoint(NSMaxX(theRect), NSMaxY(theRect));
			NSPoint aBottomRightPoint = NSMakePoint(NSMaxX(theRect), NSMinY(theRect));
			
			// start at the top right
			[self moveToPoint:aTopRightPoint];
			[self appendBezierPathWithArcFromPoint:aBottomRightPoint	toPoint:theRect.origin	radius:aClampedRadius];
			[self appendBezierPathWithArcFromPoint:theRect.origin	toPoint:aTopLeftPoint	radius:aClampedRadius];
			// now connect the last line

			[self lineToPoint:aTopLeftPoint];
			[self lineToPoint:aTopRightPoint];
			[self closePath];
		}
		else
			[self appendBezierPathWithRect:theRect];
	}
}


@end