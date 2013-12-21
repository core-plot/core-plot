#import "CPTBarPlot.h"

#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTLegend.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTMutablePlotRange.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/** @defgroup plotAnimationBarPlot Bar Plot
 *  @brief Bar plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsBarPlot Bar Plot Bindings
 *  @brief Binding identifiers for bar plots.
 *  @ingroup plotBindings
 *  @endif
 **/

NSString *const CPTBarPlotBindingBarLocations  = @"barLocations";  ///< Bar locations.
NSString *const CPTBarPlotBindingBarTips       = @"barTips";       ///< Bar tips.
NSString *const CPTBarPlotBindingBarBases      = @"barBases";      ///< Bar bases.
NSString *const CPTBarPlotBindingBarFills      = @"barFills";      ///< Bar fills.
NSString *const CPTBarPlotBindingBarLineStyles = @"barLineStyles"; ///< Bar line styles.

/// @cond
@interface CPTBarPlot()

@property (nonatomic, readwrite, copy) NSArray *barLocations;
@property (nonatomic, readwrite, copy) NSArray *barTips;
@property (nonatomic, readwrite, copy) NSArray *barBases;
@property (nonatomic, readwrite, copy) NSArray *barFills;
@property (nonatomic, readwrite, copy) NSArray *barLineStyles;

-(BOOL)barAtRecordIndex:(NSUInteger)idx basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint;
-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)recordIndex;
-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint;
-(CPTFill *)barFillForIndex:(NSUInteger)idx;
-(CPTLineStyle *)barLineStyleForIndex:(NSUInteger)idx;
-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)idx;

-(CGFloat)lengthInView:(NSDecimal)plotLength;
-(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength;

-(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A two-dimensional bar plot.
 *  @see See @ref plotAnimationBarPlot "Bar Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsBarPlot "Bar Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTBarPlot

@dynamic barLocations;
@dynamic barTips;
@dynamic barBases;
@dynamic barFills;
@dynamic barLineStyles;

/** @property CGFloat barCornerRadius
 *  @brief The corner radius for the end of the bars. Default is @num{0.0} for square corners.
 *  @ingroup plotAnimationBarPlot
 **/
@synthesize barCornerRadius;

/** @property CGFloat barBaseCornerRadius
 *  @brief The corner radius for the end of the bars drawn at the base value. Default is @num{0.0} for square corners.
 *  @ingroup plotAnimationBarPlot
 **/
@synthesize barBaseCornerRadius;

/** @property NSDecimal barOffset
 *  @brief The starting offset of the first bar in location data units.
 **/
@synthesize barOffset;

/** @property CGFloat barOffsetScale
 *  @brief An animatable scaling factor for the bar offset. Default is @num{1.0}.
 *  @ingroup plotAnimationBarPlot
 **/
@synthesize barOffsetScale;

/** @property BOOL barWidthsAreInViewCoordinates
 *  @brief Whether the bar width and bar offset is in view coordinates, or in plot coordinates.
 *  Default is @NO, meaning plot coordinates are used.
 **/
@synthesize barWidthsAreInViewCoordinates;

/** @property NSDecimal barWidth
 *  @brief The width of each bar. Either view or plot coordinates can be used.
 *
 *  With plot coordinates, the bar locations are one data unit apart (e.g., 1, 2, 3, etc.),
 *  a value of @num{1.0} will result in bars that touch each other; a value of @num{0.5} will result in bars that are as wide
 *  as the gap between them.
 *
 *  @see barWidthsAreInViewCoordinates
 **/
@synthesize barWidth;

/** @property CGFloat barWidthScale
 *  @brief An animatable scaling factor for the bar width. Default is @num{1.0}.
 *  @ingroup plotAnimationBarPlot
 **/
@synthesize barWidthScale;

/** @property CPTLineStyle *lineStyle
 *  @brief The line style for the bar outline.
 *  If @nil, the outline is not drawn.
 **/
@synthesize lineStyle;

/** @property CPTFill *fill
 *  @brief The fill style for the bars.
 *  If @nil, the bars are not filled.
 **/
@synthesize fill;

/** @property BOOL barsAreHorizontal
 *  @brief If @YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 **/
@synthesize barsAreHorizontal;

/** @property NSDecimal baseValue
 *  @brief The coordinate value of the fixed end of the bars.
 *  This is only used if @ref barBasesVary is @NO. Otherwise, the data source
 *  will be queried for an appropriate value of #CPTBarPlotFieldBarBase.
 **/
@synthesize baseValue;

/** @property BOOL barBasesVary
 *  @brief If @NO, a constant base value is used for all bars.
 *  If @YES, the data source is queried to supply a base value for each bar.
 *  @see baseValue
 **/
@synthesize barBasesVary;

/** @property CPTPlotRange *plotRange
 *  @brief Sets the plot range for the independent axis.
 *
 *  If a plot range is provided, the bars are spaced evenly throughout the plot range. If @ref plotRange is @nil,
 *  bar locations are provided by Cocoa bindings or the bar plot datasource. If locations are not provided by
 *  either bindings or the datasource, the first bar will be placed at zero (@num{0}) and subsequent bars will be at
 *  successive positive integer coordinates.
 **/
@synthesize plotRange;

#pragma mark -
#pragma mark Convenience Factory Methods

/** @brief Creates and returns a new CPTBarPlot instance initialized with a bar fill consisting of a linear gradient between black and the given color.
 *  @param color The beginning color.
 *  @param horizontal If @YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 *  @return A new CPTBarPlot instance initialized with a linear gradient bar fill.
 **/
+(CPTBarPlot *)tubularBarPlotWithColor:(CPTColor *)color horizontalBars:(BOOL)horizontal
{
    CPTBarPlot *barPlot               = [[CPTBarPlot alloc] init];
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];

    barLineStyle.lineWidth = CPTFloat(1.0);
    barLineStyle.lineColor = [CPTColor blackColor];
    barPlot.lineStyle      = barLineStyle;
    [barLineStyle release];
    barPlot.barsAreHorizontal             = horizontal;
    barPlot.barWidth                      = CPTDecimalFromDouble(0.8);
    barPlot.barWidthsAreInViewCoordinates = NO;
    barPlot.barCornerRadius               = CPTFloat(2.0);
    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];
    fillGradient.angle = CPTFloat(horizontal ? -90.0 : 0.0);
    barPlot.fill       = [CPTFill fillWithGradient:fillGradient];
    return [barPlot autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTBarPlot class] ) {
        [self exposeBinding:CPTBarPlotBindingBarLocations];
        [self exposeBinding:CPTBarPlotBindingBarTips];
        [self exposeBinding:CPTBarPlotBindingBarBases];
        [self exposeBinding:CPTBarPlotBindingBarFills];
        [self exposeBinding:CPTBarPlotBindingBarLineStyles];
    }
}
#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTBarPlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref lineStyle = default line style
 *  - @ref fill = solid black fill
 *  - @ref barWidth = @num{0.5}
 *  - @ref barWidthScale = @num{1.0}
 *  - @ref barWidthsAreInViewCoordinates = @NO
 *  - @ref barOffset = @num{0.0}
 *  - @ref barOffsetScale = @num{1.0}
 *  - @ref barCornerRadius = @num{0.0}
 *  - @ref barBaseCornerRadius = @num{0.0}
 *  - @ref baseValue = @num{0}
 *  - @ref barsAreHorizontal = @NO
 *  - @ref barBasesVary = @NO
 *  - @ref plotRange = @nil
 *  - @ref labelOffset = @num{10.0}
 *  - @ref labelField = #CPTBarPlotFieldBarTip
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTBarPlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        lineStyle                     = [[CPTLineStyle alloc] init];
        fill                          = [[CPTFill fillWithColor:[CPTColor blackColor]] retain];
        barWidth                      = CPTDecimalFromDouble(0.5);
        barWidthScale                 = CPTFloat(1.0);
        barWidthsAreInViewCoordinates = NO;
        barOffset                     = CPTDecimalFromDouble(0.0);
        barOffsetScale                = CPTFloat(1.0);
        barCornerRadius               = CPTFloat(0.0);
        barBaseCornerRadius           = CPTFloat(0.0);
        baseValue                     = CPTDecimalFromInteger(0);
        barsAreHorizontal             = NO;
        barBasesVary                  = NO;
        plotRange                     = nil;

        self.labelOffset = CPTFloat(10.0);
        self.labelField  = CPTBarPlotFieldBarTip;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTBarPlot *theLayer = (CPTBarPlot *)layer;

        lineStyle                     = [theLayer->lineStyle retain];
        fill                          = [theLayer->fill retain];
        barWidth                      = theLayer->barWidth;
        barWidthScale                 = theLayer->barWidthScale;
        barWidthsAreInViewCoordinates = theLayer->barWidthsAreInViewCoordinates;
        barOffset                     = theLayer->barOffset;
        barOffsetScale                = theLayer->barOffsetScale;
        barCornerRadius               = theLayer->barCornerRadius;
        barBaseCornerRadius           = theLayer->barBaseCornerRadius;
        baseValue                     = theLayer->baseValue;
        barBasesVary                  = theLayer->barBasesVary;
        barsAreHorizontal             = theLayer->barsAreHorizontal;
        plotRange                     = [theLayer->plotRange retain];
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

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

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
    [coder encodeCGFloat:self.barBaseCornerRadius forKey:@"CPTBarPlot.barBaseCornerRadius"];
    [coder encodeDecimal:self.baseValue forKey:@"CPTBarPlot.baseValue"];
    [coder encodeBool:self.barsAreHorizontal forKey:@"CPTBarPlot.barsAreHorizontal"];
    [coder encodeBool:self.barBasesVary forKey:@"CPTBarPlot.barBasesVary"];
    [coder encodeBool:self.barWidthsAreInViewCoordinates forKey:@"CPTBarPlot.barWidthsAreInViewCoordinates"];
    [coder encodeObject:self.plotRange forKey:@"CPTBarPlot.plotRange"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        lineStyle                     = [[coder decodeObjectForKey:@"CPTBarPlot.lineStyle"] copy];
        fill                          = [[coder decodeObjectForKey:@"CPTBarPlot.fill"] copy];
        barWidth                      = [coder decodeDecimalForKey:@"CPTBarPlot.barWidth"];
        barWidthScale                 = [coder decodeCGFloatForKey:@"CPTBarPlot.barWidthScale"];
        barOffset                     = [coder decodeDecimalForKey:@"CPTBarPlot.barOffset"];
        barOffsetScale                = [coder decodeCGFloatForKey:@"CPTBarPlot.barOffsetScale"];
        barCornerRadius               = [coder decodeCGFloatForKey:@"CPTBarPlot.barCornerRadius"];
        barBaseCornerRadius           = [coder decodeCGFloatForKey:@"CPTBarPlot.barBaseCornerRadius"];
        baseValue                     = [coder decodeDecimalForKey:@"CPTBarPlot.baseValue"];
        barsAreHorizontal             = [coder decodeBoolForKey:@"CPTBarPlot.barsAreHorizontal"];
        barBasesVary                  = [coder decodeBoolForKey:@"CPTBarPlot.barBasesVary"];
        barWidthsAreInViewCoordinates = [coder decodeBoolForKey:@"CPTBarPlot.barWidthsAreInViewCoordinates"];
        plotRange                     = [[coder decodeObjectForKey:@"CPTBarPlot.plotRange"] copy];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Data Loading

/// @cond

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
    [super reloadDataInIndexRange:indexRange];

    id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:indexRange] ) {
        // Bar lengths
        if ( theDataSource ) {
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
                double *dataBytes     = (double *)locationData.mutableBytes;
                double *dataEnd       = dataBytes + indexRange.length;
                while ( dataBytes < dataEnd ) {
                    *dataBytes++    = locationDouble;
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
                NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
                NSDecimal *dataEnd        = dataBytes + indexRange.length;
                while ( dataBytes < dataEnd ) {
                    *dataBytes++    = locationDecimal;
                    locationDecimal = CPTDecimalAdd(locationDecimal, delta);
                }
            }
            [self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            [locationData release];
        }
        else if ( theDataSource ) {
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
                double *dataBytes     = (double *)locationData.mutableBytes;
                double *dataEnd       = dataBytes + indexRange.length;
                while ( dataBytes < dataEnd ) {
                    *dataBytes++    = locationDouble;
                    locationDouble += 1.0;
                }
            }
            else {
                locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                                                  dataType:CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent() )
                                                                     shape:nil];
                locationData.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:indexRange.length]];

                NSDecimal locationDecimal = CPTDecimalFromInteger(0);
                NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
                NSDecimal *dataEnd        = dataBytes + indexRange.length;
                NSDecimal one             = CPTDecimalFromInteger(1);
                while ( dataBytes < dataEnd ) {
                    *dataBytes++    = locationDecimal;
                    locationDecimal = CPTDecimalAdd(locationDecimal, one);
                }
            }
            [self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            [locationData release];
        }
    }

    // Bar fills
    if ( [theDataSource respondsToSelector:@selector(barFillsForBarPlot:recordIndexRange:)] ) {
        [self cacheArray:[theDataSource barFillsForBarPlot:self recordIndexRange:indexRange]
                  forKey:CPTBarPlotBindingBarFills
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTFill *dataSourceFill = [theDataSource barFillForBarPlot:self recordIndex:idx];
            if ( dataSourceFill ) {
                [array addObject:dataSourceFill];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTBarPlotBindingBarFills atRecordIndex:indexRange.location];
        [array release];
    }

    // Bar line styles
    if ( [theDataSource respondsToSelector:@selector(barLineStylesForBarPlot:recordIndexRange:)] ) {
        [self cacheArray:[theDataSource barLineStylesForBarPlot:self recordIndexRange:indexRange]
                  forKey:CPTBarPlotBindingBarLineStyles
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(barLineStyleForBarPlot:recordIndex:)] ) {
        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLineStyle *dataSourceLineStyle = [theDataSource barLineStyleForBarPlot:self recordIndex:idx];
            if ( dataSourceLineStyle ) {
                [array addObject:dataSourceLineStyle];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTBarPlotBindingBarLineStyles atRecordIndex:indexRange.location];
        [array release];
    }

    // Legend
    if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ||
         [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

/// @endcond

#pragma mark -
#pragma mark Length Conversions for Independent Coordinate (e.g., widths, offsets)

/// @cond

-(CGFloat)lengthInView:(NSDecimal)decimalLength
{
    CGFloat length;

    if ( self.barWidthsAreInViewCoordinates ) {
        length = CPTDecimalCGFloatValue(decimalLength);
    }
    else {
        CPTCoordinate coordinate     = (self.barsAreHorizontal ? CPTCoordinateY : CPTCoordinateX);
        CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
        NSDecimal xLocation          = thePlotSpace.xRange.location;
        NSDecimal yLocation          = thePlotSpace.yRange.location;

        NSDecimal originPlotPoint[2];
        NSDecimal displacedPlotPoint[2];

        switch ( coordinate ) {
            case CPTCoordinateX:
                originPlotPoint[CPTCoordinateX]    = xLocation;
                originPlotPoint[CPTCoordinateY]    = yLocation;
                displacedPlotPoint[CPTCoordinateX] = CPTDecimalAdd(xLocation, decimalLength);
                displacedPlotPoint[CPTCoordinateY] = yLocation;
                break;

            case CPTCoordinateY:
                originPlotPoint[CPTCoordinateX]    = xLocation;
                originPlotPoint[CPTCoordinateY]    = yLocation;
                displacedPlotPoint[CPTCoordinateX] = xLocation;
                displacedPlotPoint[CPTCoordinateY] = CPTDecimalAdd(yLocation, decimalLength);
                break;

            default:
                break;
        }

        CGPoint originPoint    = [thePlotSpace plotAreaViewPointForPlotPoint:originPlotPoint numberOfCoordinates:2];
        CGPoint displacedPoint = [thePlotSpace plotAreaViewPointForPlotPoint:displacedPlotPoint numberOfCoordinates:2];

        switch ( coordinate ) {
            case CPTCoordinateX:
                length = displacedPoint.x - originPoint.x;
                break;

            case CPTCoordinateY:
                length = displacedPoint.y - originPoint.y;
                break;

            default:
                length = CPTFloat(0.0);
                break;
        }
    }
    return length;
}

-(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength
{
    double length;

    if ( self.barWidthsAreInViewCoordinates ) {
        CGFloat floatLength        = CPTDecimalCGFloatValue(decimalLength);
        CGPoint originViewPoint    = CGPointZero;
        CGPoint displacedViewPoint = CPTPointMake(floatLength, floatLength);
        double originPlotPoint[2], displacedPlotPoint[2];
        CPTPlotSpace *thePlotSpace = self.plotSpace;
        [thePlotSpace doublePrecisionPlotPoint:originPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:originViewPoint];
        [thePlotSpace doublePrecisionPlotPoint:displacedPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:displacedViewPoint];
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
        CGFloat floatLength        = CPTDecimalCGFloatValue(decimalLength);
        CGPoint originViewPoint    = CGPointZero;
        CGPoint displacedViewPoint = CPTPointMake(floatLength, floatLength);
        NSDecimal originPlotPoint[2], displacedPlotPoint[2];
        CPTPlotSpace *thePlotSpace = self.plotSpace;
        [thePlotSpace plotPoint:originPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:originViewPoint];
        [thePlotSpace plotPoint:displacedPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:displacedViewPoint];
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

/// @endcond

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

/** @brief Computes a plot range that completely encloses all of the bars.
 *
 *  For a horizontal bar plot, this range starts at the left edge of the first bar and continues to the right edge
 *  of the last bar. Similarly, this range starts at the bottom edge of the first bar and continues to the top edge
 *  of the last bar for vertical bar plots. The length will have the same sign as the corresponding plot range from the plot space.
 *
 *  @return A plot range that completely encloses all of the bars.
 **/
-(CPTPlotRange *)plotRangeEnclosingBars
{
    BOOL horizontalBars = self.barsAreHorizontal;
    CPTMutablePlotRange *range;

    if ( horizontalBars ) {
        range = [[self plotRangeForCoordinate:CPTCoordinateY] mutableCopy];
    }
    else {
        range = [[self plotRangeForCoordinate:CPTCoordinateX] mutableCopy];
    }

    NSDecimal barOffsetLength = [self lengthInPlotCoordinates:self.barOffset];
    NSDecimal barWidthLength  = [self lengthInPlotCoordinates:self.barWidth];
    NSDecimal halfBarWidth    = CPTDecimalDivide( barWidthLength, CPTDecimalFromInteger(2) );

    NSDecimal rangeLocation = range.location;
    NSDecimal rangeLength   = range.length;

    if ( CPTDecimalGreaterThanOrEqualTo( rangeLength, CPTDecimalFromInteger(0) ) ) {
        rangeLocation  = CPTDecimalSubtract(rangeLocation, halfBarWidth);
        range.location = CPTDecimalAdd(rangeLocation, barOffsetLength);
        range.length   = CPTDecimalAdd(rangeLength, barWidthLength);
    }
    else {
        rangeLocation  = CPTDecimalAdd(rangeLocation, halfBarWidth);
        range.location = CPTDecimalSubtract(rangeLocation, barOffsetLength);
        range.length   = CPTDecimalSubtract(rangeLength, barWidthLength);
    }

    return [range autorelease];
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTMutableNumericData *cachedLocations = [self cachedNumbersForField:CPTBarPlotFieldBarLocation];
    CPTMutableNumericData *cachedLengths   = [self cachedNumbersForField:CPTBarPlotFieldBarTip];
    if ( (cachedLocations == nil) || (cachedLengths == nil) ) {
        return;
    }

    BOOL basesVary                     = self.barBasesVary;
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

    [super renderAsVectorInContext:context];

    CGContextBeginTransparencyLayer(context, NULL);

    for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
        // Draw
        [self drawBarInContext:context recordIndex:ii];
    }

    CGContextEndTransparencyLayer(context);
}

-(BOOL)barAtRecordIndex:(NSUInteger)idx basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint
{
    BOOL horizontalBars            = self.barsAreHorizontal;
    CPTCoordinate independentCoord = (horizontalBars ? CPTCoordinateY : CPTCoordinateX);
    CPTCoordinate dependentCoord   = (horizontalBars ? CPTCoordinateX : CPTCoordinateY);

    CPTPlotSpace *thePlotSpace = self.plotSpace;

    if ( self.doublePrecisionCache ) {
        double plotPoint[2];
        plotPoint[independentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarLocation recordIndex:idx];
        if ( isnan(plotPoint[independentCoord]) ) {
            return NO;
        }

        // Tip point
        plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarTip recordIndex:idx];
        if ( isnan(plotPoint[dependentCoord]) ) {
            return NO;
        }
        *tipPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

        // Base point
        if ( !self.barBasesVary ) {
            plotPoint[dependentCoord] = CPTDecimalDoubleValue(self.baseValue);
        }
        else {
            plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarBase recordIndex:idx];
        }
        if ( isnan(plotPoint[dependentCoord]) ) {
            return NO;
        }
        *basePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
    }
    else {
        NSDecimal plotPoint[2];
        plotPoint[independentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarLocation recordIndex:idx];
        if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) {
            return NO;
        }

        // Tip point
        plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarTip recordIndex:idx];
        if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
            return NO;
        }
        *tipPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

        // Base point
        if ( !self.barBasesVary ) {
            plotPoint[dependentCoord] = self.baseValue;
        }
        else {
            plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:idx];
        }
        if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
            return NO;
        }
        *basePoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
    }

    // Determine bar width and offset.
    CGFloat barOffsetLength = [self lengthInView:self.barOffset] * self.barOffsetScale;

    // Offset
    if ( horizontalBars ) {
        basePoint->y += barOffsetLength;
        tipPoint->y  += barOffsetLength;
    }
    else {
        basePoint->x += barOffsetLength;
        tipPoint->x  += barOffsetLength;
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
    // This function is used to create a path which is used for both
    // drawing a bar and for doing hit-testing on a click/touch event
    BOOL horizontalBars = self.barsAreHorizontal;

    CGFloat barWidthLength = [self lengthInView:self.barWidth] * self.barWidthScale;
    CGFloat halfBarWidth   = CPTFloat(0.5) * barWidthLength;

    CGRect barRect;

    if ( horizontalBars ) {
        barRect = CPTRectMake(basePoint.x, basePoint.y - halfBarWidth, tipPoint.x - basePoint.x, barWidthLength);
    }
    else {
        barRect = CPTRectMake(basePoint.x - halfBarWidth, basePoint.y, barWidthLength, tipPoint.y - basePoint.y);
    }

    int widthNegative  = signbit(barRect.size.width);
    int heightNegative = signbit(barRect.size.height);

    // Align to device pixels if there is a line border.
    // Otherwise, align to view space, so fills are sharp at edges.
    // Note: may not have a context if doing hit testing.
    if ( self.alignsPointsToPixels && context ) {
        // Round bar dimensions so adjacent bars always align to the right pixel position
        const CGFloat roundingPrecision = CPTFloat(1.0e6);

        barRect.origin.x    = round(barRect.origin.x * roundingPrecision) / roundingPrecision;
        barRect.origin.y    = round(barRect.origin.y * roundingPrecision) / roundingPrecision;
        barRect.size.width  = round(barRect.size.width * roundingPrecision) / roundingPrecision;
        barRect.size.height = round(barRect.size.height * roundingPrecision) / roundingPrecision;

        if ( self.lineStyle.lineWidth > 0.0 ) {
            barRect = CPTAlignRectToUserSpace(context, barRect);
        }
        else {
            barRect = CPTAlignIntegralRectToUserSpace(context, barRect);
        }
    }

    CGFloat radius     = MIN( MIN( self.barCornerRadius, ABS(barRect.size.width) * CPTFloat(0.5) ), ABS(barRect.size.height) * CPTFloat(0.5) );
    CGFloat baseRadius = MIN( MIN( self.barBaseCornerRadius, ABS(barRect.size.width) * CPTFloat(0.5) ), ABS(barRect.size.height) * CPTFloat(0.5) );

    if ( widthNegative && (barRect.size.width > 0.0) ) {
        barRect.origin.x  += barRect.size.width;
        barRect.size.width = -barRect.size.width;
    }
    if ( heightNegative && (barRect.size.height > 0.0) ) {
        barRect.origin.y   += barRect.size.height;
        barRect.size.height = -barRect.size.height;
    }

    CGMutablePathRef path = CGPathCreateMutable();
    if ( radius == 0.0 ) {
        if ( baseRadius == 0.0 ) {
            // square corners
            CGPathAddRect(path, NULL, barRect);
        }
        else {
            CGFloat tipX = barRect.origin.x + barRect.size.width;
            CGFloat tipY = barRect.origin.y + barRect.size.height;

            // rounded at base end only
            if ( horizontalBars ) {
                CGPathMoveToPoint(path, NULL, tipX, tipY);
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, tipX, barRect.origin.y, baseRadius);
                CGPathAddLineToPoint(path, NULL, tipX, barRect.origin.y);
            }
            else {
                CGPathMoveToPoint(path, NULL, barRect.origin.x, tipY);
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, baseRadius);
                CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, tipX, tipY, baseRadius);
                CGPathAddLineToPoint(path, NULL, tipX, tipY);
            }
            CGPathCloseSubpath(path);
        }
    }
    else {
        CGFloat tipX = barRect.origin.x + barRect.size.width;
        CGFloat tipY = barRect.origin.y + barRect.size.height;

        if ( baseRadius == 0.0 ) {
            // rounded at tip end only
            CGPathMoveToPoint(path, NULL, barRect.origin.x, barRect.origin.y);
            if ( horizontalBars ) {
                CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, tipX, CGRectGetMidY(barRect), radius);
                CGPathAddArcToPoint(path, NULL, tipX, tipY, barRect.origin.x, tipY, radius);
                CGPathAddLineToPoint(path, NULL, barRect.origin.x, tipY);
            }
            else {
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, radius);
                CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, barRect.origin.y, radius);
                CGPathAddLineToPoint(path, NULL, tipX, barRect.origin.y);
            }
            CGPathCloseSubpath(path);
        }
        else {
            // rounded at both ends
            if ( horizontalBars ) {
                CGPathMoveToPoint( path, NULL, barRect.origin.x, CGRectGetMidY(barRect) );
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, baseRadius);
                CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, CGRectGetMidY(barRect), radius);
                CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, radius);
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
            }
            else {
                CGPathMoveToPoint( path, NULL, barRect.origin.x, CGRectGetMidY(barRect) );
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, radius);
                CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, CGRectGetMidY(barRect), radius);
                CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, baseRadius);
                CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
            }
            CGPathCloseSubpath(path);
        }
    }

    return path;
}

-(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint
{
    BOOL horizontalBars    = self.barsAreHorizontal;
    CGFloat barWidthLength = [self lengthInView:self.barWidth] * self.barWidthScale;
    CGFloat halfBarWidth   = CPTFloat(0.5) * barWidthLength;

    CPTPlotArea *thePlotArea = self.plotArea;

    CGFloat lowerBound = ( horizontalBars ? CGRectGetMinY(thePlotArea.bounds) : CGRectGetMinX(thePlotArea.bounds) );
    CGFloat upperBound = ( horizontalBars ? CGRectGetMaxY(thePlotArea.bounds) : CGRectGetMaxX(thePlotArea.bounds) );
    CGFloat base       = (horizontalBars ? basePoint.y : basePoint.x);

    return (base + halfBarWidth >= lowerBound) && (base - halfBarWidth <= upperBound);
}

-(CPTFill *)barFillForIndex:(NSUInteger)idx
{
    CPTFill *theBarFill = [self cachedValueForKey:CPTBarPlotBindingBarFills recordIndex:idx];

    if ( (theBarFill == nil) || (theBarFill == [CPTPlot nilData]) ) {
        theBarFill = self.fill;
    }

    return theBarFill;
}

-(CPTLineStyle *)barLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theBarLineStyle = [self cachedValueForKey:CPTBarPlotBindingBarLineStyles recordIndex:idx];

    if ( (theBarLineStyle == nil) || (theBarLineStyle == [CPTPlot nilData]) ) {
        theBarLineStyle = self.lineStyle;
    }

    return theBarLineStyle;
}

-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)idx
{
    // Get base and tip points
    CGPoint basePoint, tipPoint;
    BOOL barExists = [self barAtRecordIndex:idx basePoint:&basePoint tipPoint:&tipPoint];

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

        CPTFill *theBarFill = [self barFillForIndex:idx];
        if ( [theBarFill isKindOfClass:[CPTFill class]] ) {
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            [theBarFill fillPathInContext:context];
        }

        CPTLineStyle *theLineStyle = [self barLineStyleForIndex:idx];
        if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            [theLineStyle setLineStyleInContext:context];
            [theLineStyle strokePathInContext:context];
        }

        CGContextRestoreGState(context);

        CGPathRelease(path);
    }
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(CGContextRef)context
{
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    if ( self.drawLegendSwatchDecoration ) {
        CPTFill *theFill           = [self barFillForIndex:idx];
        CPTLineStyle *theLineStyle = [self barLineStyleForIndex:idx];

        if ( theFill || theLineStyle ) {
            CGFloat radius = MAX(self.barCornerRadius, self.barBaseCornerRadius);

            if ( [theFill isKindOfClass:[CPTFill class]] ) {
                CGContextBeginPath(context);
                AddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
                [theFill fillPathInContext:context];
            }

            if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
                [theLineStyle setLineStyleInContext:context];
                CGContextBeginPath(context);
                AddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
                [theLineStyle strokePathInContext:context];
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
    static NSArray *keys = nil;

    if ( !keys ) {
        keys = [[NSArray alloc] initWithObjects:
                @"barCornerRadius",
                @"barBaseCornerRadius",
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

/// @endcond

#pragma mark -
#pragma mark Data Labels

/// @cond

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
{
    NSDecimal theBaseDecimalValue;

    if ( !self.barBasesVary ) {
        theBaseDecimalValue = self.baseValue;
    }
    else {
        theBaseDecimalValue = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:idx];
    }

    NSNumber *location = [self cachedNumberForField:CPTBarPlotFieldBarLocation recordIndex:idx];
    NSNumber *length   = [self cachedNumberForField:CPTBarPlotFieldBarTip recordIndex:idx];

    BOOL positiveDirection    = CPTDecimalGreaterThanOrEqualTo([length decimalValue], theBaseDecimalValue);
    BOOL horizontalBars       = self.barsAreHorizontal;
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
        NSDecimal offset          = CPTDecimalMultiply( [self lengthInPlotCoordinates:self.barOffset], CPTDecimalFromCGFloat(self.barOffsetScale) );
        offsetLocation = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalAdd(decimalLocation, offset)];
    }

    // Offset
    if ( horizontalBars ) {
        label.anchorPlotPoint = [NSArray arrayWithObjects:length, offsetLocation, nil];

        if ( positiveDirection ) {
            label.displacement = CPTPointMake(self.labelOffset, 0.0);
        }
        else {
            label.displacement = CPTPointMake(-self.labelOffset, 0.0);
        }
    }
    else {
        label.anchorPlotPoint = [NSArray arrayWithObjects:offsetLocation, length, nil];

        if ( positiveDirection ) {
            label.displacement = CPTPointMake(0.0, self.labelOffset);
        }
        else {
            label.displacement = CPTPointMake(0.0, -self.labelOffset);
        }
    }

    label.contentLayer.hidden = self.hidden || isnan([location doubleValue]) || isnan([length doubleValue]);
}

/// @endcond

#pragma mark -
#pragma mark Legends

/// @cond

/** @internal
 *  @brief The number of legend entries provided by this plot.
 *  @return The number of legend entries.
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

/** @internal
 *  @brief The title text of a legend entry.
 *  @param idx The index of the desired title.
 *  @return The title of the legend entry at the requested index.
 **/
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)idx
{
    NSString *legendTitle = nil;

    id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

    if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ) {
        legendTitle = [theDataSource legendTitleForBarPlot:self recordIndex:idx];
    }
    else {
        legendTitle = [super titleForLegendEntryAtIndex:idx];
    }

    return legendTitle;
}

/** @internal
 *  @brief The styled title text of a legend entry.
 *  @param idx The index of the desired title.
 *  @return The styled title of the legend entry at the requested index.
 **/
-(NSAttributedString *)attributedTitleForLegendEntryAtIndex:(NSUInteger)idx
{
    NSAttributedString *legendTitle = nil;

    id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;

    if ( [theDataSource respondsToSelector:@selector(attributedLegendTitleForBarPlot:recordIndex:)] ) {
        legendTitle = [theDataSource attributedLegendTitleForBarPlot:self recordIndex:idx];
    }
    else {
        legendTitle = [super attributedTitleForLegendEntryAtIndex:idx];
    }

    return legendTitle;
}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @cond

-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
{
    NSUInteger idx      = NSNotFound;
    NSUInteger barCount = self.cachedDataCount;
    NSUInteger ii       = 0;

    while ( (ii < barCount) && (idx == NSNotFound) ) {
        CGMutablePathRef path = [self newBarPathWithContext:NULL recordIndex:ii];

        if ( CGPathContainsPoint(path, NULL, point, false) ) {
            idx = ii;
        }

        CGPathRelease(path);

        ii++;
    }

    return idx;
}

/// @endcond

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTBarPlotDelegate::barPlot:barWasSelectedAtRecordIndex: -barPlot:barWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTBarPlotDelegate::barPlot:barWasSelectedAtRecordIndex:withEvent: -barPlot:barWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each bar in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTBarPlotDelegate> theDelegate = self.delegate;
    if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ) {
                [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx];
            }
            if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
                [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx withEvent:event];
            }
            return YES;
        }
    }

    return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

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

-(NSArray *)barFills
{
    return [self cachedArrayForKey:CPTBarPlotBindingBarFills];
}

-(void)setBarFills:(NSArray *)newBarFills
{
    [self cacheArray:newBarFills forKey:CPTBarPlotBindingBarFills];
    [self setNeedsDisplay];
}

-(NSArray *)barLineStyles
{
    return [self cachedArrayForKey:CPTBarPlotBindingBarLineStyles];
}

-(void)setBarLineStyles:(NSArray *)newBarLineStyles
{
    [self cacheArray:newBarLineStyles forKey:CPTBarPlotBindingBarLineStyles];
    [self setNeedsDisplay];
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

-(void)setBarBaseCornerRadius:(CGFloat)newCornerRadius
{
    if ( barBaseCornerRadius != newCornerRadius ) {
        barBaseCornerRadius = ABS(newCornerRadius);
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

/// @endcond

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
            [NSNumber numberWithUnsignedInt:CPTBarPlotFieldBarBase],
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
