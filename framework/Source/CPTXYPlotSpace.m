#import "CPTXYPlotSpace.h"

#import "CPTAxisSet.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTPlot.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"
#import "CPTXYAxisSet.h"
#import "NSNumberExtensions.h"

/**	@cond */
@interface CPTXYPlotSpace()

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord;
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;

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
	if ( (self = [super init]) ) {
		xRange		  = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger( 0 ) length:CPTDecimalFromInteger( 1 )];
		yRange		  = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromInteger( 0 ) length:CPTDecimalFromInteger( 1 )];
		globalXRange  = nil;
		globalYRange  = nil;
		xScaleType	  = CPTScaleTypeLinear;
		yScaleType	  = CPTScaleTypeLinear;
		lastDragPoint = CGPointZero;
		isDragging	  = NO;
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
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.xRange forKey:@"CPTXYPlotSpace.xRange"];
	[coder encodeObject:self.yRange forKey:@"CPTXYPlotSpace.yRange"];
	[coder encodeObject:self.globalXRange forKey:@"CPTXYPlotSpace.globalXRange"];
	[coder encodeObject:self.globalYRange forKey:@"CPTXYPlotSpace.globalYRange"];
	[coder encodeInteger:self.xScaleType forKey:@"CPTXYPlotSpace.xScaleType"];
	[coder encodeInteger:self.yScaleType forKey:@"CPTXYPlotSpace.yScaleType"];

	// No need to archive these properties:
	// lastDragPoint
	// isDragging
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		xRange		 = [[coder decodeObjectForKey:@"CPTXYPlotSpace.xRange"] copy];
		yRange		 = [[coder decodeObjectForKey:@"CPTXYPlotSpace.yRange"] copy];
		globalXRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalXRange"] copy];
		globalYRange = [[coder decodeObjectForKey:@"CPTXYPlotSpace.globalYRange"] copy];
		xScaleType	 = [coder decodeIntegerForKey:@"CPTXYPlotSpace.xScaleType"];
		yScaleType	 = [coder decodeIntegerForKey:@"CPTXYPlotSpace.yScaleType"];

		lastDragPoint = CGPointZero;
		isDragging	  = NO;
	}
	return self;
}

#pragma mark -
#pragma mark Ranges

-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
	switch ( coordinate ) {
		case CPTCoordinateX:
			self.xRange = newRange;
			break;

		case CPTCoordinateY:
			self.yRange = newRange;
			break;

		default:
			// invalid coordinate--do nothing
			break;
	}
}

-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
	CPTPlotRange *theRange = nil;

	switch ( coordinate ) {
		case CPTCoordinateX:
			theRange = self.xRange;
			break;

		case CPTCoordinateY:
			theRange = self.yRange;
			break;

		default:
			// invalid coordinate
			break;
	}

	return theRange;
}

-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate
{
	switch ( coordinate ) {
		case CPTCoordinateX:
			self.xScaleType = newType;
			break;

		case CPTCoordinateY:
			self.yScaleType = newType;
			break;

		default:
			// invalid coordinate--do nothing
			break;
	}
}

-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate
{
	CPTScaleType theScaleType = CPTScaleTypeLinear;

	switch ( coordinate ) {
		case CPTCoordinateX:
			theScaleType = self.xScaleType;
			break;

		case CPTCoordinateY:
			theScaleType = self.yScaleType;
			break;

		default:
			// invalid coordinate
			break;
	}

	return theScaleType;
}

-(void)setXRange:(CPTPlotRange *)range
{
	NSParameterAssert( range );
	if ( ![range isEqualToRange:xRange] ) {
		CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalXRange];
		[xRange release];
		xRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification object:self];
		if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
			[self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateX];
		}
		if ( self.graph ) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
		}
	}
}

-(void)setYRange:(CPTPlotRange *)range
{
	NSParameterAssert( range );
	if ( ![range isEqualToRange:yRange] ) {
		CPTPlotRange *constrainedRange = [self constrainRange:range toGlobalRange:self.globalYRange];
		[yRange release];
		yRange = [constrainedRange copy];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTPlotSpaceCoordinateMappingDidChangeNotification object:self];
		if ( [self.delegate respondsToSelector:@selector(plotSpace:didChangePlotRangeForCoordinate:)] ) {
			[self.delegate plotSpace:self didChangePlotRangeForCoordinate:CPTCoordinateY];
		}
		if ( self.graph ) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
		}
	}
}

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange
{
	if ( !globalRange ) {
		return existingRange;
	}
	if ( !existingRange ) {
		return nil;
	}

	if ( CPTDecimalGreaterThanOrEqualTo( existingRange.length, globalRange.length ) ) {
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
		self.xRange	 = [self constrainRange:self.xRange toGlobalRange:globalXRange];
	}
}

-(void)setGlobalYRange:(CPTPlotRange *)newRange
{
	if ( ![newRange isEqualToRange:globalYRange] ) {
		[globalYRange release];
		globalYRange = [newRange copy];
		self.yRange	 = [self constrainRange:self.yRange toGlobalRange:globalYRange];
	}
}

-(void)scaleToFitPlots:(NSArray *)plots
{
	if ( plots.count == 0 ) {
		return;
	}

	// Determine union of ranges
	CPTPlotRange *unionXRange = nil;
	CPTPlotRange *unionYRange = nil;
	for ( CPTPlot *plot in plots ) {
		CPTPlotRange *currentXRange = [plot plotRangeForCoordinate:CPTCoordinateX];
		CPTPlotRange *currentYRange = [plot plotRangeForCoordinate:CPTCoordinateY];
		if ( !unionXRange ) {
			unionXRange = currentXRange;
		}
		if ( !unionYRange ) {
			unionYRange = currentYRange;
		}
		[unionXRange unionPlotRange:currentXRange];
		[unionYRange unionPlotRange:currentYRange];
	}

	// Set range
	NSDecimal zero = CPTDecimalFromInteger( 0 );
	if ( unionXRange && !CPTDecimalEquals( unionXRange.length, zero ) ) {
		self.xRange = unionXRange;
	}
	if ( unionYRange && !CPTDecimalEquals( unionYRange.length, zero ) ) {
		self.yRange = unionYRange;
	}
}

-(void)setXScaleType:(CPTScaleType)newScaleType
{
	if ( newScaleType != xScaleType ) {
		xScaleType = newScaleType;
		if ( self.graph ) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
		}
	}
}

-(void)setYScaleType:(CPTScaleType)newScaleType
{
	if ( newScaleType != yScaleType ) {
		yScaleType = newScaleType;
		if ( self.graph ) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
		}
	}
}

#pragma mark -
#pragma mark Point Conversion

// Linear
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range plotCoordinateValue:(NSDecimal)plotCoord
{
	if ( !range ) {
		return 0.0;
	}

	NSDecimal factor = CPTDecimalDivide( CPTDecimalSubtract( plotCoord, range.location ), range.length );
	if ( NSDecimalIsNotANumber( &factor ) ) {
		factor = CPTDecimalFromInteger( 0 );
	}

	CGFloat viewCoordinate = viewLength * [[NSDecimalNumber decimalNumberWithDecimal:factor] cgFloatValue];

	return viewCoordinate;
}

-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	if ( !range || (range.lengthDouble == 0.0) ) {
		return 0.0;
	}
	return viewLength * ( (plotCoord - range.locationDouble) / range.lengthDouble );
}

// Natural log (only one version since there are no trancendental functions for NSDecimal)
-(CGFloat)viewCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(CPTPlotRange *)range doublePrecisionPlotCoordinateValue:(double)plotCoord;
{
	if ( (range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0) || (plotCoord <= 0.0) ) {
		return 0.0;
	}

	double logLoc	= log10( range.locationDouble );
	double logCoord = log10( plotCoord );
	double logEnd	= log10( range.endDouble );

	return viewLength * (logCoord - logLoc) / (logEnd - logLoc);
}

// Plot area view point for plot point
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
	CGSize layerSize	  = CGSizeZero;
	CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

	if ( plotArea ) {
		layerSize = plotArea.bounds.size;
	}
	else {
		return CGPointZero;
	}

	CGFloat viewX = 0.0;
	CGFloat viewY = 0.0;

	switch ( self.xScaleType ) {
		case CPTScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange plotCoordinateValue:plotPoint[CPTCoordinateX]];
			break;

		case CPTScaleTypeLog:
		{
			double x = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateX]] doubleValue];
			viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:x];
		}
		break;

		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}

	switch ( self.yScaleType ) {
		case CPTScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange plotCoordinateValue:plotPoint[CPTCoordinateY]];
			break;

		case CPTScaleTypeLog:
		{
			double y = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateY]] doubleValue];
			viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:y];
		}
		break;

		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}

	return CGPointMake( viewX, viewY );
}

-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint
{
	CGSize layerSize	  = CGSizeZero;
	CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

	if ( plotArea ) {
		layerSize = plotArea.bounds.size;
	}
	else {
		return CGPointZero;
	}

	CGFloat viewX = 0.0;
	CGFloat viewY = 0.0;

	switch ( self.xScaleType ) {
		case CPTScaleTypeLinear:
			viewX = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
			break;

		case CPTScaleTypeLog:
			viewX = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
			break;

		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}

	switch ( self.yScaleType ) {
		case CPTScaleTypeLinear:
			viewY = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
			break;

		case CPTScaleTypeLog:
			viewY = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
			break;

		default:
			[NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
	}

	return CGPointMake( viewX, viewY );
}

// Plot point for view point
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
	CGSize boundsSize	  = CGSizeZero;
	CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

	if ( plotArea ) {
		boundsSize = plotArea.bounds.size;
	}
	else {
		NSDecimal zero = CPTDecimalFromInteger( 0 );
		plotPoint[CPTCoordinateX] = zero;
		plotPoint[CPTCoordinateY] = zero;
		return;
	}

	NSDecimal pointx  = CPTDecimalFromDouble( point.x );
	NSDecimal pointy  = CPTDecimalFromDouble( point.y );
	NSDecimal boundsw = CPTDecimalFromDouble( boundsSize.width );
	NSDecimal boundsh = CPTDecimalFromDouble( boundsSize.height );

	// get the xRange's location and length
	NSDecimal xLocation = xRange.location;
	NSDecimal xLength	= xRange.length;

	NSDecimal x;
	NSDecimalDivide( &x, &pointx, &boundsw, NSRoundPlain );
	NSDecimalMultiply( &x, &x, &(xLength), NSRoundPlain );
	NSDecimalAdd( &x, &x, &(xLocation), NSRoundPlain );

	// get the yRange's location and length
	NSDecimal yLocation = yRange.location;
	NSDecimal yLength	= yRange.length;

	NSDecimal y;
	NSDecimalDivide( &y, &pointy, &boundsh, NSRoundPlain );
	NSDecimalMultiply( &y, &y, &(yLength), NSRoundPlain );
	NSDecimalAdd( &y, &y, &(yLocation), NSRoundPlain );

	plotPoint[CPTCoordinateX] = x;
	plotPoint[CPTCoordinateY] = y;
}

-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
	CGSize boundsSize	  = CGSizeZero;
	CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;

	if ( plotArea ) {
		boundsSize = plotArea.bounds.size;
	}
	else {
		plotPoint[CPTCoordinateX] = 0.0;
		plotPoint[CPTCoordinateY] = 0.0;
		return;
	}

	double x = point.x / boundsSize.width;
	x *= xRange.lengthDouble;
	x += xRange.locationDouble;

	double y = point.y / boundsSize.height;
	y *= yRange.lengthDouble;
	y += yRange.locationDouble;

	plotPoint[CPTCoordinateX] = x;
	plotPoint[CPTCoordinateY] = y;
}

#pragma mark -
#pragma mark Scaling

-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
{
	if ( !self.graph.plotAreaFrame || (interactionScale <= 1.e-6) ) {
		return;
	}
	if ( ![self.graph.plotAreaFrame.plotArea containsPoint:plotAreaPoint] ) {
		return;
	}

	// Ask the delegate if it is OK
	BOOL shouldScale = YES;
	if ( [self.delegate respondsToSelector:@selector(plotSpace:shouldScaleBy:aboutPoint:)] ) {
		shouldScale = [self.delegate plotSpace:self shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
	}
	if ( !shouldScale ) {
		return;
	}

	// Determine point in plot coordinates
	NSDecimal const decimalScale = CPTDecimalFromCGFloat( interactionScale );
	NSDecimal plotInteractionPoint[2];
	[self plotPoint:plotInteractionPoint forPlotAreaViewPoint:plotAreaPoint];

	// Cache old ranges
	CPTPlotRange *oldRangeX = self.xRange;
	CPTPlotRange *oldRangeY = self.yRange;

	// Lengths are scaled by the pinch gesture inverse proportional
	NSDecimal newLengthX = CPTDecimalDivide( oldRangeX.length, decimalScale );
	NSDecimal newLengthY = CPTDecimalDivide( oldRangeY.length, decimalScale );

	// New locations
	NSDecimal newLocationX;
	if ( CPTDecimalGreaterThanOrEqualTo( oldRangeX.length, CPTDecimalFromInteger( 0 ) ) ) {
		NSDecimal oldFirstLengthX = CPTDecimalSubtract( plotInteractionPoint[CPTCoordinateX], oldRangeX.minLimit ); // x - minX
		NSDecimal newFirstLengthX = CPTDecimalDivide( oldFirstLengthX, decimalScale );                              // (x - minX) / scale
		newLocationX = CPTDecimalSubtract( plotInteractionPoint[CPTCoordinateX], newFirstLengthX );
	}
	else {
		NSDecimal oldSecondLengthX = CPTDecimalSubtract( oldRangeX.maxLimit, plotInteractionPoint[0] ); // maxX - x
		NSDecimal newSecondLengthX = CPTDecimalDivide( oldSecondLengthX, decimalScale );                // (maxX - x) / scale
		newLocationX = CPTDecimalAdd( plotInteractionPoint[CPTCoordinateX], newSecondLengthX );
	}

	NSDecimal newLocationY;
	if ( CPTDecimalGreaterThanOrEqualTo( oldRangeY.length, CPTDecimalFromInteger( 0 ) ) ) {
		NSDecimal oldFirstLengthY = CPTDecimalSubtract( plotInteractionPoint[CPTCoordinateY], oldRangeY.minLimit ); // y - minY
		NSDecimal newFirstLengthY = CPTDecimalDivide( oldFirstLengthY, decimalScale );                              // (y - minY) / scale
		newLocationY = CPTDecimalSubtract( plotInteractionPoint[CPTCoordinateY], newFirstLengthY );
	}
	else {
		NSDecimal oldSecondLengthY = CPTDecimalSubtract( oldRangeY.maxLimit, plotInteractionPoint[1] ); // maxY - y
		NSDecimal newSecondLengthY = CPTDecimalDivide( oldSecondLengthY, decimalScale );                // (maxY - y) / scale
		newLocationY = CPTDecimalAdd( plotInteractionPoint[CPTCoordinateY], newSecondLengthY );
	}

	// New ranges
	CPTPlotRange *newRangeX = [[[CPTPlotRange alloc] initWithLocation:newLocationX length:newLengthX] autorelease];
	CPTPlotRange *newRangeY = [[[CPTPlotRange alloc] initWithLocation:newLocationY length:newLengthY] autorelease];

	// Delegate may still veto/modify the range
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

	if ( handledByDelegate ) {
		return YES;
	}

	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
		return NO;
	}

	CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
	if ( [self.graph.plotAreaFrame containsPoint:pointInPlotArea] ) {
		// Handle event
		lastDragPoint = pointInPlotArea;
		isDragging	  = YES;
		return YES;
	}

	return NO;
}

-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];

	if ( handledByDelegate ) {
		return YES;
	}

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

	if ( handledByDelegate ) {
		return YES;
	}

	if ( !self.allowsUserInteraction || !self.graph.plotAreaFrame ) {
		return NO;
	}

	if ( isDragging ) {
		CGPoint pointInPlotArea = [self.graph convertPoint:interactionPoint toLayer:self.graph.plotAreaFrame];
		CGPoint displacement	= CGPointMake( pointInPlotArea.x - lastDragPoint.x, pointInPlotArea.y - lastDragPoint.y );
		CGPoint pointToUse		= pointInPlotArea;

		// Allow delegate to override
		if ( [self.delegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
			displacement = [self.delegate plotSpace:self willDisplaceBy:displacement];
			pointToUse	 = CGPointMake( lastDragPoint.x + displacement.x, lastDragPoint.y + displacement.y );
		}

		NSDecimal lastPoint[2], newPoint[2];
		[self plotPoint:lastPoint forPlotAreaViewPoint:lastDragPoint];
		[self plotPoint:newPoint forPlotAreaViewPoint:pointToUse];

		CPTPlotRange *newRangeX = [[self.xRange copy] autorelease];
		CPTPlotRange *newRangeY = [[self.yRange copy] autorelease];

		NSDecimal shiftX = CPTDecimalSubtract( lastPoint[0], newPoint[0] );
		NSDecimal shiftY = CPTDecimalSubtract( lastPoint[1], newPoint[1] );
		newRangeX.location = CPTDecimalAdd( newRangeX.location, shiftX );
		newRangeY.location = CPTDecimalAdd( newRangeY.location, shiftY );

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
