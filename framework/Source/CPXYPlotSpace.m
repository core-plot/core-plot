
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPAxisSet.h"
#import "CPPlot.h"
#import "CPPlotAreaFrame.h"
#import "CPPlotRange.h"
#import "CPPlotArea.h"
#import "CPGraph.h"

/// @cond
@interface CPXYPlotSpace ()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CPPlotRange *)constrainRange:(CPPlotRange *)existingRange toGlobalRange:(CPPlotRange *)globalRange;

@end
/// @endcond

#pragma mark -

/** @brief A plot space using a two-dimensional cartesian coordinate system.
 **/
@implementation CPXYPlotSpace

/** @property xRange
 *	@brief The range of the x coordinate.
 **/
@synthesize xRange;

/** @property yRange
 *	@brief The range of the y coordinate.
 **/
@synthesize yRange;

/** @property globalXRange
 *	@brief The global range of the x coordinate to which the plot range is constrained.
 *  If nil, there is no constraint on x.
 **/
@synthesize globalXRange;

/** @property globalYRange
 *	@brief The global range of the y coordinate to which the plot range is constrained.
 *  If nil, there is no constraint on y.
 **/
@synthesize globalYRange;

/** @property xScaleType
 *	@brief The scale type of the x coordinate.
 **/
@synthesize xScaleType;

/** @property yScaleType
 *	@brief The scale type of the y coordinate.
 **/
@synthesize yScaleType;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)init
{
	if ( self = [super init] ) {
		xRange = [[CPPlotRange alloc] initWithLocation:CPDecimalFromInteger(0) length:CPDecimalFromInteger(1)];
		yRange = [[CPPlotRange alloc] initWithLocation:CPDecimalFromInteger(0) length:CPDecimalFromInteger(1)];;
        globalXRange = nil;
        globalYRange = nil;
		xScaleType = CPScaleTypeLinear;
		yScaleType = CPScaleTypeLinear;
	}
	return self;
}

-(void)dealloc
{
	[xRange release];
	[yRange release];
    [globalXRange release];
    [globalYRange release];
	[super dealloc];
}

#pragma mark -
#pragma mark Ranges

-(void)setPlotRange:(CPPlotRange *)newRange forCoordinate:(CPCoordinate)coordinate
{
	if ( coordinate == CPCoordinateX ) {
        self.xRange = newRange;
    }
    else {
        self.yRange = newRange;
    }
}

-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate
{
	return ( coordinate == CPCoordinateX ? self.xRange : self.yRange );
}

-(void)setXRange:(CPPlotRange *)range 
{
	NSParameterAssert(range);
	if ( ![range isEqualToRange:xRange] ) {
        CPPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
		[xRange release];
		xRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
    	if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPCoordinateX];
        }
        if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPGraphNeedsRedrawNotification object:self.graph];
	}
}

-(void)setYRange:(CPPlotRange *)range 
{
	NSParameterAssert(range);
	if ( ![range isEqualToRange:yRange] ) {
        CPPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
		[yRange release];
		yRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
        if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPCoordinateY];
        }
        if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPGraphNeedsRedrawNotification object:self.graph];
	}
}

-(CPPlotRange *)constrainRange:(CPPlotRange *)existingRange toGlobalRange:(CPPlotRange *)globalRange 
{
    if ( !globalRange ) return existingRange;
    if ( !existingRange ) return nil;
    CPPlotRange *newRange = [[existingRange copy] autorelease];
    [newRange shiftEndToFitInRange:globalRange];
    [newRange shiftLocationToFitInRange:globalRange];
    return newRange;
}

-(void)setGlobalXRange:(CPPlotRange *)newRange 
{
    if ( ![newRange isEqualToRange:globalXRange] ) {
    	[globalXRange release];
        globalXRange = [newRange copy];
		self.xRange = [self constrainRange:self.xRange toGlobalRange:globalXRange];
    }
}

-(void)setGlobalYRange:(CPPlotRange *)newRange 
{
    if ( ![newRange isEqualToRange:globalYRange] ) {
    	[globalYRange release];
        globalYRange = [newRange copy];
        self.yRange = [self constrainRange:self.yRange toGlobalRange:globalYRange];
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
    NSDecimal zero = CPDecimalFromInteger(0);
    if ( !CPDecimalEquals(unionXRange.length, zero) ) self.xRange = unionXRange;
    if ( !CPDecimalEquals(unionYRange.length, zero) ) self.yRange = unionYRange;
}

#pragma mark -
#pragma mark Point Conversion

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord 
{	 
	if ( !range ) return 0.0;
    
	NSDecimal factor = CPDecimalDivide(CPDecimalSubtract(plotCoord, range.location), range.length);
	if ( NSDecimalIsNotANumber(&factor) ) {
		factor = CPDecimalFromInteger(0);
	}
	
	CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] doubleValue];
    
    return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	if ( !range || range.lengthDouble == 0.0 ) return 0.0;
    return viewLength * ((plotCoord - range.locationDouble) / range.lengthDouble);
}

-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
	CGFloat viewX = 0.0, viewY = 0.0;
	CGSize layerSize = self.graph.plotAreaFrame.plotArea.bounds.size;
	
	switch ( self.xScaleType ) {
		case CPScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPCoordinateX]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPCoordinateY]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint
{
	CGFloat viewX = 0.0, viewY = 0.0;
	CGSize layerSize = self.graph.plotAreaFrame.plotArea.bounds.size;

	switch ( self.xScaleType ) {
		case CPScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateX]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPCoordinateY]];
			break;
		default:
			[NSException raise:CPException format:@"Scale type not supported in CPXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
	NSDecimal pointx = CPDecimalFromDouble(point.x);
	NSDecimal pointy = CPDecimalFromDouble(point.y);
	CGSize boundsSize = self.graph.plotAreaFrame.plotArea.bounds.size;
	NSDecimal boundsw = CPDecimalFromDouble(boundsSize.width);
	NSDecimal boundsh = CPDecimalFromDouble(boundsSize.height);
	
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

-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point 
{
	//	TODO: implement doublePrecisionPlotPoint:forViewPoint:
}

#pragma mark -
#pragma mark Interaction

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    if ( handledByDelegate ) return YES;

	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }
    
    CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
    if ( [self.graph.plotAreaFrame containsPoint:pointInPlotArea] ) {
        // Handle event
        lastDragPoint = pointInPlotArea;
        isDragging = YES;
        return YES;
    }

	return NO;
}

-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];
	if ( handledByDelegate ) return YES;

	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }
    
    if ( isDragging ) {
        isDragging = NO;
        return YES;
    }
    
	return NO;
}

-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
	if ( handledByDelegate ) return YES;
    
	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
        return NO;
    }
    
    CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
    if ( isDragging ) {
    	CGPoint displacement = CGPointMake(pointInPlotArea.x-lastDragPoint.x, pointInPlotArea.y-lastDragPoint.y);
        CGPoint pointToUse = pointInPlotArea;
        
        // Allow delegate to override
        if ( [self.delegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
            displacement = [self.delegate plotSpace:self willDisplaceBy:displacement];
            pointToUse = CGPointMake(lastDragPoint.x+displacement.x, lastDragPoint.y+displacement.y);
        }
    
    	NSDecimal lastPoint[2], newPoint[2];
    	[self plotPoint:lastPoint forPlotAreaViewPoint:lastDragPoint];
        [self plotPoint:newPoint forPlotAreaViewPoint:pointToUse];
        
		CPPlotRange *newRangeX = [[self.xRange copy] autorelease];
        CPPlotRange *newRangeY = [[self.yRange copy] autorelease];

        NSDecimal shiftX = CPDecimalSubtract(lastPoint[0], newPoint[0]);
        NSDecimal shiftY = CPDecimalSubtract(lastPoint[1], newPoint[1]);
		newRangeX.location = CPDecimalAdd(newRangeX.location, shiftX);
        newRangeY.location = CPDecimalAdd(newRangeY.location, shiftY);

        // Delegate override
        if ( [self.delegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            newRangeX = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPCoordinateX];
            newRangeY = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPCoordinateY];
        }
        
        self.xRange = newRangeX;
        self.yRange = newRangeY;
        
        lastDragPoint = pointInPlotArea;
        
        return YES;
    }

	return NO;
}

@end
