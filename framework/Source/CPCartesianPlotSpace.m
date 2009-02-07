
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"


@implementation CPCartesianPlotSpace

@synthesize xRange, yRange;

#pragma mark Init/Dealloc
-(id)init
{
	if ( self = [super init] ) {
	}
	return self;
}

#pragma mark Point Conversion
-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
{
	if ( [decimalNumbers count] == 2 ) {
		NSDecimal boundsw = CPDecimalFromFloat(self.bounds.size.width);
		NSDecimal boundsh = CPDecimalFromFloat(self.bounds.size.height);

		NSDecimal x = [[decimalNumbers objectAtIndex:0] decimalValue];
		NSDecimalSubtract(&x, &x, &(xRange.location), NSRoundPlain);
		NSDecimalDivide(&x, &x, &(xRange.length), NSRoundPlain);
		NSDecimalMultiply(&x, &x, &boundsw, NSRoundPlain);
		NSDecimal y = [[decimalNumbers objectAtIndex:1] decimalValue];
		NSDecimalSubtract(&y, &y, &(yRange.location), NSRoundPlain);
		NSDecimalDivide(&y, &y, &(yRange.length), NSRoundPlain);
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

	NSDecimal x;
	NSDecimalDivide(&x, &pointx, &boundsw, NSRoundPlain);
	NSDecimalMultiply(&x, &x, &(xRange.length), NSRoundPlain);
	NSDecimalAdd(&x, &x, &(xRange.location), NSRoundPlain);

	NSDecimal y;
	NSDecimalDivide(&y, &pointy, &boundsh, NSRoundPlain);
	NSDecimalMultiply(&y, &y, &(yRange.length), NSRoundPlain);
	NSDecimalAdd(&y, &y, &(yRange.location), NSRoundPlain);

	return [NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithDecimal:x],[NSDecimalNumber decimalNumberWithDecimal:y],nil];
}


@end
