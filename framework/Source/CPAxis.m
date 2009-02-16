

#import "CPAxis.h"


@implementation CPAxis

@synthesize plotSpace;
@synthesize majorTickLocations;
@synthesize minorTickLocations;
@synthesize minorTickLength;
@synthesize majorTickLength;

-(void)dealloc {
    self.plotSpace = nil;
    self.majorTickLocations = nil;
    self.minorTickLocations = nil;
    [super dealloc];
}

// The following was originally in CPPlotSpace. It should be adapted for here:
//
//
//-(void)renderAsVectorInContext:(CGContextRef)theContext
//{
//	// Temporary storage for the viewPointForPlotPoint call
//	NSMutableArray *plotPoint = [NSMutableArray array];
//	CGPoint viewPoint;
//	
//	// Cache the range limits
//	NSDecimalNumber *xLowerRange = [NSDecimalNumber decimalNumberWithDecimal:xRange.location];
//	NSDecimalNumber *xUpperRange = [xLowerRange decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:xRange.length] withBehavior:NSRoundPlain];
//	NSDecimalNumber *yLowerRange = [NSDecimalNumber decimalNumberWithDecimal:yRange.location];
//	NSDecimalNumber *yUpperRange = [yLowerRange decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:yRange.length] withBehavior:NSRoundPlain];
//    
//	// One path to hold the tickLines
//	CGMutablePathRef tickLine = CGPathCreateMutable();
//    
//	// Make the tick line path
//	for (NSDecimalNumber *tick in XMajorTickLocations)
//	{
//		[plotPoint insertObject:tick atIndex:0];
//		[plotPoint insertObject:yLowerRange atIndex:1];
//		viewPoint = [self viewPointForPlotPoint:plotPoint];
//		CGPathMoveToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
//		[plotPoint replaceObjectAtIndex:1 withObject:yUpperRange];
//		viewPoint = [self viewPointForPlotPoint:plotPoint];
//		CGPathAddLineToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
//		[plotPoint removeAllObjects];
//	}
//	
//	for (NSDecimalNumber* tick in YMajorTickLocations)
//	{
//		[plotPoint insertObject:xLowerRange atIndex:0];
//		[plotPoint insertObject:tick atIndex:1];
//		viewPoint = [self viewPointForPlotPoint:plotPoint];
//		CGPathMoveToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
//        
//		[plotPoint replaceObjectAtIndex:0 withObject:xUpperRange];
//		viewPoint = [self viewPointForPlotPoint:plotPoint];
//		CGPathAddLineToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
//		[plotPoint removeAllObjects];
//	}
//	
//	// Draw the tick line
//	CGContextBeginPath(theContext);
//	CGContextAddPath(theContext, tickLine);
//	[self.majorTickLineStyle setLineStyleInContext:theContext];
//    CGContextStrokePath(theContext);
//    
//	CGPathRelease(tickLine);
//}

@end
