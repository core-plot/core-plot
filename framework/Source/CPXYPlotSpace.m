
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPAxisSet.h"
#import "CPPlot.h"

/// @cond
@interface CPXYPlotSpace ()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

@end
/// @endcond

/** @brief A plot space using a two-dimensional cartesian coordinate system.
 **/
@implementation CPXYPlotSpace

/** @property xRange
 *	@brief The range of the x-axis.
 **/
@synthesize xRange;

/** @property yRange
 *	@brief The range of the y-axis.
 **/
@synthesize yRange;

/** @property xScaleType
 *	@brief The scale type of the x-axis.
 **/
@synthesize xScaleType;

/** @property yScaleType
 *	@brief The scale type of the y-axis.
 **/
@synthesize yScaleType;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)init
{
	if ( self = [super init] ) {
		xRange = nil;
		yRange = nil;
		xScaleType = CPScaleTypeLinear;
		yScaleType = CPScaleTypeLinear;
	}
	return self;
}

-(void)dealloc
{
	[xRange release];
	[yRange release];
	[super dealloc];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
	}
}

-(void)setYRange:(CPPlotRange *)range 
{
	if ( range != yRange ) {
		[yRange release];
		yRange = [range copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
	}
}

-(void)scaleToFitPlots:(NSArray *)plots {
	if ( plots.count == 0 ) return;
    
	// Determine union of ranges
	CPPlotRange *unionXRange = [[plots objectAtIndex:0] plotRangeForCoordinate:CPCoordinateX];
    CPPlotRange *unionYRange = [[plots objectAtIndex:0] plotRangeForCoordinate:CPCoordinateY];
    for ( CPPlot *plot in plots ) {
    	[unionXRange unionPlotRange:[plot plotRangeForCoordinate:CPCoordinateX]];
        [unionYRange unionPlotRange:[plot plotRangeForCoordinate:CPCoordinateY]];
    }
    
    // Set range
    NSDecimal zero = CPDecimalFromInt(0);
    if ( !CPDecimalEquals(unionXRange.length, zero) ) self.xRange = unionXRange;
    if ( !CPDecimalEquals(unionYRange.length, zero) )self.yRange = unionYRange;
}

#pragma mark -
#pragma mark Point Conversion

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord 
{	 
	if ( !range ) return 0.0f;
    
	NSDecimal factor = CPDecimalDivide(CPDecimalSubtract(plotCoord, range.location), range.length);
	if ( NSDecimalIsNotANumber(&factor) ) {
		factor = CPDecimalFromInt(0);
	}
	
	CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] doubleValue];
    
    return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	if ( !range || range.doublePrecisionLength == 0.0 ) return 0.0f;
    return viewLength * ((plotCoord - range.doublePrecisionLocation) / range.doublePrecisionLength);
}

-(CGPoint)viewPointInLayer:(CPLayer *)layer forPlotPoint:(NSDecimal *)plotPoint
{
	CGFloat viewX, viewY;
	CGSize layerSize = layer.bounds.size;
	
	switch ( self.xScaleType ) {
		case CPScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:xRange plotCoordinateValue:plotPoint[CPCoordinateX]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:yRange plotCoordinateValue:plotPoint[CPCoordinateY]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(CGPoint)viewPointInLayer:(CPLayer *)layer forDoublePrecisionPlotPoint:(double *)plotPoint
{
	CGFloat viewX, viewY;
	CGSize layerSize = layer.bounds.size;

	switch ( self.xScaleType ) {
		case CPScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:xRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateX]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:yRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateY]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer
{
	NSDecimal pointx = CPDecimalFromFloat(point.x);
	NSDecimal pointy = CPDecimalFromFloat(point.y);
	NSDecimal boundsw = CPDecimalFromFloat(layer.bounds.size.width);
	NSDecimal boundsh = CPDecimalFromFloat(layer.bounds.size.height);
	
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

-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer
{
	//	TODO: implement doublePrecisionPlotPoint:forViewPoint:
}

@end
