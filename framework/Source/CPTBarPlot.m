#import "CPTBarPlot.h"

#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTLegend.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTMutablePlotRange.h"
#import "CPTMutableTextStyle.h"
#import "CPTNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

/**	@defgroup plotAnimationBarPlot Bar Plot
 *	@ingroup plotAnimation
 **/

/**	@if MacOnly
 *	@defgroup plotBindingsBarPlot Bar Plot Bindings
 *	@ingroup plotBindings
 *	@endif
 **/

NSString *const CPTBarPlotBindingBarLocations = @"barLocations"; ///< Bar locations.
NSString *const CPTBarPlotBindingBarTips	  = @"barTips";      ///< Bar tips.
NSString *const CPTBarPlotBindingBarBases	  = @"barBases";     ///< Bar bases.

///	@cond
@interface CPTBarPlot()

@property (nonatomic, readwrite, copy) NSArray *barLocations;
@property (nonatomic, readwrite, copy) NSArray *barTips;
@property (nonatomic, readwrite, copy) NSArray *barBases;

-(BOOL)barAtRecordIndex:(NSUInteger)index basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint;
-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)recordIndex;
-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint;
-(CPTFill *)barFillForIndex:(NSUInteger)index;
-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index;

-(CGFloat)lengthInView:(NSDecimal)plotLength;
-(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength;

-(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint;

@end

///	@endcond

#pragma mark -

/**
 *	@brief A two-dimensional bar plot.
 *	@see See @ref plotAnimationBarPlot "Bar Plot" for a list of animatable properties.
 *	@if MacOnly
 *	@see See @ref plotBindingsBarPlot "Bar Plot Bindings" for a list of supported binding identifiers.
 *	@endif
 **/
@implementation CPTBarPlot

@dynamic barLocations;
@dynamic barTips;
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
 *	If <code>nil</code>, the outline is not drawn.
 **/
@synthesize lineStyle;

/** @property fill
 *	@brief The fill style for the bars.
 *	If <code>nil</code>, the bars are not filled.
 **/
@synthesize fill;

/** @property barsAreHorizontal
 *	@brief If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 **/
@synthesize barsAreHorizontal;

/** @property baseValue
 *	@brief The coordinate value of the fixed end of the bars.
 *  This is only used if @link CPTBarPlot::barBasesVary barBasesVary @endlink is NO. Otherwise, the data source
 *  will be queried for an appropriate value of #CPTBarPlotFieldBarBase.
 **/
@synthesize baseValue;

/** @property barBasesVary
 *  @brief If NO, a constant base value is used for all bars.
 *  If YES, the data source is queried to supply a base value for each bar.
 *	@see baseValue
 **/
@synthesize barBasesVary;

/** @property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	If a plot range is provided, the bars are spaced evenly throughout the plot range. If @link CPTBarPlot::plotRange plotRange @endlink is <code>nil</code>,
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
	CPTBarPlot *barPlot				  = [[CPTBarPlot alloc] init];
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];

	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPTColor blackColor];
	barPlot.lineStyle	   = barLineStyle;
	[barLineStyle release];
	barPlot.barsAreHorizontal			  = horizontal;
	barPlot.barWidth					  = CPTDecimalFromDouble(0.8);
	barPlot.barWidthsAreInViewCoordinates = NO;
	barPlot.barCornerRadius				  = 2.0;
	CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];
	fillGradient.angle = (horizontal ? -90.0 : 0.0);
	barPlot.fill	   = [CPTFill fillWithGradient:fillGradient];
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

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTBarPlot object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTBarPlot::lineStyle lineStyle @endlink = default line style
 *	- @link CPTBarPlot::fill fill @endlink = solid black fill
 *	- @link CPTBarPlot::barWidth barWidth @endlink = 0.5
 *	- @link CPTBarPlot::barWidthScale barWidthScale @endlink = 1.0
 *	- @link CPTBarPlot::barWidthsAreInViewCoordinates barWidthsAreInViewCoordinates @endlink = <code>NO</code>
 *	- @link CPTBarPlot::barOffset barOffset @endlink = 0.0
 *	- @link CPTBarPlot::barOffsetScale barOffsetScale @endlink = 1.0
 *	- @link CPTBarPlot::barCornerRadius barCornerRadius @endlink = 0.0
 *	- @link CPTBarPlot::baseValue baseValue @endlink = 0
 *	- @link CPTBarPlot::barsAreHorizontal barsAreHorizontal @endlink = <code>NO</code>
 *	- @link CPTBarPlot::barBasesVary barBasesVary @endlink = <code>NO</code>
 *	- @link CPTBarPlot::plotRange plotRange @endlink = <code>nil</code>
 *	- @link CPTPlot::labelOffset labelOffset @endlink = 10.0
 *	- @link CPTPlot::labelField labelField @endlink = #CPTBarPlotFieldBarTip
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTBarPlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		lineStyle					  = [[CPTLineStyle alloc] init];
		fill						  = [[CPTFill fillWithColor:[CPTColor blackColor]] retain];
		barWidth					  = CPTDecimalFromDouble(0.5);
		barWidthScale				  = 1.0;
		barWidthsAreInViewCoordinates = NO;
		barOffset					  = CPTDecimalFromDouble(0.0);
		barOffsetScale				  = 1.0;
		barCornerRadius				  = 0.0;
		baseValue					  = CPTDecimalFromInteger(0);
		barsAreHorizontal			  = NO;
		barBasesVary				  = NO;
		plotRange					  = nil;

		self.labelOffset = 10.0;
		self.labelField	 = CPTBarPlotFieldBarTip;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTBarPlot *theLayer = (CPTBarPlot *)layer;

		lineStyle					  = [theLayer->lineStyle retain];
		fill						  = [theLayer->fill retain];
		barWidth					  = theLayer->barWidth;
		barWidthScale				  = theLayer->barWidthScale;
		barWidthsAreInViewCoordinates = theLayer->barWidthsAreInViewCoordinates;
		barOffset					  = theLayer->barOffset;
		barOffsetScale				  = theLayer->barOffsetScale;
		barCornerRadius				  = theLayer->barCornerRadius;
		baseValue					  = theLayer->baseValue;
		barBasesVary				  = theLayer->barBasesVary;
		barsAreHorizontal			  = theLayer->barsAreHorizontal;
		plotRange					  = [theLayer->plotRange retain];
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
		lineStyle					  = [[coder decodeObjectForKey:@"CPTBarPlot.lineStyle"] copy];
		fill						  = [[coder decodeObjectForKey:@"CPTBarPlot.fill"] copy];
		barWidth					  = [coder decodeDecimalForKey:@"CPTBarPlot.barWidth"];
		barWidthScale				  = [coder decodeCGFloatForKey:@"CPTBarPlot.barWidthScale"];
		barOffset					  = [coder decodeDecimalForKey:@"CPTBarPlot.barOffset"];
		barOffsetScale				  = [coder decodeCGFloatForKey:@"CPTBarPlot.barOffsetScale"];
		barCornerRadius				  = [coder decodeCGFloatForKey:@"CPTBarPlot.barCornerRadius"];
		baseValue					  = [coder decodeDecimalForKey:@"CPTBarPlot.baseValue"];
		barsAreHorizontal			  = [coder decodeBoolForKey:@"CPTBarPlot.barsAreHorizontal"];
		barBasesVary				  = [coder decodeBoolForKey:@"CPTBarPlot.barBasesVary"];
		barWidthsAreInViewCoordinates = [coder decodeBoolForKey:@"CPTBarPlot.barWidthsAreInViewCoordinates"];
		plotRange					  = [[coder decodeObjectForKey:@"CPTBarPlot.plotRange"] copy];
	}
	return self;
}

#pragma mark -
#pragma mark Data Loading

/// @cond

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
		self.barTips  = nil;
		self.barBases = nil;
	}

	// Locations of bars
	if ( self.plotRange ) {
		// Spread bars evenly over the plot range
		CPTMutableNumericData *locationData = nil;
		if ( self.doublePrecisionCache ) {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															  dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
																 shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

			double doublePrecisionDelta = 1.0;
			if ( indexRange.length > 1 ) {
				doublePrecisionDelta = self.plotRange.lengthDouble / (double)(indexRange.length - 1);
			}

			double locationDouble = self.plotRange.locationDouble;
			double *dataBytes	  = (double *)locationData.mutableBytes;
			double *dataEnd		  = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++	= locationDouble;
				locationDouble += doublePrecisionDelta;
			}
		}
		else {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															  dataType:CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent() )
																 shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

			NSDecimal delta = CPTDecimalFromInteger(1);
			if ( indexRange.length > 1 ) {
				delta = CPTDecimalDivide( self.plotRange.length, CPTDecimalFromUnsignedInteger(indexRange.length - 1) );
			}

			NSDecimal locationDecimal = self.plotRange.location;
			NSDecimal *dataBytes	  = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd		  = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++	= locationDecimal;
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
															  dataType:CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() )
																 shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

			double locationDouble = 0.0;
			double *dataBytes	  = (double *)locationData.mutableBytes;
			double *dataEnd		  = dataBytes + indexRange.length;
			while ( dataBytes < dataEnd ) {
				*dataBytes++	= locationDouble;
				locationDouble += 1.0;
			}
		}
		else {
			locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
															  dataType:CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent() )
																 shape:nil];
			locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

			NSDecimal locationDecimal = CPTDecimalFromInteger(0);
			NSDecimal *dataBytes	  = (NSDecimal *)locationData.mutableBytes;
			NSDecimal *dataEnd		  = dataBytes + indexRange.length;
			NSDecimal one			  = CPTDecimalFromInteger(1);
			while ( dataBytes < dataEnd ) {
				*dataBytes++	= locationDecimal;
				locationDecimal = CPTDecimalAdd(locationDecimal, one);
			}
		}
		[self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
		[locationData release];
	}

	// Legend
	id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

	if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ||
		 [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

/// @endcond

#pragma mark -
#pragma mark Length Conversions for Independent Coordinate (e.g., widths, offsets)

///	@cond

-(CGFloat)lengthInView:(NSDecimal)decimalLength
{
	CGFloat length;

	if ( self.barWidthsAreInViewCoordinates ) {
		length = CPTDecimalCGFloatValue(decimalLength);
	}
	else {
		CPTCoordinate coordinate	 = (self.barsAreHorizontal ? CPTCoordinateY : CPTCoordinateX);
		CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
		NSDecimal xLocation			 = thePlotSpace.xRange.location;
		NSDecimal yLocation			 = thePlotSpace.yRange.location;

		NSDecimal originPlotPoint[2];
		NSDecimal displacedPlotPoint[2];

		switch ( coordinate ) {
			case CPTCoordinateX:
				originPlotPoint[CPTCoordinateX]	   = xLocation;
				originPlotPoint[CPTCoordinateY]	   = yLocation;
				displacedPlotPoint[CPTCoordinateX] = CPTDecimalAdd(xLocation, decimalLength);
				displacedPlotPoint[CPTCoordinateY] = yLocation;
				break;

			case CPTCoordinateY:
				originPlotPoint[CPTCoordinateX]	   = xLocation;
				originPlotPoint[CPTCoordinateY]	   = yLocation;
				displacedPlotPoint[CPTCoordinateX] = xLocation;
				displacedPlotPoint[CPTCoordinateY] = CPTDecimalAdd(yLocation, decimalLength);
				break;

			default:
				break;
		}

		CGPoint originPoint	   = [thePlotSpace plotAreaViewPointForPlotPoint:originPlotPoint];
		CGPoint displacedPoint = [thePlotSpace plotAreaViewPointForPlotPoint:displacedPlotPoint];

		switch ( coordinate ) {
			case CPTCoordinateX:
				length = displacedPoint.x - originPoint.x;
				break;

			case CPTCoordinateY:
				length = displacedPoint.y - originPoint.y;
				break;

			default:
				length = 0.0;
				break;
		}
	}
	return length;
}

-(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength
{
	double length;

	if ( self.barWidthsAreInViewCoordinates ) {
		CGFloat floatLength		   = CPTDecimalCGFloatValue(decimalLength);
		CGPoint originViewPoint	   = CGPointZero;
		CGPoint displacedViewPoint = CGPointMake(floatLength, floatLength);
		double originPlotPoint[2], displacedPlotPoint[2];
		CPTPlotSpace *thePlotSpace = self.plotSpace;
		[thePlotSpace doublePrecisionPlotPoint:originPlotPoint forPlotAreaViewPoint:originViewPoint];
		[thePlotSpace doublePrecisionPlotPoint:displacedPlotPoint forPlotAreaViewPoint:displacedViewPoint];
		if ( self.barsAreHorizontal ) {
			length = displacedPlotPoint[CPTCoordinateY] - originPlotPoint[CPTCoordinateY];
		}
		else {
			length = displacedPlotPoint[CPTCoordinateX] - originPlotPoint[CPTCoordinateX];
		}
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
		CGFloat floatLength		   = CPTDecimalCGFloatValue(decimalLength);
		CGPoint originViewPoint	   = CGPointZero;
		CGPoint displacedViewPoint = CGPointMake(floatLength, floatLength);
		NSDecimal originPlotPoint[2], displacedPlotPoint[2];
		CPTPlotSpace *thePlotSpace = self.plotSpace;
		[thePlotSpace plotPoint:originPlotPoint forPlotAreaViewPoint:originViewPoint];
		[thePlotSpace plotPoint:displacedPlotPoint forPlotAreaViewPoint:displacedViewPoint];
		if ( self.barsAreHorizontal ) {
			length = CPTDecimalSubtract(displacedPlotPoint[CPTCoordinateY], originPlotPoint[CPTCoordinateY]);
		}
		else {
			length = CPTDecimalSubtract(displacedPlotPoint[CPTCoordinateX], originPlotPoint[CPTCoordinateX]);
		}
	}
	else {
		length = decimalLength;
	}
	return length;
}

///	@endcond

#pragma mark -
#pragma mark Data Ranges

/// @cond

-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord
{
	CPTPlotRange *range = [super plotRangeForCoordinate:coord];

	if ( !self.barBasesVary ) {
		switch ( coord ) {
			case CPTCoordinateX:
				if ( self.barsAreHorizontal ) {
					NSDecimal base = self.baseValue;
					if ( ![range contains:base] ) {
						CPTMutablePlotRange *newRange = [[range mutableCopy] autorelease];
						[newRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:base length:CPTDecimalFromInteger(0)]];
						range = newRange;
					}
				}
				break;

			case CPTCoordinateY:
				if ( !self.barsAreHorizontal ) {
					NSDecimal base = self.baseValue;
					if ( ![range contains:base] ) {
						CPTMutablePlotRange *newRange = [[range mutableCopy] autorelease];
						[newRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:base length:CPTDecimalFromInteger(0)]];
						range = newRange;
					}
				}
				break;

			default:
				break;
		}
	}
	return range;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) {
		return;
	}

	CPTMutableNumericData *cachedLocations = [self cachedNumbersForField:CPTBarPlotFieldBarLocation];
	CPTMutableNumericData *cachedLengths   = [self cachedNumbersForField:CPTBarPlotFieldBarTip];
	if ( (cachedLocations == nil) || (cachedLengths == nil) ) {
		return;
	}

	BOOL basesVary					   = self.barBasesVary;
	CPTMutableNumericData *cachedBases = [self cachedNumbersForField:CPTBarPlotFieldBarBase];
	if ( basesVary && (cachedBases == nil) ) {
		return;
	}

	NSUInteger barCount = self.cachedDataCount;
	if ( barCount == 0 ) {
		return;
	}

	if ( cachedLocations.numberOfSamples != cachedLengths.numberOfSamples ) {
		[NSException raise:CPTException format:@"Number of bar locations and lengths do not match"];
	}

	if ( basesVary && (cachedLengths.numberOfSamples != cachedBases.numberOfSamples) ) {
		[NSException raise:CPTException format:@"Number of bar lengths and bases do not match"];
	}

	[super renderAsVectorInContext:theContext];

	for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
		// Draw
		[self drawBarInContext:theContext recordIndex:ii];
	}
}

-(BOOL)barAtRecordIndex:(NSUInteger)index basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint
{
	BOOL horizontalBars			   = self.barsAreHorizontal;
	CPTCoordinate independentCoord = (horizontalBars ? CPTCoordinateY : CPTCoordinateX);
	CPTCoordinate dependentCoord   = (horizontalBars ? CPTCoordinateX : CPTCoordinateY);

	CPTPlotSpace *thePlotSpace = self.plotSpace;
	CPTPlotArea *thePlotArea   = self.plotArea;

	if ( self.doublePrecisionCache ) {
		double plotPoint[2];
		plotPoint[independentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarLocation recordIndex:index];
		if ( isnan(plotPoint[independentCoord]) ) {
			return NO;
		}

		// Tip point
		plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarTip recordIndex:index];
		if ( isnan(plotPoint[dependentCoord]) ) {
			return NO;
		}
		*tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];

		// Base point
		if ( !self.barBasesVary ) {
			plotPoint[dependentCoord] = CPTDecimalDoubleValue(self.baseValue);
		}
		else {
			plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarBase recordIndex:index];
		}
		if ( isnan(plotPoint[dependentCoord]) ) {
			return NO;
		}
		*basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
	}
	else {
		NSDecimal plotPoint[2];
		plotPoint[independentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarLocation recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) {
			return NO;
		}

		// Tip point
		plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarTip recordIndex:index];
		if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
			return NO;
		}
		*tipPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];

		// Base point
		if ( !self.barBasesVary ) {
			plotPoint[dependentCoord] = self.baseValue;
		}
		else {
			plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:index];
		}
		if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
			return NO;
		}
		*basePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
	}

	// Determine bar width and offset.
	CGFloat barOffsetLength = [self lengthInView:self.barOffset] * self.barOffsetScale;

	// Offset
	if ( horizontalBars ) {
		basePoint->y += barOffsetLength;
		tipPoint->y	 += barOffsetLength;
	}
	else {
		basePoint->x += barOffsetLength;
		tipPoint->x	 += barOffsetLength;
	}

	return YES;
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)recordIndex
{
	// Get base and tip points
	CGPoint basePoint, tipPoint;
	BOOL barExists = [self barAtRecordIndex:recordIndex basePoint:&basePoint tipPoint:&tipPoint];

	if ( !barExists ) {
		return NULL;
	}

	CGMutablePathRef path = [self newBarPathWithContext:context basePoint:basePoint tipPoint:tipPoint];

	return path;
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint
{
	BOOL horizontalBars = self.barsAreHorizontal;

	// This function is used to create a path which is used for both
	// drawing a bar and for doing hit-testing on a click/touch event
	CPTCoordinate widthCoordinate = (horizontalBars ? CPTCoordinateY : CPTCoordinateX);
	CGFloat barWidthLength		  = [self lengthInView:self.barWidth] * self.barWidthScale;
	CGFloat halfBarWidth		  = (CGFloat)0.5 * barWidthLength;

	CGFloat point[2];

	point[CPTCoordinateX]	= basePoint.x;
	point[CPTCoordinateY]	= basePoint.y;
	point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);

	point[CPTCoordinateX]	= tipPoint.x;
	point[CPTCoordinateY]	= tipPoint.y;
	point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);

	point[CPTCoordinateX] = tipPoint.x;
	point[CPTCoordinateY] = tipPoint.y;
	CGPoint alignedPoint3 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);

	point[CPTCoordinateX]	= tipPoint.x;
	point[CPTCoordinateY]	= tipPoint.y;
	point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);

	point[CPTCoordinateX]	= basePoint.x;
	point[CPTCoordinateY]	= basePoint.y;
	point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CGPointMake(point[CPTCoordinateX], point[CPTCoordinateY]);

	// Align to device pixels if there is a line border.
	// Otherwise, align to view space, so fills are sharp at edges.
	// Note: may not have a context if doing hit testing.
	if ( self.alignsPointsToPixels ) {
		if ( self.lineStyle.lineWidth > 0.0 ) {
			if ( context ) {
				alignedPoint1 = CPTAlignPointToUserSpace(context, alignedPoint1);
				alignedPoint2 = CPTAlignPointToUserSpace(context, alignedPoint2);
				alignedPoint3 = CPTAlignPointToUserSpace(context, alignedPoint3);
				alignedPoint4 = CPTAlignPointToUserSpace(context, alignedPoint4);
				alignedPoint5 = CPTAlignPointToUserSpace(context, alignedPoint5);
			}
		}
		else {
			alignedPoint1 = CPTAlignIntegralPointToUserSpace(context, alignedPoint1);
			alignedPoint2 = CPTAlignIntegralPointToUserSpace(context, alignedPoint2);
			alignedPoint3 = CPTAlignIntegralPointToUserSpace(context, alignedPoint3);
			alignedPoint4 = CPTAlignIntegralPointToUserSpace(context, alignedPoint4);
			alignedPoint5 = CPTAlignIntegralPointToUserSpace(context, alignedPoint5);
		}
	}

	CGFloat radius = MIN(self.barCornerRadius, halfBarWidth);
	if ( horizontalBars ) {
		radius = MIN( radius, ABS(tipPoint.x - basePoint.x) );
	}
	else {
		radius = MIN( radius, ABS(tipPoint.y - basePoint.y) );
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
	BOOL horizontalBars	   = self.barsAreHorizontal;
	CGFloat barWidthLength = [self lengthInView:self.barWidth] * self.barWidthScale;
	CGFloat halfBarWidth   = (CGFloat)0.5 * barWidthLength;

	CPTPlotArea *thePlotArea = self.plotArea;

	CGFloat lowerBound = ( horizontalBars ? CGRectGetMinY(thePlotArea.bounds) : CGRectGetMinX(thePlotArea.bounds) );
	CGFloat upperBound = ( horizontalBars ? CGRectGetMaxY(thePlotArea.bounds) : CGRectGetMaxX(thePlotArea.bounds) );
	CGFloat base	   = (horizontalBars ? basePoint.y : basePoint.x);

	return (base + halfBarWidth >= lowerBound) && (base - halfBarWidth <= upperBound);
}

-(CPTFill *)barFillForIndex:(NSUInteger)index
{
	id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

	CPTFill *theBarFill;

	if ( [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
		CPTFill *dataSourceFill = [theDataSource barFillForBarPlot:self recordIndex:index];
		if ( dataSourceFill ) {
			theBarFill = dataSourceFill;
		}
		else {
			theBarFill = self.fill;
		}
	}
	else {
		theBarFill = self.fill;
	}

	return theBarFill;
}

-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index
{
	// Get base and tip points
	CGPoint basePoint, tipPoint;
	BOOL barExists = [self barAtRecordIndex:index basePoint:&basePoint tipPoint:&tipPoint];

	if ( !barExists ) {
		return;
	}

	// Return if bar is off screen
	if ( ![self barIsVisibleWithBasePoint:basePoint] ) {
		return;
	}

	CGMutablePathRef path = [self newBarPathWithContext:context basePoint:basePoint tipPoint:tipPoint];

	if ( path ) {
		CGContextSaveGState(context);

		CPTFill *theBarFill = [self barFillForIndex:index];
		if ( [theBarFill isKindOfClass:[CPTFill class]] ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[theBarFill fillPathInContext:context];
		}

		id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

		CPTLineStyle *theLineStyle = self.lineStyle;
		if ( [theDataSource respondsToSelector:@selector(barLineStyleForBarPlot:recordIndex:)] ) {
			CPTLineStyle *dataSourceLineStyle = [theDataSource barLineStyleForBarPlot:self recordIndex:index];
			if ( dataSourceLineStyle ) {
				theLineStyle = dataSourceLineStyle;
			}
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

	CPTFill *theFill		   = [self barFillForIndex:index];
	CPTLineStyle *theLineStyle = self.lineStyle;

	if ( theFill || theLineStyle ) {
		CGPathRef swatchPath;
		CGFloat radius = self.barCornerRadius;
		if ( radius > 0.0 ) {
			radius	   = MIN(MIN(radius, rect.size.width / (CGFloat)2.0), rect.size.height / (CGFloat)2.0);
			swatchPath = CreateRoundedRectPath(rect, radius);
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect(mutablePath, NULL, rect);
			swatchPath = mutablePath;
		}

		if ( [theFill isKindOfClass:[CPTFill class]] ) {
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

///	@endcond

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

/// @cond

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
	NSNumber *length   = [self cachedNumberForField:CPTBarPlotFieldBarTip recordIndex:index];

	BOOL positiveDirection	  = CPTDecimalGreaterThanOrEqualTo([length decimalValue], theBaseDecimalValue);
	BOOL horizontalBars		  = self.barsAreHorizontal;
	CPTCoordinate coordinate  = (horizontalBars ? CPTCoordinateX : CPTCoordinateY);
	CPTPlotRange *lengthRange = [self.plotSpace plotRangeForCoordinate:coordinate];
	if ( CPTDecimalLessThan( lengthRange.length, CPTDecimalFromInteger(0) ) ) {
		positiveDirection = !positiveDirection;
	}

	NSNumber *offsetLocation;
	if ( self.doublePrecisionCache ) {
		offsetLocation = [NSNumber numberWithDouble:([location doubleValue] + [self doubleLengthInPlotCoordinates:self.barOffset] * self.barOffsetScale)];
	}
	else {
		NSDecimal decimalLocation = [location decimalValue];
		NSDecimal offset		  = CPTDecimalMultiply( [self lengthInPlotCoordinates:self.barOffset], CPTDecimalFromCGFloat(self.barOffsetScale) );
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

/// @endcond

#pragma mark -
#pragma mark Legends

///	@cond

/**	@internal
 *	@brief The number of legend entries provided by this plot.
 *	@return The number of legend entries.
 **/
-(NSUInteger)numberOfLegendEntries
{
	NSUInteger entryCount = 1;

	id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

	if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ||
		 [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
		[self reloadDataIfNeeded];
		entryCount = self.cachedDataCount;
	}

	return entryCount;
}

/**	@internal
 *	@brief The title text of a legend entry.
 *	@param index The index of the desired title.
 *	@return The title of the legend entry at the requested index.
 **/
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)index
{
	NSString *legendTitle = nil;

	id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

	if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ) {
		legendTitle = [theDataSource legendTitleForBarPlot:self recordIndex:index];
	}
	else {
		legendTitle = [super titleForLegendEntryAtIndex:index];
	}

	return legendTitle;
}

///	@endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

/**
 *	@brief Informs the receiver that the user has
 *	@if MacOnly pressed the mouse button. @endif
 *	@if iOSOnly touched the screen. @endif
 *
 *
 *	If this plot has a delegate that responds to the
 *	@link CPTBarPlotDelegate::barPlot:barWasSelectedAtRecordIndex: -barPlot:barWasSelectedAtRecordIndex: @endlink
 *	method, the <code>interactionPoint</code> is compared with each bar in index order.
 *	The delegate method will be called and this method returns <code>YES</code> for the first
 *	index where the <code>interactionPoint</code> is inside a bar.
 *	This method returns <code>NO</code> if the <code>interactionPoint</code> is outside all of the bars.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result				 = NO;
	CPTGraph *theGraph		 = self.graph;
	CPTPlotArea *thePlotArea = self.plotArea;

	if ( !theGraph || !thePlotArea ) {
		return NO;
	}

	id<CPTBarPlotDelegate> theDelegate = self.delegate;
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

///	@}

#pragma mark -
#pragma mark Accessors

///	@cond

-(NSArray *)barTips
{
	return [[self cachedNumbersForField:CPTBarPlotFieldBarTip] sampleArray];
}

-(void)setBarTips:(NSArray *)newTips
{
	[self cacheNumbers:newTips forField:CPTBarPlotFieldBarTip];
}

-(NSArray *)barBases
{
	return [[self cachedNumbersForField:CPTBarPlotFieldBarBase] sampleArray];
}

-(void)setBarBases:(NSArray *)newBases
{
	[self cacheNumbers:newBases forField:CPTBarPlotFieldBarBase];
}

-(NSArray *)barLocations
{
	return [[self cachedNumbersForField:CPTBarPlotFieldBarLocation] sampleArray];
}

-(void)setBarLocations:(NSArray *)newLocations
{
	[self cacheNumbers:newLocations forField:CPTBarPlotFieldBarLocation];
}

-(void)setLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( lineStyle != newLineStyle ) {
		[lineStyle release];
		lineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setFill:(CPTFill *)newFill
{
	if ( fill != newFill ) {
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
	if ( barCornerRadius != newCornerRadius ) {
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
	if ( barsAreHorizontal != newBarsAreHorizontal ) {
		barsAreHorizontal = newBarsAreHorizontal;
		[self setNeedsDisplay];
		[self setNeedsLayout];
	}
}

///	@endcond

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
	return 3;
}

-(NSArray *)fieldIdentifiers
{
	return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarLocation],
			[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip],
			[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarLocation],
			nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
	NSArray *result = nil;

	switch ( coord ) {
		case CPTCoordinateX:
			if ( self.barsAreHorizontal ) {
				if ( self.barBasesVary ) {
					result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip], [NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarBase], nil];
				}
				else {
					result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip], nil];
				}
			}
			else {
				result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarLocation], nil];
			}
			break;

		case CPTCoordinateY:
			if ( self.barsAreHorizontal ) {
				result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarLocation], nil];
			}
			else {
				if ( self.barBasesVary ) {
					result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip], [NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarBase], nil];
				}
				else {
					result = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarTip], nil];
				}
			}
			break;

		default:
			[NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
			break;
	}
	return result;
}

/// @endcond

@end
