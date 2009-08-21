
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPLineStyle.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPAxisSet.h"

///	@cond
@interface CPXYPlotSpace ()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

@end
///	@endcond

/**	@brief A plot space using a two-dimensional cartesian coordinate system.
 **/
@implementation CPXYPlotSpace

/**	@property xRange
 *	@brief The range of the x-axis.
 **/
@synthesize xRange;

/**	@property yRange
 *	@brief The range of the y-axis.
 **/
@synthesize yRange;

/**	@property xScaleType
 *	@brief The scale type of the x-axis.
 **/
@synthesize xScaleType;

/**	@property yScaleType
 *	@brief The scale type of the y-axis.
 **/
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

-(void)setXRange:(CPPlotRange *)range 
{
    if ( range != xRange ) {
        [xRange release];
        xRange = [range copy];
        [self setNeedsLayout];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
    }
}

-(void)setYRange:(CPPlotRange *)range 
{
    if ( range != yRange ) {
        [yRange release];
        yRange = [range copy];
        [self setNeedsLayout];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
    }
}

#pragma mark -
#pragma mark Point Conversion

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord 
{    
	NSDecimal factor = CPDecimalDivide(CPDecimalSubtract(plotCoord, range.location), range.length);
    
    if ( NSDecimalIsNotANumber(&factor) ) {
        [NSException raise:CPException format:@"range length is zero in viewCoordinateForViewLength:..."];
    }
    
	CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] floatValue];
    
    return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	return viewLength * ((plotCoord - range.doublePrecisionLocation) / range.doublePrecisionLength);
}

-(CGPoint)viewPointForPlotPoint:(NSDecimal *)plotPoint
{
    CGFloat viewX, viewY;
    
    if ( self.xScaleType == CPScaleTypeLinear ) {
        viewX = [self viewCoordinateForViewLength:self.bounds.size.width linearPlotRange:xRange plotCoordinateValue:plotPoint[CPCoordinateX]];
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }
    
    if ( self.yScaleType == CPScaleTypeLinear ) {
        viewY = [self viewCoordinateForViewLength:self.bounds.size.height linearPlotRange:yRange plotCoordinateValue:plotPoint[CPCoordinateY]];      
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }
    
    return CGPointMake(viewX, viewY);
}

-(CGPoint)viewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
{
    CGFloat viewX, viewY;
    
    if ( self.xScaleType == CPScaleTypeLinear ) {
        viewX = [self viewCoordinateForViewLength:self.bounds.size.width linearPlotRange:xRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateX]];
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }
    
    if ( self.yScaleType == CPScaleTypeLinear ) {
        viewY = [self viewCoordinateForViewLength:self.bounds.size.height linearPlotRange:yRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateY]];      
    }
    else {
        [NSException raise:CPException format:@"Scale type not yet supported in CPXYPlotSpace"];
    }
    
    return CGPointMake(viewX, viewY);
}


-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point
{
	NSDecimal pointx = CPDecimalFromFloat(point.x);
	NSDecimal pointy = CPDecimalFromFloat(point.y);
	NSDecimal boundsw = CPDecimalFromFloat(self.bounds.size.width);
	NSDecimal boundsh = CPDecimalFromFloat(self.bounds.size.height);
	
	// get the xRange's location and length
	NSDecimal xLocation = xRange.location;
	NSDecimal xLength = xRange.length;
	
	NSDecimal x;
	NSDecimalDivide(&x, &pointx, &boundsw, NSRoundPlain);
	NSDecimalMultiply(&x, &x, &(xLength), NSRoundPlain);
	NSDecimalAdd(&x, &x, &(xLocation), NSRoundPlain);
    
	// get the yRange's location and length
	NSDecimal yLocation = yRange.location;
	NSDecimal yLength = yRange.length;
    
	NSDecimal y;
	NSDecimalDivide(&y, &pointy, &boundsh, NSRoundPlain);
	NSDecimalMultiply(&y, &y, &(yLength), NSRoundPlain);
	NSDecimalAdd(&y, &y, &(yLocation), NSRoundPlain);

    plotPoint[CPCoordinateX] = x;
    plotPoint[CPCoordinateY] = y;
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point;
{
}

@end
