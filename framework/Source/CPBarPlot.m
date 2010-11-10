#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "CPBarPlot.h"
#import "CPXYPlotSpace.h"
#import "CPColor.h"
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotArea.h"
#import "CPPlotRange.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPGradient.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"

NSString * const CPBarPlotBindingBarLocations = @"barLocations";	///< Bar locations.
NSString * const CPBarPlotBindingBarLengths = @"barLengths";		///< Bar lengths.

/// @cond
@interface CPBarPlot ()

@property (nonatomic, readwrite, copy) NSArray *barLocations;
@property (nonatomic, readwrite, copy) NSArray *barLengths;

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)index;
-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index;

@end
/// @endcond

#pragma mark -

/** @brief A two-dimensional bar plot.
 **/
@implementation CPBarPlot

@dynamic barLocations;
@dynamic barLengths;

/** @property cornerRadius
 *	@brief The corner radius for the end of the bars.
 **/
@synthesize cornerRadius;

/** @property barOffset
 *	@brief The starting offset of the first bar in units of bar width.
 **/
@synthesize barOffset;

/** @property barWidth
 *	@brief The width of each bar.
 **/
@synthesize barWidth;

/** @property lineStyle
 *	@brief The line style for the bar outline.
 *	If nil, the outline is not drawn.
 **/
@synthesize lineStyle;

/** @property fill 
 *	@brief The fill style for the bars.
 *	If nil, the bars are not filled.
 **/
@synthesize fill;

/** @property barsAreHorizontal
 *	@brief If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 **/
@synthesize barsAreHorizontal;

/** @property baseValue
 *	@brief The coordinate value of the fixed end of the bars.
 **/
@synthesize baseValue;

/** @property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	If a plot range is provided, the bars are spaced evenly throughout the plot range. If plotRange is nil,
 *	bar locations are provided by Cocoa bindings or the bar plot datasource. If locations are not provided by
 *	either bindings or the datasource, the first bar will be placed at zero (0) and subsequent bars will be at
 *	successive positive integer coordinates.
 **/
@synthesize plotRange;

/** @property barLabelOffset
 *  @brief Sets the offset of the value label above the bar
 *	@deprecated This property has been replaced by the CPPlot::labelOffset property.
 **/
@dynamic barLabelOffset;

/** @property barLabelTextStyle
 *  @brief Sets the textstyle of the value label above the bar
 *	@deprecated This property has been replaced by the CPPlot::labelTextStyle property.
 **/
@dynamic barLabelTextStyle;

#pragma mark -
#pragma mark Convenience Factory Methods

/** @brief Creates and returns a new CPBarPlot instance initialized with a bar fill consisting of a linear gradient between black and the given color.
 *	@param color The beginning color.
 *	@param horizontal If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 *	@return A new CPBarPlot instance initialized with a linear gradient bar fill.
 **/
+(CPBarPlot *)tubularBarPlotWithColor:(CPColor *)color horizontalBars:(BOOL)horizontal
{
	CPBarPlot *barPlot = [[CPBarPlot alloc] init];
	CPLineStyle *barLineStyle = [[CPLineStyle alloc] init];
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPColor blackColor];
	barPlot.lineStyle = barLineStyle;
	[barLineStyle release];
	barPlot.barsAreHorizontal = horizontal;
	barPlot.barWidth = 10.0;
	barPlot.cornerRadius = 2.0;
	CPGradient *fillGradient = [CPGradient gradientWithBeginningColor:color endingColor:[CPColor blackColor]];
	fillGradient.angle = (horizontal ? -90.0 : 0.0);
	barPlot.fill = [CPFill fillWithGradient:fillGradient];
	return [barPlot autorelease];
}

#pragma mark -
#pragma mark Initialization

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPBarPlot class] ) {
		[self exposeBinding:CPBarPlotBindingBarLocations];
		[self exposeBinding:CPBarPlotBindingBarLengths];
	}
}
#endif

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		lineStyle = [[CPLineStyle alloc] init];
		lineStyle.delegate = self;
		fill = [[CPFill fillWithColor:[CPColor blackColor]] retain];
		barWidth = 10.0;
		barOffset = 0.0;
		cornerRadius = 0.0;
		baseValue = [[NSDecimalNumber zero] decimalValue];
		barsAreHorizontal = NO;
		plotRange = nil;
        
		self.labelOffset = 10.0;
		self.labelField = CPBarPlotFieldBarLength;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPBarPlot *theLayer = (CPBarPlot *)layer;
		
		lineStyle = [theLayer->lineStyle retain];
		fill = [theLayer->fill retain];
		barWidth = theLayer->barWidth;
		barOffset = theLayer->barOffset;
		cornerRadius = theLayer->cornerRadius;
		baseValue = theLayer->baseValue;
		barsAreHorizontal = theLayer->barsAreHorizontal;
		plotRange = [theLayer->plotRange retain];
	}
	return self;
}

-(void)dealloc
{
	[lineStyle release];
	[fill release];
	[plotRange release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
	[super reloadDataInIndexRange:indexRange];
	
	// Bar lengths
	if ( self.dataSource ) {
		id newBarLengths = [self numbersFromDataSourceForField:CPBarPlotFieldBarLength recordIndexRange:indexRange];
		[self cacheNumbers:newBarLengths forField:CPBarPlotFieldBarLength atRecordIndex:indexRange.location];
	}
	else {
		self.barLengths = nil;
	}

	// Locations of bars
	if ( self.plotRange ) {
		// Spread bars evenly over the plot range
		CPMutableNumericData *locationData = nil;
		if ( self.doublePrecisionCache ) {
			locationData = [[CPMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																shape:nil];
			((NSMutableData *)locationData.data).length = indexRange.length * sizeof(double);
			
			double doublePrecisionDelta = 1.0;
			if ( indexRange.length > 1 ) {
				doublePrecisionDelta  = self.plotRange.lengthDouble / (double)(indexRange.length - 1);
			}
			
			double locationDouble = self.plotRange.locationDouble;
			double *dataBytes = (double *)locationData.mutableBytes;
			double *dataEnd = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDouble;
				locationDouble += doublePrecisionDelta;
			}
		}
		else {
			locationData = [[CPMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPDataType(CPDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
																shape:nil];
			((NSMutableData *)locationData.data).length = indexRange.length * sizeof(NSDecimal);
			
			NSDecimal delta = CPDecimalFromInteger(1);
			if ( indexRange.length > 1 ) {
				delta = CPDecimalDivide(self.plotRange.length, CPDecimalFromUnsignedInteger(indexRange.length - 1));
			}

			NSDecimal locationDecimal = self.plotRange.location;
			NSDecimal *dataBytes = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDecimal;
				locationDecimal = CPDecimalAdd(locationDecimal, delta);
			}
		}
		[self cacheNumbers:locationData forField:CPBarPlotFieldBarLocation atRecordIndex:indexRange.location];
		[locationData release];
	}
	else if ( self.dataSource ) {
		// Get locations from the datasource
		id newBarLocations = [self numbersFromDataSourceForField:CPBarPlotFieldBarLocation recordIndexRange:indexRange];
		[self cacheNumbers:newBarLocations forField:CPBarPlotFieldBarLocation atRecordIndex:indexRange.location];
	}
	else {
		// Make evenly spaced locations starting at zero
		CPMutableNumericData *locationData = nil;
		if ( self.doublePrecisionCache ) {
			locationData = [[CPMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																shape:nil];
			((NSMutableData *)locationData.data).length = indexRange.length * sizeof(double);
			
			double locationDouble = 0.0;
			double *dataBytes = (double *)locationData.mutableBytes;
			double *dataEnd = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDouble;
				locationDouble += 1.0;
			}
		}
		else {
			locationData = [[CPMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPDataType(CPDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
																shape:nil];
			((NSMutableData *)locationData.data).length = indexRange.length * sizeof(NSDecimal);
			
			NSDecimal locationDecimal = CPDecimalFromInteger(0);
			NSDecimal *dataBytes = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd = dataBytes + indexRange.length;
			NSDecimal one = CPDecimalFromInteger(1);
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDecimal;
				locationDecimal = CPDecimalAdd(locationDecimal, one);
			}
		}
		[self cacheNumbers:locationData forField:CPBarPlotFieldBarLocation atRecordIndex:indexRange.location];
		[locationData release];
	}
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	CPMutableNumericData *cachedLocations = [self cachedNumbersForField:CPBarPlotFieldBarLocation];
	CPMutableNumericData *cachedLengths = [self cachedNumbersForField:CPBarPlotFieldBarLength];
	if ( cachedLocations == nil || cachedLengths == nil ) return;
	
	NSUInteger barCount = self.cachedDataCount;
    if ( barCount == 0 ) return;
	
	if ( cachedLocations.numberOfSamples != cachedLengths.numberOfSamples ) {
		[NSException raise:CPException format:@"Number of bar locations and lengths do not match"];
	};
	
	[super renderAsVectorInContext:theContext];
	
    for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
        // Draw
        [self drawBarInContext:theContext recordIndex:ii];
    }   
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)index
{
	NSDecimal theBaseValue = self.baseValue;
	if ( NSDecimalIsNotANumber(&theBaseValue) ) return NULL;
		
    CGPoint tipPoint, basePoint;
	BOOL horizontalBars = self.barsAreHorizontal;
    CPCoordinate independentCoord = ( horizontalBars ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( horizontalBars ? CPCoordinateX : CPCoordinateY );
	
	CPPlotSpace *thePlotSpace = self.plotSpace;
	CPPlotArea *thePlotArea = self.plotArea;
	
	if ( self.doublePrecisionCache ) {
		double plotPoint[2];
		plotPoint[independentCoord] = [self cachedDoubleForField:CPBarPlotFieldBarLocation recordIndex:index];
		if ( isnan(plotPoint[independentCoord]) ) return NULL;
		
		// Tip point
		plotPoint[dependentCoord] = [self cachedDoubleForField:CPBarPlotFieldBarLength recordIndex:index];
		if ( isnan(plotPoint[dependentCoord]) ) return NULL;
		tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
		
		// Base point
		plotPoint[dependentCoord] = CPDecimalDoubleValue(theBaseValue);
		basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
	}
	else {
		NSDecimal plotPoint[2];
		plotPoint[independentCoord] = [self cachedDecimalForField:CPBarPlotFieldBarLocation recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) return NULL;
		
		// Tip point
		plotPoint[dependentCoord] = [self cachedDecimalForField:CPBarPlotFieldBarLength recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) return NULL;
		tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
		
		// Base point
		plotPoint[dependentCoord] = theBaseValue;
		basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
	}
	
	// Offset
	CGFloat viewOffset = self.barOffset * self.barWidth;
	if ( horizontalBars ) {
		basePoint.y += viewOffset;
		tipPoint.y += viewOffset;
	}
	else {
		basePoint.x += viewOffset;
		tipPoint.x += viewOffset;
	}
	
	// This function is used to create a path which is used for both
	// drawing a bar and for doing hit-testing on a click/touch event
    CPCoordinate widthCoordinate = ( horizontalBars ? CPCoordinateY : CPCoordinateX );
	CGFloat halfBarWidth = 0.5 * self.barWidth;
	
    CGFloat point[2];
    point[CPCoordinateX] = basePoint.x;
    point[CPCoordinateY] = basePoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if ( context ) {
		// may not have a context if doing hit testing
		alignedPoint1 = CPAlignPointToUserSpace(context, alignedPoint1);
	}	
    
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if ( context ) {
		alignedPoint2 = CPAlignPointToUserSpace(context, alignedPoint2);
	}	
	
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
	CGPoint alignedPoint3 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if ( context ) {
		alignedPoint3 = CPAlignPointToUserSpace(context, alignedPoint3);
	}	
	
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if ( context ) {
		alignedPoint4 = CPAlignPointToUserSpace(context, alignedPoint4);
	}	
    
    point[CPCoordinateX] = basePoint.x;
    point[CPCoordinateY] = basePoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if ( context ) {
		alignedPoint5 = CPAlignPointToUserSpace(context, alignedPoint5);
	}	
	
	CGFloat radius = MIN(self.cornerRadius, halfBarWidth);
	if ( self.barsAreHorizontal ) {
		radius = MIN(radius, ABS(tipPoint.x - basePoint.x));
	}
	else {
		radius = MIN(radius, ABS(tipPoint.y - basePoint.y));
	}
	
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
	CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
    CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
    CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
    CGPathCloseSubpath(path);
	
	return path;
}

-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index
{
	CGMutablePathRef path = [self newBarPathWithContext:context recordIndex:index];
	
	if ( path ) {
		CGContextSaveGState(context);
		
		// If data source returns nil, default fill is used.
		// If data source returns NSNull object, no fill is drawn.
		CPFill *currentBarFill = self.fill;
		if ( [self.dataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
			CPFill *dataSourceFill = [(id <CPBarPlotDataSource>)self.dataSource barFillForBarPlot:self recordIndex:index];
			if ( dataSourceFill ) currentBarFill = dataSourceFill;
		}
		if ( [currentBarFill isKindOfClass:[CPFill class]] ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[currentBarFill fillPathInContext:context]; 
		}
		
		CPLineStyle *theLineStyle = self.lineStyle;
		if ( theLineStyle ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[theLineStyle setLineStyleInContext:context];
			CGContextStrokePath(context);
		}
		
		CGContextRestoreGState(context);
		
		CGPathRelease(path);
	}
}

#pragma mark -
#pragma mark Data Labels

-(void)positionLabelAnnotation:(CPPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	NSNumber *location = [self cachedNumberForField:CPBarPlotFieldBarLocation recordIndex:index];
	NSNumber *length = [self cachedNumberForField:CPBarPlotFieldBarLength recordIndex:index];
	
	BOOL positiveDirection = CPDecimalGreaterThanOrEqualTo([length decimalValue], self.baseValue);
	CPPlotRange *lengthRange = [self.plotSpace plotRangeForCoordinate:self.barsAreHorizontal ? CPCoordinateX : CPCoordinateY];
	if ( CPDecimalLessThan(lengthRange.length, CPDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}
	CGFloat viewOffset = self.barOffset * self.barWidth;

	if ( self.barsAreHorizontal ) {
		label.anchorPlotPoint = [NSArray arrayWithObjects:length, location, nil];
		
		if ( positiveDirection ) {
			label.displacement = CGPointMake(self.labelOffset, viewOffset);
		}
		else {
			label.displacement = CGPointMake(-self.labelOffset, viewOffset);
		}
	}
	else {
		label.anchorPlotPoint = [NSArray arrayWithObjects:location, length, nil];
		
		if ( positiveDirection ) {
			label.displacement = CGPointMake(viewOffset, self.labelOffset);
		}
		else {
			label.displacement = CGPointMake(viewOffset, -self.labelOffset);
		}
	}

	label.contentLayer.hidden = isnan([location doubleValue]) || isnan([length doubleValue]);
}

#pragma mark -
#pragma mark Responder Chain and User interaction

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;
	CPGraph *theGraph = self.graph;
	CPPlotArea *thePlotArea = self.plotArea;
	if ( !theGraph || !thePlotArea ) return NO;
	
	id <CPBarPlotDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ) {
    	// Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
		
		NSUInteger barCount = self.cachedDataCount;
		
		for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
			CGMutablePathRef path = [self newBarPathWithContext:NULL recordIndex:ii];
			
			if ( CGPathContainsPoint(path, nil, plotAreaPoint, false) ) {
				[theDelegate barPlot:self barWasSelectedAtRecordIndex:ii];
				CGPathRelease(path);
				return YES;
			}
			
			CGPathRelease(path);			
		}   
    }
    else {
        result = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    }
    
	return result;
}


#pragma mark -
#pragma mark Accessors

-(NSArray *)barLengths {
    return [[self cachedNumbersForField:CPBarPlotFieldBarLength] sampleArray];
}

-(void)setBarLengths:(NSArray *)newLengths 
{
    [self cacheNumbers:newLengths forField:CPBarPlotFieldBarLength];
}

-(NSArray *)barLocations {
    return [[self cachedNumbersForField:CPBarPlotFieldBarLocation] sampleArray];
}

-(void)setBarLocations:(NSArray *)newLocations 
{
    [self cacheNumbers:newLocations forField:CPBarPlotFieldBarLocation];
}

-(void)setLineStyle:(CPLineStyle *)newLineStyle 
{
    if (lineStyle != newLineStyle) {
		lineStyle.delegate = nil;
        [lineStyle release];
        lineStyle = [newLineStyle copy];
		lineStyle.delegate = self;
        [self setNeedsDisplay];
    }
}

-(void)setFill:(CPFill *)newFill 
{
    if (fill != newFill) {
        [fill release];
        fill = [newFill copy];
        [self setNeedsDisplay];
    }
}

-(void)setBarWidth:(CGFloat)newBarWidth {
	if (barWidth != newBarWidth) {
		barWidth = ABS(newBarWidth);
		[self setNeedsDisplay];
	}
}

-(void)setBarOffset:(CGFloat)newBarOffset 
{
    if (barOffset != newBarOffset) {
        barOffset = newBarOffset;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

-(void)setCornerRadius:(CGFloat)newCornerRadius 
{
    if (cornerRadius != newCornerRadius) {
        cornerRadius = ABS(newCornerRadius);
        [self setNeedsDisplay];
    }
}

-(void)setBaseValue:(NSDecimal)newBaseValue 
{
	if ( !CPDecimalEquals(baseValue, newBaseValue) ) 
    {
		baseValue = newBaseValue;
		[self setNeedsDisplay];
        [self setNeedsLayout];
	}
}

-(void)setBarsAreHorizontal:(BOOL)newBarsAreHorizontal 
{
	if (barsAreHorizontal != newBarsAreHorizontal) {
		barsAreHorizontal = newBarsAreHorizontal;
		[self setNeedsDisplay];
        [self setNeedsLayout];
	}
}

-(CGFloat)barLabelOffset
{
	return self.labelOffset;
}

-(void)setBarLabelOffset:(CGFloat)newOffset 
{
    self.labelOffset = newOffset;
}

-(CPTextStyle *)barLabelTextStyle
{
	return self.labelTextStyle;
}

-(void)setBarLabelTextStyle:(CPTextStyle *)newStyle 
{
    self.labelTextStyle = newStyle;
}

#pragma mark -
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 2;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPBarPlotFieldBarLocation], [NSNumber numberWithUnsignedInt:CPBarPlotFieldBarLength], nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPBarPlotFieldBarLength : CPBarPlotFieldBarLocation)]];
            break;
        case CPCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPBarPlotFieldBarLocation : CPBarPlotFieldBarLength)]];
            break;
        default:
        	[NSException raise:CPException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

@end
