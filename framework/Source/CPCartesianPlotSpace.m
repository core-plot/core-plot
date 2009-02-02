
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"

@implementation CPCartesianPlotSpace

@synthesize XRange, YRange;
@synthesize XMajorTickLocations, YMajorTickLocations;
@synthesize majorTickLineStyle;

#pragma mark init/dealloc

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setMajorTickLineStyle:[CPLineStyle defaultLineStyle]];

	}
	return self;
}

#pragma mark Point Conversion

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
{
	if ([decimalNumbers count] == 2)
	{
		NSDecimal boundsw = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.width exponent:0 isNegative:NO] decimalValue];
		NSDecimal boundsh = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.height exponent:0 isNegative:NO] decimalValue];

		
		NSDecimal x = [[decimalNumbers objectAtIndex:0] decimalValue];
		NSDecimalSubtract(&x, &x, &(XRange.location), NSRoundPlain);
		NSDecimalDivide(&x, &x, &(XRange.length), NSRoundPlain);
		NSDecimalMultiply(&x, &x, &boundsw, NSRoundPlain);
		NSDecimal y = [[decimalNumbers objectAtIndex:1] decimalValue];
		NSDecimalSubtract(&y, &y, &(YRange.location), NSRoundPlain);
		NSDecimalDivide(&y, &y, &(YRange.length), NSRoundPlain);
		NSDecimalMultiply(&y, &y, &boundsh, NSRoundPlain);
		
		return CGPointMake(NSDecimalFloatValue(x), NSDecimalFloatValue(y));
	}
	else {
        [NSException raise:CPDataException format:@"Wrong number of plot points supplied to viewPointForPlotPoint:"];
    }
    return CGPointMake(0.f, 0.f);
}

-(NSArray *)plotPointForViewPoint:(CGPoint)point
{
	NSDecimal pointx = [[[[NSDecimalNumber alloc] initWithFloat:point.x] autorelease] decimalValue];
	NSDecimal pointy = [[[[NSDecimalNumber alloc] initWithFloat:point.y] autorelease] decimalValue];
	NSDecimal boundsw = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.width exponent:0 isNegative:NO] decimalValue];
	NSDecimal boundsh = [[NSDecimalNumber decimalNumberWithMantissa:self.bounds.size.height exponent:0 isNegative:NO] decimalValue];

	NSDecimal x;
	NSDecimalDivide(&x, &pointx, &boundsw, NSRoundPlain);
	NSDecimalMultiply(&x, &x, &(XRange.length), NSRoundPlain);
	NSDecimalAdd(&x, &x, &(XRange.location), NSRoundPlain);

	NSDecimal y;
	NSDecimalDivide(&y, &pointy, &boundsh, NSRoundPlain);
	NSDecimalMultiply(&y, &y, &(YRange.length), NSRoundPlain);
	NSDecimalAdd(&y, &y, &(YRange.location), NSRoundPlain);

	return [NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithDecimal:x],[NSDecimalNumber decimalNumberWithDecimal:y],nil];
}

- (void)drawInContext:(CGContextRef)theContext
{
	// Temporary storage for the viewPointForPlotPoint call
	NSMutableArray* plotPoint = [NSMutableArray array];
	CGPoint viewPoint;
	
	// Cache the range limits
	NSDecimalNumber* XLowerRange = [NSDecimalNumber decimalNumberWithDecimal:XRange.location];
	NSDecimalNumber* XUpperRange = [XLowerRange decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:XRange.length] withBehavior:NSRoundPlain];
	NSDecimalNumber* YLowerRange = [NSDecimalNumber decimalNumberWithDecimal:YRange.location];
	NSDecimalNumber* YUpperRange = [YLowerRange decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:YRange.length] withBehavior:NSRoundPlain];

	// One path to hold the tickLines
	CGMutablePathRef tickLine = CGPathCreateMutable();

	// Make the tick line path
	for (NSDecimalNumber* tick in XMajorTickLocations)
	{
		[plotPoint insertObject:tick atIndex:0];
		[plotPoint insertObject:YLowerRange atIndex:1];
		viewPoint = [self viewPointForPlotPoint:plotPoint];
		CGPathMoveToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
		[plotPoint replaceObjectAtIndex:1 withObject:YUpperRange];
		viewPoint = [self viewPointForPlotPoint:plotPoint];
		CGPathAddLineToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
		[plotPoint removeAllObjects];
	}
	
	for (NSDecimalNumber* tick in YMajorTickLocations)
	{
		[plotPoint insertObject:XLowerRange atIndex:0];
		[plotPoint insertObject:tick atIndex:1];
		viewPoint = [self viewPointForPlotPoint:plotPoint];
		CGPathMoveToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);

		[plotPoint replaceObjectAtIndex:0 withObject:XUpperRange];
		viewPoint = [self viewPointForPlotPoint:plotPoint];
		CGPathAddLineToPoint(tickLine, NULL, viewPoint.x, viewPoint.y);
		[plotPoint removeAllObjects];
	}
	
	// Draw the tick line
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, tickLine);
	[self.majorTickLineStyle CPApplyLineStyleToContext:theContext];
    CGContextStrokePath(theContext);

	CGPathRelease(tickLine);
}

@end
