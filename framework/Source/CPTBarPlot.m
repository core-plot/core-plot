#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTBarPlot.h"
#import "CPTXYPlotSpace.h"
#import "CPTColor.h"
#import "CPTMutableLineStyle.h"
#import "CPTFill.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTGradient.h"
#import "CPTUtilities.h"
#import "CPTExceptions.h"
#import "CPTTextLayer.h"
#import "CPTMutableTextStyle.h"
#import "CPTLegend.h"
#import "NSCoderExtensions.h"

/**	@defgroup plotAnimationBarPlot Bar Plot
 *	@ingroup plotAnimation
 **/

/**	@if MacOnly
 *	@defgroup plotBindingsBarPlot Bar Plot Bindings
 *	@ingroup plotBindings
 *	@endif
 **/

NSString * const CPTBarPlotBindingBarLocations = @"barLocations";	///< Bar locations.
NSString * const CPTBarPlotBindingBarTips = @"barTips";				///< Bar tips.
NSString * const CPTBarPlotBindingBarBases = @"barBases";			///< Bar bases.

/**	@cond */
@interface CPTBarPlot ()

@property (nonatomic, readwrite, copy) NSArray *barLocations;
@property (nonatomic, readwrite, copy) NSArray *barLengths;
@property (nonatomic, readwrite, copy) NSArray *barBases;

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)recordIndex;
-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint;
-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index;

-(CGFloat)lengthInView:(NSDecimal)plotLength;

-(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint;

@end
/**	@endcond */

#pragma mark -

/** @brief A two-dimensional bar plot.
 **/
@implementation CPTBarPlot

@dynamic barLocations;
@dynamic barLengths;
@dynamic barBases;

/** @property barCornerRadius
 *	@brief The corner radius for the end of the bars.
 *	@ingroup plotAnimationBarPlot
 **/
@synthesize barCornerRadius;

/** @property barOffset
 *	@brief The starting offset of the first bar in location data units.
 **/
@synthesize barOffset;

/** @property barOffsetScale
 *	@brief An animatable scaling factor for the bar offset. Default is 1.0.
 *	@ingroup plotAnimationBarPlot
 **/
@synthesize barOffsetScale;

/** @property barWidthsAreInViewCoordinates
 *  @brief Whether the bar width and bar offset is in view coordinates, or in plot coordinates.
 *  Default is NO, meaning plot coordinates are used.
 **/
@synthesize barWidthsAreInViewCoordinates;

/** @property barWidth
 *	@brief The width of each bar. Either view or plot coordinates can be used.
 *
 *	With plot coordinates, the bar locations are one data unit apart (e.g., 1, 2, 3, etc.), 
 *  a value of 1.0 will result in bars that touch each other; a value of 0.5 will result in bars that are as wide 
 *  as the gap between them.
 *
 *	@see barWidthsAreInViewCoordinates
 **/
@synthesize barWidth;

/** @property barWidthScale
 *	@brief An animatable scaling factor for the bar width. Default is 1.0.
 *	@ingroup plotAnimationBarPlot
 **/
@synthesize barWidthScale;

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
 *  This is only used if barsHaveVariableBases is NO. Otherwise, the data source
 *  will be queried for an appropriate value of CPTBarPlotFieldBarBase.
 **/
@synthesize baseValue;

/** @property barBasesVary
 *  @brief If YES, a constant base value is used for all bars (baseValue).
 *  If NO, the data source is queried to supply a base value for each bar.
 **/
@synthesize barBasesVary;

/** @property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	If a plot range is provided, the bars are spaced evenly throughout the plot range. If plotRange is nil,
 *	bar locations are provided by Cocoa bindings or the bar plot datasource. If locations are not provided by
 *	either bindings or the datasource, the first bar will be placed at zero (0) and subsequent bars will be at
 *	successive positive integer coordinates.
 **/
@synthesize plotRange;

#pragma mark -
#pragma mark Convenience Factory Methods

/** @brief Creates and returns a new CPTBarPlot instance initialized with a bar fill consisting of a linear gradient between black and the given color.
 *	@param color The beginning color.
 *	@param horizontal If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 *	@return A new CPTBarPlot instance initialized with a linear gradient bar fill.
 **/
+(CPTBarPlot *)tubularBarPlotWithColor:(CPTColor *)color horizontalBars:(BOOL)horizontal
{
	CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPTColor blackColor];
	barPlot.lineStyle = barLineStyle;
	[barLineStyle release];
	barPlot.barsAreHorizontal = horizontal;
	barPlot.barWidth = CPTDecimalFromDouble(0.8);
    barPlot.barWidthsAreInViewCoordinates = NO;
	barPlot.barCornerRadius = 2.0;
	CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];
	fillGradient.angle = (horizontal ? -90.0 : 0.0);
	barPlot.fill = [CPTFill fillWithGradient:fillGradient];
	return [barPlot autorelease];
}

#pragma mark -
#pragma mark Initialization

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPTBarPlot class] ) {
		[self exposeBinding:CPTBarPlotBindingBarLocations];
		[self exposeBinding:CPTBarPlotBindingBarTips];
		[self exposeBinding:CPTBarPlotBindingBarBases];
	}
}
#endif

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		lineStyle = [[CPTLineStyle alloc] init];
		fill = [[CPTFill fillWithColor:[CPTColor blackColor]] retain];
		barWidth = CPTDecimalFromDouble(0.5);
		barWidthScale = 1.0;
        barWidthsAreInViewCoordinates = NO;
		barOffset = CPTDecimalFromDouble(0.0);
		barOffsetScale = 1.0;
		barCornerRadius = 0.0;
		baseValue = CPTDecimalFromInteger(0);
		barsAreHorizontal = NO;
        barBasesVary = NO;
		plotRange = nil;
        
		self.labelOffset = 10.0;
		self.labelField = CPTBarPlotFieldBarTip;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTBarPlot *theLayer = (CPTBarPlot *)layer;
		
		lineStyle = [theLayer->lineStyle retain];
		fill = [theLayer->fill retain];
		barWidth = theLayer->barWidth;
		barWidthScale = theLayer->barWidthScale;
        barWidthsAreInViewCoordinates = theLayer->barWidthsAreInViewCoordinates;
		barOffset = theLayer->barOffset;
		barOffsetScale = theLayer->barOffsetScale;
		barCornerRadius = theLayer->barCornerRadius;
		baseValue = theLayer->baseValue;
        barBasesVary = theLayer->barBasesVary;
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

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	
	[coder encodeObject:self.lineStyle forKey:@"CPTBarPlot.lineStyle"];
	[coder encodeObject:self.fill forKey:@"CPTBarPlot.fill"];
	[coder encodeDecimal:self.barWidth forKey:@"CPTBarPlot.barWidth"];
	[coder encodeCGFloat:self.barWidthScale forKey:@"CPTBarPlot.barWidthScale"];
	[coder encodeDecimal:self.barOffset forKey:@"CPTBarPlot.barOffset"];
	[coder encodeCGFloat:self.barOffsetScale forKey:@"CPTBarPlot.barOffsetScale"];
	[coder encodeCGFloat:self.barCornerRadius forKey:@"CPTBarPlot.barCornerRadius"];
	[coder encodeDecimal:self.baseValue forKey:@"CPTBarPlot.baseValue"];
	[coder encodeBool:self.barsAreHorizontal forKey:@"CPTBarPlot.barsAreHorizontal"];
	[coder encodeBool:self.barBasesVary forKey:@"CPTBarPlot.barBasesVary"];
	[coder encodeBool:self.barWidthsAreInViewCoordinates forKey:@"CPTBarPlot.barWidthsAreInViewCoordinates"];
	[coder encodeObject:self.plotRange forKey:@"CPTBarPlot.plotRange"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
		lineStyle = [[coder decodeObjectForKey:@"CPTBarPlot.lineStyle"] copy];
		fill = [[coder decodeObjectForKey:@"CPTBarPlot.fill"] copy];
		barWidth = [coder decodeDecimalForKey:@"CPTBarPlot.barWidth"];
		barWidthScale = [coder decodeCGFloatForKey:@"CPTBarPlot.barWidthScale"];
		barOffset = [coder decodeDecimalForKey:@"CPTBarPlot.barOffset"];
		barOffsetScale = [coder decodeCGFloatForKey:@"CPTBarPlot.barOffsetScale"];
		barCornerRadius = [coder decodeCGFloatForKey:@"CPTBarPlot.barCornerRadius"];
		baseValue = [coder decodeDecimalForKey:@"CPTBarPlot.baseValue"];
		barsAreHorizontal = [coder decodeBoolForKey:@"CPTBarPlot.barsAreHorizontal"];
		barBasesVary = [coder decodeBoolForKey:@"CPTBarPlot.barBasesVary"];
		barWidthsAreInViewCoordinates = [coder decodeBoolForKey:@"CPTBarPlot.barWidthsAreInViewCoordinates"];
		plotRange = [[coder decodeObjectForKey:@"CPTBarPlot.plotRange"] copy];
	}
    return self;
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
	[super reloadDataInIndexRange:indexRange];
	
	// Bar lengths
	if ( self.dataSource ) {
		id newBarLengths = [self numbersFromDataSourceForField:CPTBarPlotFieldBarTip recordIndexRange:indexRange];
		[self cacheNumbers:newBarLengths forField:CPTBarPlotFieldBarTip atRecordIndex:indexRange.location];
		if ( self.barBasesVary ) {
			id newBarBases = [self numbersFromDataSourceForField:CPTBarPlotFieldBarBase recordIndexRange:indexRange];
			[self cacheNumbers:newBarBases forField:CPTBarPlotFieldBarBase atRecordIndex:indexRange.location];
		}
		else {
			self.barBases = nil;
		}
	}
	else {
		self.barLengths = nil;
		self.barBases = nil;
	}

	// Locations of bars
	if ( self.plotRange ) {
		// Spread bars evenly over the plot range
		CPTMutableNumericData *locationData = nil;
		if ( self.doublePrecisionCache ) {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];
			
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
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
																shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];
			
			NSDecimal delta = CPTDecimalFromInteger(1);
			if ( indexRange.length > 1 ) {
				delta = CPTDecimalDivide(self.plotRange.length, CPTDecimalFromUnsignedInteger(indexRange.length - 1));
			}

			NSDecimal locationDecimal = self.plotRange.location;
			NSDecimal *dataBytes = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDecimal;
				locationDecimal = CPTDecimalAdd(locationDecimal, delta);
			}
		}
		[self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
		[locationData release];
	}
	else if ( self.dataSource ) {
		// Get locations from the datasource
		id newBarLocations = [self numbersFromDataSourceForField:CPTBarPlotFieldBarLocation recordIndexRange:indexRange];
		[self cacheNumbers:newBarLocations forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
	}
	else {
		// Make evenly spaced locations starting at zero
		CPTMutableNumericData *locationData = nil;
		if ( self.doublePrecisionCache ) {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
																shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];
			
			double locationDouble = 0.0;
			double *dataBytes = (double *)locationData.mutableBytes;
			double *dataEnd = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDouble;
				locationDouble += 1.0;
			}
		}
		else {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															 dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
																shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

			NSDecimal locationDecimal = CPTDecimalFromInteger(0);
			NSDecimal *dataBytes = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd = dataBytes + indexRange.length;
			NSDecimal one = CPTDecimalFromInteger(1);
			while ( dataBytes < dataEnd ) {
				*dataBytes++ = locationDecimal;
				locationDecimal = CPTDecimalAdd(locationDecimal, one);
			}
		}
		[self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
		[locationData release];
	}
}

#pragma mark -
#pragma mark Length Conversions for Independent Coordinate (e.g., widths, offsets)

-(CGFloat)lengthInView:(NSDecimal)decimalLength
{
    CPTCoordinate coordinate = ( self.barsAreHorizontal ? CPTCoordinateY : CPTCoordinateX );
    CGFloat length;
    if ( !self.barWidthsAreInViewCoordinates ) {
        NSDecimal originPlotPoint[2] = {CPTDecimalFromInteger(0), CPTDecimalFromInteger(0)};
        NSDecimal displacedPlotPoint[2] = {decimalLength, decimalLength};
		CPTPlotSpace *thePlotSpace = self.plotSpace;
        CGPoint originPoint = [thePlotSpace plotAreaViewPointForPlotPoint:originPlotPoint];
        CGPoint displacedPoint = [thePlotSpace plotAreaViewPointForPlotPoint:displacedPlotPoint];
		length = ( coordinate == CPTCoordinateX ? displacedPoint.x - originPoint.x : displacedPoint.y - originPoint.y );
    }
    else {
        length = CPTDecimalCGFloatValue(decimalLength);
    }
    return length;
}

-(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength
{
    double length;
    if ( self.barWidthsAreInViewCoordinates ) {
    	CGFloat floatLength = CPTDecimalCGFloatValue(decimalLength);
        CGPoint originViewPoint = CGPointZero;
        CGPoint displacedViewPoint = CGPointMake(floatLength, floatLength);
        double originPlotPoint[2], displacedPlotPoint[2];
		CPTPlotSpace *thePlotSpace = self.plotSpace;
        [thePlotSpace doublePrecisionPlotPoint:originPlotPoint forPlotAreaViewPoint:originViewPoint];
        [thePlotSpace doublePrecisionPlotPoint:displacedPlotPoint forPlotAreaViewPoint:displacedViewPoint];
		length = ( !self.barsAreHorizontal ? displacedPlotPoint[0] - originPlotPoint[0] : displacedPlotPoint[1] - originPlotPoint[1]);
    }
    else {
        length = CPTDecimalDoubleValue(decimalLength);
    }
	return length;
}

-(NSDecimal)lengthInPlotCoordinates:(NSDecimal)decimalLength
{
    NSDecimal length;
    if ( self.barWidthsAreInViewCoordinates ) {
    	CGFloat floatLength = CPTDecimalCGFloatValue(decimalLength);
        CGPoint originViewPoint = CGPointZero;
        CGPoint displacedViewPoint = CGPointMake(floatLength, floatLength);
        NSDecimal originPlotPoint[2], displacedPlotPoint[2];
		CPTPlotSpace *thePlotSpace = self.plotSpace;
        [thePlotSpace plotPoint:originPlotPoint forPlotAreaViewPoint:originViewPoint];
        [thePlotSpace plotPoint:displacedPlotPoint forPlotAreaViewPoint:displacedViewPoint];
        if ( !self.barsAreHorizontal ) {
        	length = CPTDecimalSubtract(displacedPlotPoint[0], originPlotPoint[0]);
        }
        else {
            length = CPTDecimalSubtract(displacedPlotPoint[1], originPlotPoint[1]);
        }
    }
    else {
        length = decimalLength;
    }
    return length;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) return;
	
	CPTMutableNumericData *cachedLocations = [self cachedNumbersForField:CPTBarPlotFieldBarLocation];
	CPTMutableNumericData *cachedLengths = [self cachedNumbersForField:CPTBarPlotFieldBarTip];
	if ( cachedLocations == nil || cachedLengths == nil ) return;

	BOOL basesVary = self.barBasesVary;
	CPTMutableNumericData *cachedBases = [self cachedNumbersForField:CPTBarPlotFieldBarBase];
	if ( basesVary && cachedBases == nil ) return;
	
	NSUInteger barCount = self.cachedDataCount;
    if ( barCount == 0 ) return;
	
	if ( cachedLocations.numberOfSamples != cachedLengths.numberOfSamples ) {
		[NSException raise:CPTException format:@"Number of bar locations and lengths do not match"];
	};
	
	if ( basesVary && cachedLengths.numberOfSamples != cachedBases.numberOfSamples ) {
		[NSException raise:CPTException format:@"Number of bar lengths and bases do not match"];
	};

	[super renderAsVectorInContext:theContext];
	
    for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
        // Draw
        [self drawBarInContext:theContext recordIndex:ii];
    }   
}

-(BOOL)barAtRecordIndex:(NSUInteger)index basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint
{    
    BOOL horizontalBars = self.barsAreHorizontal;
    CPTCoordinate independentCoord = ( horizontalBars ? CPTCoordinateY : CPTCoordinateX );
    CPTCoordinate dependentCoord = ( horizontalBars ? CPTCoordinateX : CPTCoordinateY );
	
	CPTPlotSpace *thePlotSpace = self.plotSpace;
	CPTPlotArea *thePlotArea = self.plotArea;
    
    if ( self.doublePrecisionCache ) {
		double plotPoint[2];
		plotPoint[independentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarLocation recordIndex:index];
		if ( isnan(plotPoint[independentCoord]) ) return NO;
		
		// Tip point
		plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarTip recordIndex:index];
		if ( isnan(plotPoint[dependentCoord]) ) return NO;
		*tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
		
		// Base point
		if ( !self.barBasesVary ) {
			plotPoint[dependentCoord] = CPTDecimalDoubleValue(self.baseValue);
		}
		else {
			plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarBase recordIndex:index];
		}
		if ( isnan(plotPoint[dependentCoord]) ) return NO;
		*basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
	}
	else {
		NSDecimal plotPoint[2];
		plotPoint[independentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarLocation recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) return NO;
		
		// Tip point
		plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarTip recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) return NO;
		*tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
		
		// Base point
		if ( !self.barBasesVary ) {
			plotPoint[dependentCoord] = self.baseValue;
		}
		else {
			plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:index];
		}
		if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) return NO;
		*basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
	}
    
    // Determine bar width and offset. 
    CGFloat barOffsetLength = [self lengthInView:self.barOffset] * self.barOffsetScale;
    
	// Offset
	if ( horizontalBars ) {
		basePoint->y += barOffsetLength;
		tipPoint->y += barOffsetLength;
	}
	else {
		basePoint->x += barOffsetLength;
		tipPoint->x += barOffsetLength;
	}
    
	return YES;    
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)recordIndex {
	// Get base and tip points
    CGPoint basePoint, tipPoint;
    BOOL barExists = [self barAtRecordIndex:recordIndex basePoint:&basePoint tipPoint:&tipPoint];
    if ( !barExists ) return NULL;
    
	CGMutablePathRef path = [self newBarPathWithContext:context basePoint:basePoint tipPoint:tipPoint];
    
    return path;
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint
{		
	BOOL horizontalBars = self.barsAreHorizontal;
	
	// This function is used to create a path which is used for both
	// drawing a bar and for doing hit-testing on a click/touch event
    CPTCoordinate widthCoordinate = ( horizontalBars ? CPTCoordinateY : CPTCoordinateX );
    CGFloat barWidthLength = [self lengthInView:self.barWidth] * self.barWidthScale;
	CGFloat halfBarWidth = (CGFloat)0.5 * barWidthLength;
	
    CGFloat point[2];
    point[CPTCoordinateX] = basePoint.x;
    point[CPTCoordinateY] = basePoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);
	if ( context ) {
		// may not have a context if doing hit testing
		alignedPoint1 = CPTAlignPointToUserSpace(context, alignedPoint1);
	}	
    
    point[CPTCoordinateX] = tipPoint.x;
    point[CPTCoordinateY] = tipPoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);
	if ( context ) {
		alignedPoint2 = CPTAlignPointToUserSpace(context, alignedPoint2);
	}	
	
    point[CPTCoordinateX] = tipPoint.x;
    point[CPTCoordinateY] = tipPoint.y;
	CGPoint alignedPoint3 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);
	if ( context ) {
		alignedPoint3 = CPTAlignPointToUserSpace(context, alignedPoint3);
	}	
	
    point[CPTCoordinateX] = tipPoint.x;
    point[CPTCoordinateY] = tipPoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);
	if ( context ) {
		alignedPoint4 = CPTAlignPointToUserSpace(context, alignedPoint4);
	}	
    
    point[CPTCoordinateX] = basePoint.x;
    point[CPTCoordinateY] = basePoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);
	if ( context ) {
		alignedPoint5 = CPTAlignPointToUserSpace(context, alignedPoint5);
	}	
	
	CGFloat radius = MIN(self.barCornerRadius, halfBarWidth);
	if ( horizontalBars ) {
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

-(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint
{
	BOOL horizontalBars = self.barsAreHorizontal;
    CGFloat barWidthLength = [self lengthInView:self.barWidth] * self.barWidthScale;
	CGFloat halfBarWidth = (CGFloat)0.5 * barWidthLength;
    
    CPTPlotArea *thePlotArea = self.plotArea;
	
    CGFloat lowerBound = ( horizontalBars ? CGRectGetMinY(thePlotArea.bounds) : CGRectGetMinX(thePlotArea.bounds) );
    CGFloat upperBound = ( horizontalBars ? CGRectGetMaxY(thePlotArea.bounds) : CGRectGetMaxX(thePlotArea.bounds) );
    CGFloat base = ( horizontalBars ? basePoint.y : basePoint.x );
    
    return ( base + halfBarWidth > lowerBound ) && ( base - halfBarWidth < upperBound );
}

-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index
{    
	// Get base and tip points
    CGPoint basePoint, tipPoint;
    BOOL barExists = [self barAtRecordIndex:index basePoint:&basePoint tipPoint:&tipPoint];
    if ( !barExists ) return;
    
    // Return if bar is off screen
	if ( ![self barIsVisibleWithBasePoint:basePoint] ) return;
    
	CGMutablePathRef path = [self newBarPathWithContext:context basePoint:basePoint tipPoint:tipPoint];
	
	if ( path ) {
		CGContextSaveGState(context);
		
		id <CPTBarPlotDataSource> theDataSource = (id <CPTBarPlotDataSource>)self.dataSource;
		
		CPTFill *theBarFill = self.fill;
		if ( [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
			CPTFill *dataSourceFill = [theDataSource barFillForBarPlot:self recordIndex:index];
			if ( dataSourceFill ) theBarFill = dataSourceFill;
		}
		if ( [theBarFill isKindOfClass:[CPTFill class]] ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[theBarFill fillPathInContext:context]; 
		}
		
		CPTLineStyle *theLineStyle = self.lineStyle;
		if ( [theDataSource respondsToSelector:@selector(barLineStyleForBarPlot:recordIndex:)] ) {
			CPTLineStyle *dataSourceLineStyle = [theDataSource barLineStyleForBarPlot:self recordIndex:index];
			if ( dataSourceLineStyle ) theLineStyle = dataSourceLineStyle;
		}
		if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[theLineStyle setLineStyleInContext:context];
			CGContextStrokePath(context);
		}
		
		CGContextRestoreGState(context);
		
		CGPathRelease(path);
	}
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)index inRect:(CGRect)rect inContext:(CGContextRef)context
{
	[super drawSwatchForLegend:legend atIndex:index inRect:rect inContext:context];
	
	CPTFill *theFill = self.fill;
	CPTLineStyle *theLineStyle = self.lineStyle;
	
	if ( theFill || theLineStyle ) {
		CGPathRef swatchPath;
		CGFloat radius = self.barCornerRadius;
		if ( radius > 0.0 ) {
			radius = MIN(MIN(radius, rect.size.width / (CGFloat)2.0), rect.size.height / (CGFloat)2.0);
			swatchPath = CreateRoundedRectPath(rect, radius);
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect(mutablePath, NULL, rect);
			swatchPath = mutablePath;
		}
		
		if ( theFill ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, swatchPath);
			[theFill fillPathInContext:context];
		}
		
		if ( theLineStyle ) {
			[theLineStyle setLineStyleInContext:context];
			CGContextBeginPath(context);
			CGContextAddPath(context, swatchPath);
			CGContextStrokePath(context);
		}
		
		CGPathRelease(swatchPath);
	}
}

#pragma mark -
#pragma mark Animation

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
	static NSArray *keys = nil;
	
	if ( !keys ) {
		keys = [[NSArray alloc] initWithObjects:
				@"barCornerRadius",
				@"barOffsetScale", 
				@"barWidthScale", 
				nil];
	}
	
	if ( [keys containsObject:aKey] ) {
		return YES;
	}
	else {
		return [super needsDisplayForKey:aKey];
	}
}

#pragma mark -
#pragma mark Data Labels

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	NSDecimal theBaseDecimalValue;
	if ( !self.barBasesVary ) {
		theBaseDecimalValue = self.baseValue;
	}
	else {
		theBaseDecimalValue = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:index];
	}
	
	NSNumber *location = [self cachedNumberForField:CPTBarPlotFieldBarLocation recordIndex:index];
	NSNumber *length = [self cachedNumberForField:CPTBarPlotFieldBarTip recordIndex:index];
	
	BOOL positiveDirection = CPTDecimalGreaterThanOrEqualTo([length decimalValue], theBaseDecimalValue);
	BOOL horizontalBars = self.barsAreHorizontal;
	CPTPlotRange *lengthRange = [self.plotSpace plotRangeForCoordinate:horizontalBars ? CPTCoordinateX : CPTCoordinateY];
	if ( CPTDecimalLessThan(lengthRange.length, CPTDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}

	NSNumber *offsetLocation;
	if ( self.doublePrecisionCache ) {
		offsetLocation = [NSNumber numberWithDouble:([location doubleValue] + [self doubleLengthInPlotCoordinates:self.barOffset] * self.barOffsetScale)];
	}
	else {
		NSDecimal decimalLocation = [location decimalValue];
		NSDecimal offset = CPTDecimalMultiply([self lengthInPlotCoordinates:self.barOffset], CPTDecimalFromCGFloat(self.barOffsetScale));
		offsetLocation = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalAdd(decimalLocation, offset)];
	}
	
	// Offset
	if ( horizontalBars ) {
		label.anchorPlotPoint = [NSArray arrayWithObjects:length, offsetLocation, nil];
		
		if ( positiveDirection ) {
			label.displacement = CGPointMake(self.labelOffset, 0.0);
		}
		else {
			label.displacement = CGPointMake(-self.labelOffset, 0.0);
		}
	}
	else {
		label.anchorPlotPoint = [NSArray arrayWithObjects:offsetLocation, length, nil];
		
		if ( positiveDirection ) {
			label.displacement = CGPointMake(0.0, self.labelOffset);
		}
		else {
			label.displacement = CGPointMake(0.0, -self.labelOffset);
		}
	}

	label.contentLayer.hidden = isnan([location doubleValue]) || isnan([length doubleValue]);
}

#pragma mark -
#pragma mark Responder Chain and User interaction

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;
	CPTGraph *theGraph = self.graph;
	CPTPlotArea *thePlotArea = self.plotArea;
	if ( !theGraph || !thePlotArea ) return NO;
	
	id <CPTBarPlotDelegate> theDelegate = self.delegate;
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
    return [[self cachedNumbersForField:CPTBarPlotFieldBarTip] sampleArray];
}

-(void)setBarLengths:(NSArray *)newLengths 
{
    [self cacheNumbers:newLengths forField:CPTBarPlotFieldBarTip];
}

-(NSArray *)barBases {
    return [[self cachedNumbersForField:CPTBarPlotFieldBarBase] sampleArray];
}

-(void)setBarBases:(NSArray *)newBases 
{
    [self cacheNumbers:newBases forField:CPTBarPlotFieldBarBase];
}

-(NSArray *)barLocations {
    return [[self cachedNumbersForField:CPTBarPlotFieldBarLocation] sampleArray];
}

-(void)setBarLocations:(NSArray *)newLocations 
{
    [self cacheNumbers:newLocations forField:CPTBarPlotFieldBarLocation];
}

-(void)setLineStyle:(CPTLineStyle *)newLineStyle 
{
    if (lineStyle != newLineStyle) {
        [lineStyle release];
        lineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setFill:(CPTFill *)newFill 
{
    if (fill != newFill) {
        [fill release];
        fill = [newFill copy];
        [self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setBarWidth:(NSDecimal)newBarWidth
{
	if ( NSDecimalCompare(&barWidth, &newBarWidth) != NSOrderedSame ) {
		barWidth = newBarWidth;
		[self setNeedsDisplay];
	}
}

-(void)setBarWidthScale:(CGFloat)newBarWidthScale
{
	if ( barWidthScale != newBarWidthScale ) {
		barWidthScale = newBarWidthScale;
		[self setNeedsDisplay];
	}
}

-(void)setBarOffset:(NSDecimal)newBarOffset 
{
	if ( NSDecimalCompare(&barOffset, &newBarOffset) != NSOrderedSame ) {
		barOffset = newBarOffset;
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

-(void)setBarOffsetScale:(CGFloat)newBarOffsetScale
{
	if ( barOffsetScale != newBarOffsetScale ) {
		barOffsetScale = newBarOffsetScale;
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

-(void)setBarCornerRadius:(CGFloat)newCornerRadius 
{
    if ( barCornerRadius != newCornerRadius) {
        barCornerRadius = ABS(newCornerRadius);
        [self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setBaseValue:(NSDecimal)newBaseValue 
{
	if ( !CPTDecimalEquals(baseValue, newBaseValue) ) {
		baseValue = newBaseValue;
		[self setNeedsDisplay];
        [self setNeedsLayout];
	}
}

-(void)setBarBasesVary:(BOOL)newBasesVary
{
    if ( newBasesVary != barBasesVary ) {
        barBasesVary = newBasesVary;
        [self setDataNeedsReloading];
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

#pragma mark -
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 2;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarLocation], [NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip], nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPTCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPTBarPlotFieldBarTip : CPTBarPlotFieldBarLocation)]];
            break;
        case CPTCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPTBarPlotFieldBarLocation : CPTBarPlotFieldBarTip)]];
            break;
        default:
        	[NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

@end
