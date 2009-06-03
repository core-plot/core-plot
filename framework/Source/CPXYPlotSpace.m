
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPAxisSet.h"

@interface CPXYPlotSpace ()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSNumber *)plotCoord;

@end

@implementation CPXYPlotSpace

@synthesize xRange;
@synthesize yRange;
@synthesize xScaleType;
@synthesize yScaleType;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.xScaleType = CPScaleTypeLinear;
        self.yScaleType = CPScaleTypeLinear;
	}
	return self;
}

#pragma mark -
#pragma mark Ranges

-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate
{
    return ( coordinate == CPCoordinateX ? self.xRange : self.yRange );
}

#pragma mark -
#pragma mark Point Conversion

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSNumber *)plotCoord 
{    
    NSDecimalNumber *plotCoordDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:plotCoord.decimalValue];
    NSDecimalNumber *diff = [plotCoordDecimalNumber decimalNumberBySubtracting:range.location];
    NSDecimalNumber *factor = [diff decimalNumberByDividingBy:range.length];
    
    if ( [factor isEqualToNumber:[NSDecimalNumber notANumber]] ) {
        [NSException raise:CPException format:@"range length is zero in viewCoordinateForViewLength:..."];
    }
    
    CGFloat viewCoordinate = viewLength * factor.doubleValue;
    return viewCoordinate;
}

-(CGPoint)viewPointForPlotPoint:(NSArray *)numbers;
{
	if ([numbers count] != 2) {
        [NSException raise:CPDataException format:@"Wrong number of plot points supplied to viewPointForPlotPoint:"];
    }
        
    CGFloat viewX, viewY;

    if ( self.xScaleType == CPScaleTypeLinear ) {
        viewX = [self viewCoordinateForViewLength:self.bounds.size.width linearPlotRange:xRange plotCoordinateValue:[numbers objectAtIndex:CPCoordinateX]];
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }

    if ( self.yScaleType == CPScaleTypeLinear ) {
        viewY = [self viewCoordinateForViewLength:self.bounds.size.height linearPlotRange:yRange plotCoordinateValue:[numbers objectAtIndex:CPCoordinateY]];      
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }
    
    return CGPointMake(viewX, viewY);
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
