
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPAxisSet.h"


@implementation CPCartesianPlotSpace

@synthesize xRange;
@synthesize yRange;

#pragma mark -
#pragma mark Ranges

-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate
{
    return ( coordinate == CPCoordinateX ? self.xRange : self.yRange );
}

#pragma mark -
#pragma mark Point Conversion

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
{
	if ([decimalNumbers count] == 2) {
		NSDecimal boundsw = CPDecimalFromFloat(self.bounds.size.width);
		NSDecimal boundsh = CPDecimalFromFloat(self.bounds.size.height);

		// get the xRange's location and length
		NSDecimal xLocation = xRange.location.decimalValue;
		NSDecimal xLength = xRange.length.decimalValue;
		
		if (CPDecimalFloatValue(xLength) == 0.0) {
			[NSException raise:CPException format:@"xLength is zero in viewPointForPlotPoint:"];
		}

		NSDecimal x = [[decimalNumbers objectAtIndex:0] decimalValue];
		NSDecimalSubtract(&x, &x, &(xLocation), NSRoundPlain);
		NSDecimalDivide(&x, &x, &(xLength), NSRoundPlain);
		NSDecimalMultiply(&x, &x, &boundsw, NSRoundPlain);

		// get the yRange's location and length
		NSDecimal yLocation = yRange.location.decimalValue;
		NSDecimal yLength = yRange.length.decimalValue;
		
		if (CPDecimalFloatValue(yLength) == 0.0) {
			[NSException raise:CPException format:@"yLength is zero in viewPointForPlotPoint:"];
		}
		
		NSDecimal y = [[decimalNumbers objectAtIndex:1] decimalValue];
		NSDecimalSubtract(&y, &y, &(yLocation), NSRoundPlain);
		NSDecimalDivide(&y, &y, &(yLength), NSRoundPlain);
		NSDecimalMultiply(&y, &y, &boundsh, NSRoundPlain);
		
		return CGPointMake(CPDecimalFloatValue(x), CPDecimalFloatValue(y));
	}
	else {
        [NSException raise:CPDataException format:@"Wrong number of plot points supplied to viewPointForPlotPoint:"];
    }
    return CGPointMake(0.f, 0.f);
}

-(NSArray *)plotPointForViewPoint:(CGPoint)point
{
	NSDecimal pointx = CPDecimalFromFloat(point.x);
	NSDecimal pointy = CPDecimalFromFloat(point.y);
	NSDecimal boundsw = CPDecimalFromFloat(self.bounds.size.width);
	NSDecimal boundsh = CPDecimalFromFloat(self.bounds.size.height);
	
	// get the xRange's location and length
	NSDecimal xLocation = xRange.location.decimalValue;
	NSDecimal xLength = xRange.length.decimalValue;
	
	NSDecimal x;
	NSDecimalDivide(&x, &pointx, &boundsw, NSRoundPlain);
	NSDecimalMultiply(&x, &x, &(xLength), NSRoundPlain);
	NSDecimalAdd(&x, &x, &(xLocation), NSRoundPlain);

	// get the yRange's location and length
	NSDecimal yLocation = yRange.location.decimalValue;
	NSDecimal yLength = yRange.length.decimalValue;

	NSDecimal y;
	NSDecimalDivide(&y, &pointy, &boundsh, NSRoundPlain);
	NSDecimalMultiply(&y, &y, &(yLength), NSRoundPlain);
	NSDecimalAdd(&y, &y, &(yLocation), NSRoundPlain);

	return [NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithDecimal:x], [NSDecimalNumber decimalNumberWithDecimal:y], nil];
}

@end
