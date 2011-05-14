#import "CPTXYPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTExceptions.h"
#import "CPTXYAxisSet.h"
#import "CPTXYAxis.h"
#import "CPTAxisSet.h"
#import "CPTPlot.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotRange.h"
#import "CPTPlotArea.h"
#import "CPTGraph.h"

/**	@cond */
@interface CPTXYPlotSpace ()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;

@end
/**	@endcond */

#pragma mark -

/** @brief A plot space using a two-dimensional cartesian coordinate system.
 **/
@implementation CPTXYPlotSpace

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
		xRange = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
		yRange = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];;
        globalXRange = nil;
        globalYRange = nil;
		xScaleType = CPTScaleTypeLinear;
		yScaleType = CPTScaleTypeLinear;
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

-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
	if ( coordinate == CPTCoordinateX ) {
        self.xRange = newRange;
    }
    else {
        self.yRange = newRange;
    }
}

-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
	return ( coordinate == CPTCoordinateX ? self.xRange : self.yRange );
}

-(void)setXRange:(CPTPlotRange *)range 
{
	NSParameterAssert(range);
	if ( ![range isEqualToRange:xRange] ) {
        CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
		[xRange release];
		xRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification object:self];
    	if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateX];
        }
        if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
	}
}

-(void)setYRange:(CPTPlotRange *)range 
{
	NSParameterAssert(range);
	if ( ![range isEqualToRange:yRange] ) {
        CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
		[yRange release];
		yRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification object:self];
        if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
            [self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateY];
        }
        if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
	}
}

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange 
{
    if ( !globalRange ) return existingRange;
    if ( !existingRange ) return nil;
	
	if ( CPTDecimalGreaterThanOrEqualTo(existingRange.length, globalRange.length) ) {
		return [[globalRange copy] autorelease];
	}
	else {
		CPTPlotRange *newRange = [[existingRange copy] autorelease];
		[newRange shiftEndToFitInRange:globalRange];
		[newRange shiftLocationToFitInRange:globalRange];
		return newRange;
	}
}

-(void)setGlobalXRange:(CPTPlotRange *)newRange 
{
    if ( ![newRange isEqualToRange:globalXRange] ) {
    	[globalXRange release];
        globalXRange = [newRange copy];
		self.xRange = [self constrainRange:self.xRange toGlobalRange:globalXRange];
    }
}

-(void)setGlobalYRange:(CPTPlotRange *)newRange 
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
	CPTPlotRange *unionXRange = nil;
    CPTPlotRange *unionYRange = nil;
    for ( CPTPlot *plot in plots ) {
    	CPTPlotRange *currentXRange = [plot plotRangeForCoordinate:CPTCoordinateX];
        CPTPlotRange *currentYRange = [plot plotRangeForCoordinate:CPTCoordinateY];
        if ( !unionXRange ) unionXRange = currentXRange;
        if ( !unionYRange ) unionYRange = currentYRange;
    	[unionXRange unionPlotRange:currentXRange];
        [unionYRange unionPlotRange:currentYRange];
    }
    
    // Set range
    NSDecimal zero = CPTDecimalFromInteger(0);
    if ( unionXRange && !CPTDecimalEquals(unionXRange.length, zero) ) self.xRange = unionXRange;
    if ( unionYRange && !CPTDecimalEquals(unionYRange.length, zero) ) self.yRange = unionYRange;
}

#pragma mark -
#pragma mark Point Conversion

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord 
{	 
	if ( !range ) return 0.0;
    
	NSDecimal factor = CPTDecimalDivide(CPTDecimalSubtract(plotCoord, range.location), range.length);
	if ( NSDecimalIsNotANumber(&factor) ) {
		factor = CPTDecimalFromInteger(0);
	}
	
	CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] doubleValue];
    
    return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	if ( !range || range.lengthDouble == 0.0 ) return 0.0;
    return viewLength * ((plotCoord - range.locationDouble) / range.lengthDouble);
}

-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
	CGFloat viewX = 0.0, viewY = 0.0;
	CGSize layerSize = self.graph.plotAreaFrame.plotArea.bounds.size;
	
	switch ( self.xScaleType ) {
		case CPTScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
			break;
		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPTScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
			break;
		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint
{
	CGFloat viewX = 0.0, viewY = 0.0;
	CGSize layerSize = self.graph.plotAreaFrame.plotArea.bounds.size;

	switch ( self.xScaleType ) {
		case CPTScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
			break;
		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}
	
	switch ( self.yScaleType ) {
		case CPTScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
			break;
		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}
	
	return CGPointMake(viewX, viewY);
}

-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
	NSDecimal pointx = CPTDecimalFromDouble(point.x);
	NSDecimal pointy = CPTDecimalFromDouble(point.y);
	CGSize boundsSize = self.graph.plotAreaFrame.plotArea.bounds.size;
	NSDecimal boundsw = CPTDecimalFromDouble(boundsSize.width);
	NSDecimal boundsh = CPTDecimalFromDouble(boundsSize.height);
	
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
	
	plotPoint[CPTCoordinateX] = x;
	plotPoint[CPTCoordinateY] = y;
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point 
{
	//	TODO: implement doublePrecisionPlotPoint:forViewPoint:
}

#pragma mark -
#pragma mark Scaling

-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
{
	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame || interactionScale <= 1.e-6 ) return;
	if ( ![self.graph.plotAreaFrame.plotArea containsPoint:plotAreaPoint] ) return;
    
    // Ask the delegate if it is OK
    BOOL shouldScale = YES;
    if ( [self.delegate respondsToSelector:@selector(plotSpace:shouldScaleBy:aboutPoint:)] ) {
        shouldScale = [self.delegate plotSpace:self shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
    }
    if ( !shouldScale ) return;
    
    // Determine point in plot coordinates
    NSDecimal const decimalScale = CPTDecimalFromFloat(interactionScale);
    NSDecimal plotInteractionPoint[2];
    [self plotPoint:plotInteractionPoint forPlotAreaViewPoint:plotAreaPoint];
        
    // Original Lengths
    NSDecimal oldFirstLengthX  = CPTDecimalSubtract(plotInteractionPoint[0], self.xRange.minLimit);
    NSDecimal oldSecondLengthX = CPTDecimalSubtract(self.xRange.maxLimit, plotInteractionPoint[0]);
    NSDecimal oldFirstLengthY  = CPTDecimalSubtract(plotInteractionPoint[1], self.yRange.minLimit);
    NSDecimal oldSecondLengthY = CPTDecimalSubtract(self.yRange.maxLimit, plotInteractionPoint[1]);
    
    // Lengths are scaled by the pinch gesture inverse proportional
    NSDecimal newFirstLengthX  = CPTDecimalDivide(oldFirstLengthX, decimalScale);
    NSDecimal newSecondLengthX = CPTDecimalDivide(oldSecondLengthX, decimalScale);
    NSDecimal newFirstLengthY  = CPTDecimalDivide(oldFirstLengthY, decimalScale);
    NSDecimal newSecondLengthY = CPTDecimalDivide(oldSecondLengthY, decimalScale);

	// New ranges
    CPTPlotRange *newRangeX = [[[CPTPlotRange alloc] initWithLocation:CPTDecimalSubtract(plotInteractionPoint[0],newFirstLengthX) length:CPTDecimalAdd(newFirstLengthX,newSecondLengthX)] autorelease];
    CPTPlotRange *newRangeY = [[[CPTPlotRange alloc] initWithLocation:CPTDecimalSubtract(plotInteractionPoint[1],newFirstLengthY) length:CPTDecimalAdd(newFirstLengthY,newSecondLengthY)] autorelease];

    // delegate may still veto/modify the range
    if ( [self.delegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
      newRangeX = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
      newRangeY = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
    }

    self.xRange = newRangeX;
    self.yRange = newRangeY;
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
        
		CPTPlotRange *newRangeX = [[self.xRange copy] autorelease];
        CPTPlotRange *newRangeY = [[self.yRange copy] autorelease];

        NSDecimal shiftX = CPTDecimalSubtract(lastPoint[0], newPoint[0]);
        NSDecimal shiftY = CPTDecimalSubtract(lastPoint[1], newPoint[1]);
		newRangeX.location = CPTDecimalAdd(newRangeX.location, shiftX);
        newRangeY.location = CPTDecimalAdd(newRangeY.location, shiftY);

        // Delegate override
        if ( [self.delegate respondsToSelector:@selector(plotSpace:willChangePlotRangeTo:forCoordinate:)] ) {
            newRangeX = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeX forCoordinate:CPTCoordinateX];
            newRangeY = [self.delegate plotSpace:self willChangePlotRangeTo:newRangeY forCoordinate:CPTCoordinateY];
        }
        
        self.xRange = newRangeX;
        self.yRange = newRangeY;
        
        lastDragPoint = pointInPlotArea;
        
        return YES;
    }

	return NO;
}

@end
