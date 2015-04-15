#import "CPTTradingRangePlot.h"

#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

/** @defgroup plotAnimationTradingRangePlot Trading Range Plot
 *  @brief Trading range plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsTradingRangePlot Trading Range Plot Bindings
 *  @brief Binding identifiers for trading range plots.
 *  @ingroup plotBindings
 *  @endif
 **/

NSString *const CPTTradingRangePlotBindingXValues            = @"xValues";            ///< X values.
NSString *const CPTTradingRangePlotBindingOpenValues         = @"openValues";         ///< Open price values.
NSString *const CPTTradingRangePlotBindingHighValues         = @"highValues";         ///< High price values.
NSString *const CPTTradingRangePlotBindingLowValues          = @"lowValues";          ///< Low price values.
NSString *const CPTTradingRangePlotBindingCloseValues        = @"closeValues";        ///< Close price values.
NSString *const CPTTradingRangePlotBindingIncreaseFills      = @"increaseFills";      ///< Fills used with a candlestick plot when close >= open.
NSString *const CPTTradingRangePlotBindingDecreaseFills      = @"decreaseFills";      ///< Fills used with a candlestick plot when close < open.
NSString *const CPTTradingRangePlotBindingLineStyles         = @"lineStyles";         ///< Line styles used to draw candlestick or OHLC symbols.
NSString *const CPTTradingRangePlotBindingIncreaseLineStyles = @"increaseLineStyles"; ///< Line styles used to outline candlestick symbols when close >= open.
NSString *const CPTTradingRangePlotBindingDecreaseLineStyles = @"decreaseLineStyles"; ///< Line styles used to outline candlestick symbols when close < open.

static const CPTCoordinate independentCoord = CPTCoordinateX;
static const CPTCoordinate dependentCoord   = CPTCoordinateY;

/// @cond
@interface CPTTradingRangePlot()

@property (nonatomic, readwrite, copy) CPTMutableNumericData *xValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *openValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *closeValues;
@property (nonatomic, readwrite, copy) NSArray *increaseFills;
@property (nonatomic, readwrite, copy) NSArray *decreaseFills;
@property (nonatomic, readwrite, copy) NSArray *lineStyles;
@property (nonatomic, readwrite, copy) NSArray *increaseLineStyles;
@property (nonatomic, readwrite, copy) NSArray *decreaseLineStyles;
@property (nonatomic, readwrite, assign) NSUInteger pointingDeviceDownIndex;

-(void)drawCandleStickInContext:(CGContextRef)context atIndex:(NSUInteger)idx x:(CGFloat)x open:(CGFloat)openValue close:(CGFloat)closeValue high:(CGFloat)highValue low:(CGFloat)lowValue alignPoints:(BOOL)alignPoints;
-(void)drawOHLCInContext:(CGContextRef)context atIndex:(NSUInteger)idx x:(CGFloat)x open:(CGFloat)openValue close:(CGFloat)closeValue high:(CGFloat)highValue low:(CGFloat)lowValue alignPoints:(BOOL)alignPoints;

-(CPTFill *)increaseFillForIndex:(NSUInteger)idx;
-(CPTFill *)decreaseFillForIndex:(NSUInteger)idx;

-(CPTLineStyle *)lineStyleForIndex:(NSUInteger)idx;
-(CPTLineStyle *)increaseLineStyleForIndex:(NSUInteger)idx;
-(CPTLineStyle *)decreaseLineStyleForIndex:(NSUInteger)idx;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A trading range financial plot.
 *  @see See @ref plotAnimationTradingRangePlot "Trading Range Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsTradingRangePlot "Trading Range Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTTradingRangePlot

@dynamic xValues;
@dynamic openValues;
@dynamic highValues;
@dynamic lowValues;
@dynamic closeValues;
@dynamic increaseFills;
@dynamic decreaseFills;
@dynamic lineStyles;
@dynamic increaseLineStyles;
@dynamic decreaseLineStyles;

/** @property CPTLineStyle *lineStyle
 *  @brief The line style used to draw candlestick or OHLC symbols.
 **/
@synthesize lineStyle;

/** @property CPTLineStyle *increaseLineStyle
 *  @brief The line style used to outline candlestick symbols or draw OHLC symbols when close >= open.
 *  If @nil, will use @ref lineStyle instead.
 **/
@synthesize increaseLineStyle;

/** @property CPTLineStyle *decreaseLineStyle
 *  @brief The line style used to outline candlestick symbols or draw OHLC symbols when close < open.
 *  If @nil, will use @ref lineStyle instead.
 **/
@synthesize decreaseLineStyle;

/** @property CPTFill *increaseFill
 *  @brief The fill used with a candlestick plot when close >= open.
 **/
@synthesize increaseFill;

/** @property CPTFill *decreaseFill
 *  @brief The fill used with a candlestick plot when close < open.
 **/
@synthesize decreaseFill;

/** @property CPTTradingRangePlotStyle plotStyle
 *  @brief The style of trading range plot drawn. The default is #CPTTradingRangePlotStyleOHLC.
 **/
@synthesize plotStyle;

/** @property CGFloat barWidth
 *  @brief The width of bars in candlestick plots (view coordinates).
 *  @ingroup plotAnimationTradingRangePlot
 **/
@synthesize barWidth;

/** @property CGFloat stickLength
 *  @brief The length of close and open sticks on OHLC plots (view coordinates).
 *  @ingroup plotAnimationTradingRangePlot
 **/
@synthesize stickLength;

/** @property CGFloat barCornerRadius
 *  @brief The corner radius used for candlestick plots.
 *  Defaults to @num{0.0}.
 *  @ingroup plotAnimationTradingRangePlot
 **/
@synthesize barCornerRadius;

/** @property BOOL showBarBorder
 *  @brief If @YES, the candlestick body will show a border.
 *  @ingroup plotAnimationTradingRangePlot
 **/
@synthesize showBarBorder;

/** @internal
 *  @property NSUInteger pointingDeviceDownIndex
 *  @brief The index that was selected on the pointing device down event.
 **/
@synthesize pointingDeviceDownIndex;

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTTradingRangePlot class] ) {
        [self exposeBinding:CPTTradingRangePlotBindingXValues];
        [self exposeBinding:CPTTradingRangePlotBindingOpenValues];
        [self exposeBinding:CPTTradingRangePlotBindingHighValues];
        [self exposeBinding:CPTTradingRangePlotBindingLowValues];
        [self exposeBinding:CPTTradingRangePlotBindingCloseValues];
        [self exposeBinding:CPTTradingRangePlotBindingIncreaseFills];
        [self exposeBinding:CPTTradingRangePlotBindingDecreaseFills];
        [self exposeBinding:CPTTradingRangePlotBindingLineStyles];
        [self exposeBinding:CPTTradingRangePlotBindingIncreaseLineStyles];
        [self exposeBinding:CPTTradingRangePlotBindingDecreaseLineStyles];
    }
}
#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTTradingRangePlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref plotStyle = #CPTTradingRangePlotStyleOHLC
 *  - @ref lineStyle = default line style
 *  - @ref increaseLineStyle = @nil
 *  - @ref decreaseLineStyle = @nil
 *  - @ref increaseFill = solid white fill
 *  - @ref decreaseFill = solid black fill
 *  - @ref barWidth = @num{5.0}
 *  - @ref stickLength = @num{3.0}
 *  - @ref barCornerRadius = @num{0.0}
 *  - @ref showBarBorder = @YES
 *  - @ref labelField = #CPTTradingRangePlotFieldClose
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTTradingRangePlot object.
 **/
-(instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        plotStyle         = CPTTradingRangePlotStyleOHLC;
        lineStyle         = [[CPTLineStyle alloc] init];
        increaseLineStyle = nil;
        decreaseLineStyle = nil;
        increaseFill      = [[CPTFill alloc] initWithColor:[CPTColor whiteColor]];
        decreaseFill      = [[CPTFill alloc] initWithColor:[CPTColor blackColor]];
        barWidth          = CPTFloat(5.0);
        stickLength       = CPTFloat(3.0);
        barCornerRadius   = CPTFloat(0.0);
        showBarBorder     = YES;

        pointingDeviceDownIndex = NSNotFound;

        self.labelField = CPTTradingRangePlotFieldClose;
    }
    return self;
}

/// @}

/// @cond

-(instancetype)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTTradingRangePlot *theLayer = (CPTTradingRangePlot *)layer;

        plotStyle         = theLayer->plotStyle;
        lineStyle         = theLayer->lineStyle;
        increaseLineStyle = theLayer->increaseLineStyle;
        decreaseLineStyle = theLayer->decreaseLineStyle;
        increaseFill      = theLayer->increaseFill;
        decreaseFill      = theLayer->decreaseFill;
        barWidth          = theLayer->barWidth;
        stickLength       = theLayer->stickLength;
        barCornerRadius   = theLayer->barCornerRadius;
        showBarBorder     = theLayer->showBarBorder;

        pointingDeviceDownIndex = NSNotFound;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.lineStyle forKey:@"CPTTradingRangePlot.lineStyle"];
    [coder encodeObject:self.increaseLineStyle forKey:@"CPTTradingRangePlot.increaseLineStyle"];
    [coder encodeObject:self.decreaseLineStyle forKey:@"CPTTradingRangePlot.decreaseLineStyle"];
    [coder encodeObject:self.increaseFill forKey:@"CPTTradingRangePlot.increaseFill"];
    [coder encodeObject:self.decreaseFill forKey:@"CPTTradingRangePlot.decreaseFill"];
    [coder encodeInteger:self.plotStyle forKey:@"CPTTradingRangePlot.plotStyle"];
    [coder encodeCGFloat:self.barWidth forKey:@"CPTTradingRangePlot.barWidth"];
    [coder encodeCGFloat:self.stickLength forKey:@"CPTTradingRangePlot.stickLength"];
    [coder encodeCGFloat:self.barCornerRadius forKey:@"CPTTradingRangePlot.barCornerRadius"];
    [coder encodeBool:self.showBarBorder forKey:@"CPTTradingRangePlot.showBarBorder"];

    // No need to archive these properties:
    // pointingDeviceDownIndex
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        lineStyle         = [[coder decodeObjectForKey:@"CPTTradingRangePlot.lineStyle"] copy];
        increaseLineStyle = [[coder decodeObjectForKey:@"CPTTradingRangePlot.increaseLineStyle"] copy];
        decreaseLineStyle = [[coder decodeObjectForKey:@"CPTTradingRangePlot.decreaseLineStyle"] copy];
        increaseFill      = [[coder decodeObjectForKey:@"CPTTradingRangePlot.increaseFill"] copy];
        decreaseFill      = [[coder decodeObjectForKey:@"CPTTradingRangePlot.decreaseFill"] copy];
        plotStyle         = (CPTTradingRangePlotStyle)[coder decodeIntegerForKey : @"CPTTradingRangePlot.plotStyle"];
        barWidth          = [coder decodeCGFloatForKey:@"CPTTradingRangePlot.barWidth"];
        stickLength       = [coder decodeCGFloatForKey:@"CPTTradingRangePlot.stickLength"];
        barCornerRadius   = [coder decodeCGFloatForKey:@"CPTTradingRangePlot.barCornerRadius"];
        showBarBorder     = [coder decodeBoolForKey:@"CPTTradingRangePlot.showBarBorder"];

        pointingDeviceDownIndex = NSNotFound;
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

    // Fills
    [self reloadBarFillsInIndexRange:indexRange];

    // Line styles
    [self reloadBarLineStylesInIndexRange:indexRange];
}

-(void)reloadPlotDataInIndexRange:(NSRange)indexRange
{
    [super reloadPlotDataInIndexRange:indexRange];

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:indexRange] ) {
        id<CPTTradingRangePlotDataSource> theDataSource = (id<CPTTradingRangePlotDataSource>)self.dataSource;

        if ( theDataSource ) {
            id newXValues = [self numbersFromDataSourceForField:CPTTradingRangePlotFieldX recordIndexRange:indexRange];
            [self cacheNumbers:newXValues forField:CPTTradingRangePlotFieldX atRecordIndex:indexRange.location];
            id newOpenValues = [self numbersFromDataSourceForField:CPTTradingRangePlotFieldOpen recordIndexRange:indexRange];
            [self cacheNumbers:newOpenValues forField:CPTTradingRangePlotFieldOpen atRecordIndex:indexRange.location];
            id newHighValues = [self numbersFromDataSourceForField:CPTTradingRangePlotFieldHigh recordIndexRange:indexRange];
            [self cacheNumbers:newHighValues forField:CPTTradingRangePlotFieldHigh atRecordIndex:indexRange.location];
            id newLowValues = [self numbersFromDataSourceForField:CPTTradingRangePlotFieldLow recordIndexRange:indexRange];
            [self cacheNumbers:newLowValues forField:CPTTradingRangePlotFieldLow atRecordIndex:indexRange.location];
            id newCloseValues = [self numbersFromDataSourceForField:CPTTradingRangePlotFieldClose recordIndexRange:indexRange];
            [self cacheNumbers:newCloseValues forField:CPTTradingRangePlotFieldClose atRecordIndex:indexRange.location];
        }
        else {
            self.xValues     = nil;
            self.openValues  = nil;
            self.highValues  = nil;
            self.lowValues   = nil;
            self.closeValues = nil;
        }
    }
}

/// @endcond

/**
 *  @brief Reload all bar fills from the data source immediately.
 **/
-(void)reloadBarFills
{
    [self reloadBarFillsInIndexRange:NSMakeRange(0, self.cachedDataCount)];
}

/** @brief Reload bar fills in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadBarFillsInIndexRange:(NSRange)indexRange
{
    id<CPTTradingRangePlotDataSource> theDataSource = (id<CPTTradingRangePlotDataSource>)self.dataSource;

    BOOL needsLegendUpdate = NO;

    // Increase fills
    if ( [theDataSource respondsToSelector:@selector(increaseFillsForTradingRangePlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource increaseFillsForTradingRangePlot:self recordIndexRange:indexRange]
                  forKey:CPTTradingRangePlotBindingIncreaseFills
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(increaseFillForTradingRangePlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTFill *dataSourceFill = [theDataSource increaseFillForTradingRangePlot:self recordIndex:idx];
            if ( dataSourceFill ) {
                [array addObject:dataSourceFill];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTTradingRangePlotBindingIncreaseFills atRecordIndex:indexRange.location];
    }

    // Decrease fills
    if ( [theDataSource respondsToSelector:@selector(decreaseFillsForTradingRangePlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource decreaseFillsForTradingRangePlot:self recordIndexRange:indexRange]
                  forKey:CPTTradingRangePlotBindingDecreaseFills
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(decreaseFillForTradingRangePlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTFill *dataSourceFill = [theDataSource decreaseFillForTradingRangePlot:self recordIndex:idx];
            if ( dataSourceFill ) {
                [array addObject:dataSourceFill];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTTradingRangePlotBindingDecreaseFills atRecordIndex:indexRange.location];
    }

    // Legend
    if ( needsLegendUpdate ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }

    [self setNeedsDisplay];
}

/**
 *  @brief Reload all bar line styles from the data source immediately.
 **/
-(void)reloadBarLineStyles
{
    [self reloadBarLineStylesInIndexRange:NSMakeRange(0, self.cachedDataCount)];
}

/** @brief Reload bar line styles in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadBarLineStylesInIndexRange:(NSRange)indexRange
{
    id<CPTTradingRangePlotDataSource> theDataSource = (id<CPTTradingRangePlotDataSource>)self.dataSource;

    BOOL needsLegendUpdate = NO;

    // Line style
    if ( [theDataSource respondsToSelector:@selector(lineStylesForTradingRangePlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource lineStylesForTradingRangePlot:self recordIndexRange:indexRange]
                  forKey:CPTTradingRangePlotBindingLineStyles
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(lineStyleForTradingRangePlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLineStyle *dataSourceLineStyle = [theDataSource lineStyleForTradingRangePlot:self recordIndex:idx];
            if ( dataSourceLineStyle ) {
                [array addObject:dataSourceLineStyle];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTTradingRangePlotBindingLineStyles atRecordIndex:indexRange.location];
    }

    // Increase line style
    if ( [theDataSource respondsToSelector:@selector(increaseLineStylesForTradingRangePlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource increaseLineStylesForTradingRangePlot:self recordIndexRange:indexRange]
                  forKey:CPTTradingRangePlotBindingIncreaseLineStyles
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(increaseLineStyleForTradingRangePlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLineStyle *dataSourceLineStyle = [theDataSource increaseLineStyleForTradingRangePlot:self recordIndex:idx];
            if ( dataSourceLineStyle ) {
                [array addObject:dataSourceLineStyle];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTTradingRangePlotBindingIncreaseLineStyles atRecordIndex:indexRange.location];
    }

    // Decrease line styles
    if ( [theDataSource respondsToSelector:@selector(decreaseLineStylesForTradingRangePlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource decreaseLineStylesForTradingRangePlot:self recordIndexRange:indexRange]
                  forKey:CPTTradingRangePlotBindingDecreaseLineStyles
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(decreaseLineStyleForTradingRangePlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject          = [CPTPlot nilData];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex   = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLineStyle *dataSourceLineStyle = [theDataSource decreaseLineStyleForTradingRangePlot:self recordIndex:idx];
            if ( dataSourceLineStyle ) {
                [array addObject:dataSourceLineStyle];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTTradingRangePlotBindingDecreaseLineStyles atRecordIndex:indexRange.location];
    }

    // Legend
    if ( needsLegendUpdate ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }

    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTMutableNumericData *locations = [self cachedNumbersForField:CPTTradingRangePlotFieldX];
    CPTMutableNumericData *opens     = [self cachedNumbersForField:CPTTradingRangePlotFieldOpen];
    CPTMutableNumericData *highs     = [self cachedNumbersForField:CPTTradingRangePlotFieldHigh];
    CPTMutableNumericData *lows      = [self cachedNumbersForField:CPTTradingRangePlotFieldLow];
    CPTMutableNumericData *closes    = [self cachedNumbersForField:CPTTradingRangePlotFieldClose];

    NSUInteger sampleCount = locations.numberOfSamples;
    if ( sampleCount == 0 ) {
        return;
    }
    if ( (opens == nil) || (highs == nil) || (lows == nil) || (closes == nil) ) {
        return;
    }

    if ( (opens.numberOfSamples != sampleCount) || (highs.numberOfSamples != sampleCount) || (lows.numberOfSamples != sampleCount) || (closes.numberOfSamples != sampleCount) ) {
        [NSException raise:CPTException format:@"Mismatching number of data values in trading range plot"];
    }

    [super renderAsVectorInContext:context];

    CGPoint openPoint, highPoint, lowPoint, closePoint;

    CPTPlotSpace *thePlotSpace            = self.plotSpace;
    CPTTradingRangePlotStyle thePlotStyle = self.plotStyle;
    BOOL alignPoints                      = self.alignsPointsToPixels;

    CGContextBeginTransparencyLayer(context, NULL);

    if ( self.doublePrecisionCache ) {
        const double *locationBytes = (const double *)locations.data.bytes;
        const double *openBytes     = (const double *)opens.data.bytes;
        const double *highBytes     = (const double *)highs.data.bytes;
        const double *lowBytes      = (const double *)lows.data.bytes;
        const double *closeBytes    = (const double *)closes.data.bytes;

        for ( NSUInteger i = 0; i < sampleCount; i++ ) {
            double plotPoint[2];
            plotPoint[independentCoord] = *locationBytes++;
            if ( isnan(plotPoint[independentCoord]) ) {
                openBytes++;
                highBytes++;
                lowBytes++;
                closeBytes++;
                continue;
            }

            // open point
            plotPoint[dependentCoord] = *openBytes++;
            if ( isnan(plotPoint[dependentCoord]) ) {
                openPoint = CPTPointMake(NAN, NAN);
            }
            else {
                openPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // high point
            plotPoint[dependentCoord] = *highBytes++;
            if ( isnan(plotPoint[dependentCoord]) ) {
                highPoint = CPTPointMake(NAN, NAN);
            }
            else {
                highPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // low point
            plotPoint[dependentCoord] = *lowBytes++;
            if ( isnan(plotPoint[dependentCoord]) ) {
                lowPoint = CPTPointMake(NAN, NAN);
            }
            else {
                lowPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // close point
            plotPoint[dependentCoord] = *closeBytes++;
            if ( isnan(plotPoint[dependentCoord]) ) {
                closePoint = CPTPointMake(NAN, NAN);
            }
            else {
                closePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }

            CGFloat xCoord = openPoint.x;
            if ( isnan(xCoord) ) {
                xCoord = highPoint.x;
            }
            else if ( isnan(xCoord) ) {
                xCoord = lowPoint.x;
            }
            else if ( isnan(xCoord) ) {
                xCoord = closePoint.x;
            }

            if ( !isnan(xCoord) ) {
                // Draw
                switch ( thePlotStyle ) {
                    case CPTTradingRangePlotStyleOHLC:
                        [self drawOHLCInContext:context
                                        atIndex:i
                                              x:xCoord
                                           open:openPoint.y
                                          close:closePoint.y
                                           high:highPoint.y
                                            low:lowPoint.y
                                    alignPoints:alignPoints];
                        break;

                    case CPTTradingRangePlotStyleCandleStick:
                        [self drawCandleStickInContext:context
                                               atIndex:i
                                                     x:xCoord
                                                  open:openPoint.y
                                                 close:closePoint.y
                                                  high:highPoint.y
                                                   low:lowPoint.y
                                           alignPoints:alignPoints];
                        break;
                }
            }
        }
    }
    else {
        const NSDecimal *locationBytes = (const NSDecimal *)locations.data.bytes;
        const NSDecimal *openBytes     = (const NSDecimal *)opens.data.bytes;
        const NSDecimal *highBytes     = (const NSDecimal *)highs.data.bytes;
        const NSDecimal *lowBytes      = (const NSDecimal *)lows.data.bytes;
        const NSDecimal *closeBytes    = (const NSDecimal *)closes.data.bytes;

        for ( NSUInteger i = 0; i < sampleCount; i++ ) {
            NSDecimal plotPoint[2];
            plotPoint[independentCoord] = *locationBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) {
                openBytes++;
                highBytes++;
                lowBytes++;
                closeBytes++;
                continue;
            }

            // open point
            plotPoint[dependentCoord] = *openBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
                openPoint = CPTPointMake(NAN, NAN);
            }
            else {
                openPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // high point
            plotPoint[dependentCoord] = *highBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
                highPoint = CPTPointMake(NAN, NAN);
            }
            else {
                highPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // low point
            plotPoint[dependentCoord] = *lowBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
                lowPoint = CPTPointMake(NAN, NAN);
            }
            else {
                lowPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
            }

            // close point
            plotPoint[dependentCoord] = *closeBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
                closePoint = CPTPointMake(NAN, NAN);
            }
            else {
                closePoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
            }

            CGFloat xCoord = openPoint.x;
            if ( isnan(xCoord) ) {
                xCoord = highPoint.x;
            }
            else if ( isnan(xCoord) ) {
                xCoord = lowPoint.x;
            }
            else if ( isnan(xCoord) ) {
                xCoord = closePoint.x;
            }

            if ( !isnan(xCoord) ) {
                // Draw
                switch ( thePlotStyle ) {
                    case CPTTradingRangePlotStyleOHLC:
                        [self drawOHLCInContext:context
                                        atIndex:i
                                              x:xCoord
                                           open:openPoint.y
                                          close:closePoint.y
                                           high:highPoint.y
                                            low:lowPoint.y
                                    alignPoints:alignPoints];
                        break;

                    case CPTTradingRangePlotStyleCandleStick:
                        [self drawCandleStickInContext:context
                                               atIndex:i
                                                     x:xCoord
                                                  open:openPoint.y
                                                 close:closePoint.y
                                                  high:highPoint.y
                                                   low:lowPoint.y
                                           alignPoints:alignPoints];
                        break;
                }
            }
        }
    }

    CGContextEndTransparencyLayer(context);
}

-(void)drawCandleStickInContext:(CGContextRef)context
                        atIndex:(NSUInteger)idx
                              x:(CGFloat)x
                           open:(CGFloat)openValue
                          close:(CGFloat)closeValue
                           high:(CGFloat)highValue
                            low:(CGFloat)lowValue
                    alignPoints:(BOOL)alignPoints
{
    const CGFloat halfBarWidth       = CPTFloat(0.5) * self.barWidth;
    CPTFill *currentBarFill          = nil;
    CPTLineStyle *theBorderLineStyle = nil;

    if ( !isnan(openValue) && !isnan(closeValue) ) {
        if ( openValue < closeValue ) {
            theBorderLineStyle = [self increaseLineStyleForIndex:idx];
            currentBarFill     = [self increaseFillForIndex:idx];
        }
        else if ( openValue > closeValue ) {
            theBorderLineStyle = [self decreaseLineStyleForIndex:idx];
            currentBarFill     = [self decreaseFillForIndex:idx];
        }
        else {
            theBorderLineStyle = [self lineStyleForIndex:idx];
            currentBarFill     = [CPTFill fillWithColor:theBorderLineStyle.lineColor];
        }
    }

    CPTAlignPointFunction alignmentFunction = CPTAlignPointToUserSpace;

    BOOL hasLineStyle = [theBorderLineStyle isKindOfClass:[CPTLineStyle class]];
    if ( hasLineStyle ) {
        [theBorderLineStyle setLineStyleInContext:context];

        CGFloat lineWidth = theBorderLineStyle.lineWidth;
        if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
    }

    // high - low only
    if ( hasLineStyle && !isnan(highValue) && !isnan(lowValue) && ( isnan(openValue) || isnan(closeValue) ) ) {
        CGPoint alignedHighPoint = CPTPointMake(x, highValue);
        CGPoint alignedLowPoint  = CPTPointMake(x, lowValue);
        if ( alignPoints ) {
            alignedHighPoint = alignmentFunction(context, alignedHighPoint);
            alignedLowPoint  = alignmentFunction(context, alignedLowPoint);
        }

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);

        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        [theBorderLineStyle strokePathInContext:context];

        CGPathRelease(path);
    }

    // open-close
    if ( !isnan(openValue) && !isnan(closeValue) ) {
        if ( currentBarFill || hasLineStyle ) {
            CGFloat radius = MIN(self.barCornerRadius, halfBarWidth);
            radius = MIN( radius, ABS(closeValue - openValue) );

            CGPoint alignedPoint1 = CPTPointMake(x + halfBarWidth, openValue);
            CGPoint alignedPoint2 = CPTPointMake(x + halfBarWidth, closeValue);
            CGPoint alignedPoint3 = CPTPointMake(x, closeValue);
            CGPoint alignedPoint4 = CPTPointMake(x - halfBarWidth, closeValue);
            CGPoint alignedPoint5 = CPTPointMake(x - halfBarWidth, openValue);
            if ( alignPoints ) {
                if ( hasLineStyle && self.showBarBorder ) {
                    alignedPoint1 = alignmentFunction(context, alignedPoint1);
                    alignedPoint2 = alignmentFunction(context, alignedPoint2);
                    alignedPoint3 = alignmentFunction(context, alignedPoint3);
                    alignedPoint4 = alignmentFunction(context, alignedPoint4);
                    alignedPoint5 = alignmentFunction(context, alignedPoint5);
                }
                else {
                    alignedPoint1 = CPTAlignIntegralPointToUserSpace(context, alignedPoint1);
                    alignedPoint2 = CPTAlignIntegralPointToUserSpace(context, alignedPoint2);
                    alignedPoint3 = CPTAlignIntegralPointToUserSpace(context, alignedPoint3);
                    alignedPoint4 = CPTAlignIntegralPointToUserSpace(context, alignedPoint4);
                    alignedPoint5 = CPTAlignIntegralPointToUserSpace(context, alignedPoint5);
                }
            }

            if ( hasLineStyle && (openValue == closeValue) ) {
                // #285 Draw a cross with open/close values marked
                const CGFloat halfLineWidth = CPTFloat(0.5) * theBorderLineStyle.lineWidth;

                alignedPoint1.y -= halfLineWidth;
                alignedPoint2.y += halfLineWidth;
                alignedPoint3.y += halfLineWidth;
                alignedPoint4.y += halfLineWidth;
                alignedPoint5.y -= halfLineWidth;
            }

            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
            CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
            CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
            CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
            CGPathCloseSubpath(path);

            if ( [currentBarFill isKindOfClass:[CPTFill class]] ) {
                CGContextBeginPath(context);
                CGContextAddPath(context, path);
                [currentBarFill fillPathInContext:context];
            }

            if ( hasLineStyle ) {
                if ( !self.showBarBorder ) {
                    CGPathRelease(path);
                    path = CGPathCreateMutable();
                }

                if ( !isnan(lowValue) ) {
                    if ( lowValue < MIN(openValue, closeValue) ) {
                        CGPoint alignedStartPoint = CPTPointMake( x, MIN(openValue, closeValue) );
                        CGPoint alignedLowPoint   = CPTPointMake(x, lowValue);
                        if ( alignPoints ) {
                            alignedStartPoint = alignmentFunction(context, alignedStartPoint);
                            alignedLowPoint   = alignmentFunction(context, alignedLowPoint);
                        }

                        CGPathMoveToPoint(path, NULL, alignedStartPoint.x, alignedStartPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                }
                if ( !isnan(highValue) ) {
                    if ( highValue > MAX(openValue, closeValue) ) {
                        CGPoint alignedStartPoint = CPTPointMake( x, MAX(openValue, closeValue) );
                        CGPoint alignedHighPoint  = CPTPointMake(x, highValue);
                        if ( alignPoints ) {
                            alignedStartPoint = alignmentFunction(context, alignedStartPoint);
                            alignedHighPoint  = alignmentFunction(context, alignedHighPoint);
                        }

                        CGPathMoveToPoint(path, NULL, alignedStartPoint.x, alignedStartPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                    }
                }
                CGContextBeginPath(context);
                CGContextAddPath(context, path);
                [theBorderLineStyle strokePathInContext:context];
            }

            CGPathRelease(path);
        }
    }
}

-(void)drawOHLCInContext:(CGContextRef)context
                 atIndex:(NSUInteger)idx
                       x:(CGFloat)x
                    open:(CGFloat)openValue
                   close:(CGFloat)closeValue
                    high:(CGFloat)highValue
                     low:(CGFloat)lowValue
             alignPoints:(BOOL)alignPoints
{
    CPTLineStyle *theLineStyle = [self lineStyleForIndex:idx];

    if ( !isnan(openValue) && !isnan(closeValue) ) {
        if ( openValue < closeValue ) {
            CPTLineStyle *lineStyleForIncrease = [self increaseLineStyleForIndex:idx];
            if ( [lineStyleForIncrease isKindOfClass:[CPTLineStyle class]] ) {
                theLineStyle = lineStyleForIncrease;
            }
        }
        else if ( openValue > closeValue ) {
            CPTLineStyle *lineStyleForDecrease = [self decreaseLineStyleForIndex:idx];
            if ( [lineStyleForDecrease isKindOfClass:[CPTLineStyle class]] ) {
                theLineStyle = lineStyleForDecrease;
            }
        }
    }

    if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
        CGFloat theStickLength = self.stickLength;
        CGMutablePathRef path  = CGPathCreateMutable();

        CPTAlignPointFunction alignmentFunction = CPTAlignPointToUserSpace;

        CGFloat lineWidth = theLineStyle.lineWidth;
        if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }

        // high-low
        if ( !isnan(highValue) && !isnan(lowValue) ) {
            CGPoint alignedHighPoint = CPTPointMake(x, highValue);
            CGPoint alignedLowPoint  = CPTPointMake(x, lowValue);
            if ( alignPoints ) {
                alignedHighPoint = alignmentFunction(context, alignedHighPoint);
                alignedLowPoint  = alignmentFunction(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // open
        if ( !isnan(openValue) ) {
            CGPoint alignedOpenStartPoint = CPTPointMake(x, openValue);
            CGPoint alignedOpenEndPoint   = CPTPointMake(x - theStickLength, openValue); // left side
            if ( alignPoints ) {
                alignedOpenStartPoint = alignmentFunction(context, alignedOpenStartPoint);
                alignedOpenEndPoint   = alignmentFunction(context, alignedOpenEndPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedOpenStartPoint.x, alignedOpenStartPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedOpenEndPoint.x, alignedOpenEndPoint.y);
        }

        // close
        if ( !isnan(closeValue) ) {
            CGPoint alignedCloseStartPoint = CPTPointMake(x, closeValue);
            CGPoint alignedCloseEndPoint   = CPTPointMake(x + theStickLength, closeValue); // right side
            if ( alignPoints ) {
                alignedCloseStartPoint = alignmentFunction(context, alignedCloseStartPoint);
                alignedCloseEndPoint   = alignmentFunction(context, alignedCloseEndPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedCloseStartPoint.x, alignedCloseStartPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedCloseEndPoint.x, alignedCloseEndPoint.y);
        }

        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        [theLineStyle setLineStyleInContext:context];
        [theLineStyle strokePathInContext:context];
        CGPathRelease(path);
    }
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(CGContextRef)context
{
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    if ( self.drawLegendSwatchDecoration ) {
        [self.lineStyle setLineStyleInContext:context];

        switch ( self.plotStyle ) {
            case CPTTradingRangePlotStyleOHLC:
                [self drawOHLCInContext:context
                                atIndex:idx
                                      x:CGRectGetMidX(rect)
                                   open:CGRectGetMinY(rect) + rect.size.height / CPTFloat(3.0)
                                  close:CGRectGetMinY(rect) + rect.size.height * (CGFloat)(2.0 / 3.0)
                                   high:CGRectGetMaxY(rect)
                                    low:CGRectGetMinY(rect)
                            alignPoints:YES];
                break;

            case CPTTradingRangePlotStyleCandleStick:
                [self drawCandleStickInContext:context
                                       atIndex:idx
                                             x:CGRectGetMidX(rect)
                                          open:CGRectGetMinY(rect) + rect.size.height / CPTFloat(3.0)
                                         close:CGRectGetMinY(rect) + rect.size.height * (CGFloat)(2.0 / 3.0)
                                          high:CGRectGetMaxY(rect)
                                           low:CGRectGetMinY(rect)
                                   alignPoints:YES];
                break;
        }
    }
}

-(CPTFill *)increaseFillForIndex:(NSUInteger)idx
{
    CPTFill *theFill = [self cachedValueForKey:CPTTradingRangePlotBindingIncreaseFills recordIndex:idx];

    if ( (theFill == nil) || (theFill == [CPTPlot nilData]) ) {
        theFill = self.increaseFill;
    }

    return theFill;
}

-(CPTFill *)decreaseFillForIndex:(NSUInteger)idx
{
    CPTFill *theFill = [self cachedValueForKey:CPTTradingRangePlotBindingDecreaseFills recordIndex:idx];

    if ( (theFill == nil) || (theFill == [CPTPlot nilData]) ) {
        theFill = self.decreaseFill;
    }

    return theFill;
}

-(CPTLineStyle *)lineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theLineStyle = [self cachedValueForKey:CPTTradingRangePlotBindingLineStyles recordIndex:idx];

    if ( (theLineStyle == nil) || (theLineStyle == [CPTPlot nilData]) ) {
        theLineStyle = self.lineStyle;
    }

    return theLineStyle;
}

-(CPTLineStyle *)increaseLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theLineStyle = [self cachedValueForKey:CPTTradingRangePlotBindingIncreaseLineStyles recordIndex:idx];

    if ( (theLineStyle == nil) || (theLineStyle == [CPTPlot nilData]) ) {
        theLineStyle = self.increaseLineStyle;
    }

    if ( theLineStyle == nil ) {
        theLineStyle = [self lineStyleForIndex:idx];
    }

    return theLineStyle;
}

-(CPTLineStyle *)decreaseLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theLineStyle = [self cachedValueForKey:CPTTradingRangePlotBindingDecreaseLineStyles recordIndex:idx];

    if ( (theLineStyle == nil) || (theLineStyle == [CPTPlot nilData]) ) {
        theLineStyle = self.decreaseLineStyle;
    }

    if ( theLineStyle == nil ) {
        theLineStyle = [self lineStyleForIndex:idx];
    }

    return theLineStyle;
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
    static NSSet *keys               = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithArray:@[@"barWidth",
                                     @"stickLength",
                                     @"barCornerRadius",
                                     @"showBarBorder"]];
    });

    if ( [keys containsObject:aKey] ) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:aKey];
    }
}

/// @endcond

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
    return 5;
}

-(NSArray *)fieldIdentifiers
{
    return @[@(CPTTradingRangePlotFieldX),
             @(CPTTradingRangePlotFieldOpen),
             @(CPTTradingRangePlotFieldClose),
             @(CPTTradingRangePlotFieldHigh),
             @(CPTTradingRangePlotFieldLow)];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
    NSArray *result = nil;

    switch ( coord ) {
        case CPTCoordinateX:
            result = @[@(CPTTradingRangePlotFieldX)];
            break;

        case CPTCoordinateY:
            result = @[@(CPTTradingRangePlotFieldOpen),
                       @(CPTTradingRangePlotFieldLow),
                       @(CPTTradingRangePlotFieldHigh),
                       @(CPTTradingRangePlotFieldClose)];
            break;

        default:
            [NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

-(CPTCoordinate)coordinateForFieldIdentifier:(NSUInteger)field
{
    CPTCoordinate coordinate = CPTCoordinateNone;

    switch ( field ) {
        case CPTTradingRangePlotFieldX:
            coordinate = CPTCoordinateX;
            break;

        case CPTTradingRangePlotFieldOpen:
        case CPTTradingRangePlotFieldLow:
        case CPTTradingRangePlotFieldHigh:
        case CPTTradingRangePlotFieldClose:
            coordinate = CPTCoordinateY;
            break;

        default:
            break;
    }

    return coordinate;
}

/// @endcond

#pragma mark -
#pragma mark Data Labels

/// @cond

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
{
    BOOL positiveDirection = YES;
    CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

    if ( CPTDecimalLessThan( yRange.length, CPTDecimalFromInteger(0) ) ) {
        positiveDirection = !positiveDirection;
    }

    NSNumber *xValue = [self cachedNumberForField:CPTTradingRangePlotFieldX recordIndex:idx];
    NSNumber *yValue;
    NSArray *yValues = @[[self cachedNumberForField:CPTTradingRangePlotFieldOpen recordIndex:idx],
                         [self cachedNumberForField:CPTTradingRangePlotFieldClose recordIndex:idx],
                         [self cachedNumberForField:CPTTradingRangePlotFieldHigh recordIndex:idx],
                         [self cachedNumberForField:CPTTradingRangePlotFieldLow recordIndex:idx]];
    NSArray *yValuesSorted = [yValues sortedArrayUsingSelector:@selector(compare:)];
    if ( positiveDirection ) {
        yValue = [yValuesSorted lastObject];
    }
    else {
        yValue = yValuesSorted[0];
    }

    label.anchorPlotPoint = @[xValue, yValue];

    if ( positiveDirection ) {
        label.displacement = CPTPointMake(0.0, self.labelOffset);
    }
    else {
        label.displacement = CPTPointMake(0.0, -self.labelOffset);
    }

    label.contentLayer.hidden = self.hidden || isnan([xValue doubleValue]) || isnan([yValue doubleValue]);
}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User Interaction

/// @cond

-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
{
    NSUInteger dataCount = self.cachedDataCount;

    CPTMutableNumericData *locations = [self cachedNumbersForField:CPTTradingRangePlotFieldX];
    CPTMutableNumericData *opens     = [self cachedNumbersForField:CPTTradingRangePlotFieldOpen];
    CPTMutableNumericData *highs     = [self cachedNumbersForField:CPTTradingRangePlotFieldHigh];
    CPTMutableNumericData *lows      = [self cachedNumbersForField:CPTTradingRangePlotFieldLow];
    CPTMutableNumericData *closes    = [self cachedNumbersForField:CPTTradingRangePlotFieldClose];

    CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
    CPTPlotRange *xRange         = thePlotSpace.xRange;
    CPTPlotRange *yRange         = thePlotSpace.yRange;

    CGPoint openPoint, highPoint, lowPoint, closePoint;

    CGFloat lastViewX   = CPTFloat(0.0);
    CGFloat lastViewMin = CPTFloat(0.0);
    CGFloat lastViewMax = CPTFloat(0.0);

    NSUInteger result              = NSNotFound;
    CGFloat minimumDistanceSquared = NAN;

    if ( self.doublePrecisionCache ) {
        const double *locationBytes = (const double *)locations.data.bytes;
        const double *openBytes     = (const double *)opens.data.bytes;
        const double *highBytes     = (const double *)highs.data.bytes;
        const double *lowBytes      = (const double *)lows.data.bytes;
        const double *closeBytes    = (const double *)closes.data.bytes;

        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            double plotPoint[2];

            plotPoint[independentCoord] = *locationBytes++;
            if ( isnan(plotPoint[independentCoord]) || ![xRange containsDouble:plotPoint[independentCoord]] ) {
                openBytes++;
                highBytes++;
                lowBytes++;
                closeBytes++;
                continue;
            }

            // open point
            plotPoint[dependentCoord] = *openBytes++;
            if ( !isnan(plotPoint[dependentCoord]) && [yRange containsDouble:plotPoint[dependentCoord]] ) {
                openPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, openPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                openPoint = CPTPointMake(NAN, NAN);
            }

            // high point
            plotPoint[dependentCoord] = *highBytes++;
            if ( !isnan(plotPoint[dependentCoord]) && [yRange containsDouble:plotPoint[dependentCoord]] ) {
                highPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, highPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                highPoint = CPTPointMake(NAN, NAN);
            }

            // low point
            plotPoint[dependentCoord] = *lowBytes++;
            if ( !isnan(plotPoint[dependentCoord]) && [yRange containsDouble:plotPoint[dependentCoord]] ) {
                lowPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, lowPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                lowPoint = CPTPointMake(NAN, NAN);
            }

            // close point
            plotPoint[dependentCoord] = *closeBytes++;
            if ( !isnan(plotPoint[dependentCoord]) && [yRange containsDouble:plotPoint[dependentCoord]] ) {
                closePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, closePoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                closePoint = CPTPointMake(NAN, NAN);
            }

            if ( result == i ) {
                lastViewX = openPoint.x;
                if ( isnan(lastViewX) ) {
                    lastViewX = highPoint.x;
                }
                else if ( isnan(lastViewX) ) {
                    lastViewX = lowPoint.x;
                }
                else if ( isnan(lastViewX) ) {
                    lastViewX = closePoint.x;
                }

                lastViewMin = MIN( MIN(openPoint.y, closePoint.y), MIN(highPoint.y, lowPoint.y) );
                lastViewMax = MAX( MAX(openPoint.y, closePoint.y), MAX(highPoint.y, lowPoint.y) );
            }
        }
    }
    else {
        const NSDecimal *locationBytes = (const NSDecimal *)locations.data.bytes;
        const NSDecimal *openBytes     = (const NSDecimal *)opens.data.bytes;
        const NSDecimal *highBytes     = (const NSDecimal *)highs.data.bytes;
        const NSDecimal *lowBytes      = (const NSDecimal *)lows.data.bytes;
        const NSDecimal *closeBytes    = (const NSDecimal *)closes.data.bytes;

        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            NSDecimal plotPoint[2];
            plotPoint[dependentCoord] = CPTDecimalNaN();

            plotPoint[independentCoord] = *locationBytes++;
            if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) || ![xRange contains:plotPoint[independentCoord]] ) {
                openBytes++;
                highBytes++;
                lowBytes++;
                closeBytes++;
                continue;
            }

            // open point
            plotPoint[dependentCoord] = *openBytes++;
            if ( !NSDecimalIsNotANumber(&plotPoint[dependentCoord]) && [yRange contains:plotPoint[dependentCoord]] ) {
                openPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, openPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                openPoint = CPTPointMake(NAN, NAN);
            }

            // high point
            plotPoint[dependentCoord] = *highBytes++;
            if ( !NSDecimalIsNotANumber(&plotPoint[dependentCoord]) && [yRange contains:plotPoint[dependentCoord]] ) {
                highPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, highPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                highPoint = CPTPointMake(NAN, NAN);
            }

            // low point
            plotPoint[dependentCoord] = *lowBytes++;
            if ( !NSDecimalIsNotANumber(&plotPoint[dependentCoord]) && [yRange contains:plotPoint[dependentCoord]] ) {
                lowPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, lowPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                lowPoint = CPTPointMake(NAN, NAN);
            }

            // close point
            plotPoint[dependentCoord] = *closeBytes++;
            if ( !NSDecimalIsNotANumber(&plotPoint[dependentCoord]) && [yRange contains:plotPoint[dependentCoord]] ) {
                closePoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, closePoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = i;
                }
            }
            else {
                closePoint = CPTPointMake(NAN, NAN);
            }

            if ( result == i ) {
                lastViewX = openPoint.x;
                if ( isnan(lastViewX) ) {
                    lastViewX = highPoint.x;
                }
                else if ( isnan(lastViewX) ) {
                    lastViewX = lowPoint.x;
                }
                else if ( isnan(lastViewX) ) {
                    lastViewX = closePoint.x;
                }

                lastViewMin = MIN( MIN(openPoint.y, closePoint.y), MIN(highPoint.y, lowPoint.y) );
                lastViewMax = MAX( MAX(openPoint.y, closePoint.y), MAX(highPoint.y, lowPoint.y) );
            }
        }
    }

    if ( result != NSNotFound ) {
        CGFloat offset = CPTFloat(0.0);

        switch ( self.plotStyle ) {
            case CPTTradingRangePlotStyleOHLC:
                offset = self.stickLength;
                break;

            case CPTTradingRangePlotStyleCandleStick:
                offset = self.barWidth * CPTFloat(0.5);
                break;
        }

        if ( ( point.x < (lastViewX - offset) ) || ( point.x > (lastViewX + offset) ) ) {
            result = NSNotFound;
        }
        if ( (point.y < lastViewMin) || (point.y > lastViewMax) ) {
            result = NSNotFound;
        }
    }

    return result;
}

/// @endcond

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly started touching the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barTouchDownAtRecordIndex: -tradingRangePlot:barTouchDownAtRecordIndex: @endlink or
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barTouchDownAtRecordIndex:withEvent: -tradingRangePlot:barTouchDownAtRecordIndex:withEvent: @endlink
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

    id<CPTTradingRangePlotDelegate> theDelegate = self.delegate;
    if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchDownAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchDownAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];
        self.pointingDeviceDownIndex = idx;

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchDownAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate tradingRangePlot:self barTouchDownAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchDownAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate tradingRangePlot:self barTouchDownAtRecordIndex:idx withEvent:event];
            }

            if ( handled ) {
                return YES;
            }
        }
    }

    return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly ended touching the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barTouchUpAtRecordIndex: -tradingRangePlot:barTouchUpAtRecordIndex: @endlink and/or
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barTouchUpAtRecordIndex:withEvent: -tradingRangePlot:barTouchUpAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each bar in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  If the bar being released is the same as the one that was pressed (see
 *  @link CPTTradingRangePlot::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barWasSelectedAtRecordIndex: -tradingRangePlot:barWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTTradingRangePlotDelegate::tradingRangePlot:barWasSelectedAtRecordIndex:withEvent: -tradingRangePlot:barWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, these will be called.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    NSUInteger selectedDownIndex = self.pointingDeviceDownIndex;

    self.pointingDeviceDownIndex = NSNotFound;

    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTTradingRangePlotDelegate> theDelegate = self.delegate;
    if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchUpAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchUpAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchUpAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate tradingRangePlot:self barTouchUpAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barTouchUpAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate tradingRangePlot:self barTouchUpAtRecordIndex:idx withEvent:event];
            }

            if ( idx == selectedDownIndex ) {
                if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:)] ) {
                    handled = YES;
                    [theDelegate tradingRangePlot:self barWasSelectedAtRecordIndex:idx];
                }

                if ( [theDelegate respondsToSelector:@selector(tradingRangePlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
                    handled = YES;
                    [theDelegate tradingRangePlot:self barWasSelectedAtRecordIndex:idx withEvent:event];
                }
            }

            if ( handled ) {
                return YES;
            }
        }
    }

    return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setPlotStyle:(CPTTradingRangePlotStyle)newPlotStyle
{
    if ( plotStyle != newPlotStyle ) {
        plotStyle = newPlotStyle;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setLineStyle:(CPTLineStyle *)newLineStyle
{
    if ( lineStyle != newLineStyle ) {
        lineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setIncreaseLineStyle:(CPTLineStyle *)newLineStyle
{
    if ( increaseLineStyle != newLineStyle ) {
        increaseLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setDecreaseLineStyle:(CPTLineStyle *)newLineStyle
{
    if ( decreaseLineStyle != newLineStyle ) {
        decreaseLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setIncreaseFill:(CPTFill *)newFill
{
    if ( increaseFill != newFill ) {
        increaseFill = [newFill copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setDecreaseFill:(CPTFill *)newFill
{
    if ( decreaseFill != newFill ) {
        decreaseFill = [newFill copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setBarWidth:(CGFloat)newWidth
{
    if ( barWidth != newWidth ) {
        barWidth = newWidth;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setStickLength:(CGFloat)newLength
{
    if ( stickLength != newLength ) {
        stickLength = newLength;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setBarCornerRadius:(CGFloat)newBarCornerRadius
{
    if ( barCornerRadius != newBarCornerRadius ) {
        barCornerRadius = newBarCornerRadius;
        [self setNeedsDisplay];
    }
}

-(void)setShowBarBorder:(BOOL)newShowBarBorder
{
    if ( showBarBorder != newShowBarBorder ) {
        showBarBorder = newShowBarBorder;
        [self setNeedsDisplay];
    }
}

-(void)setXValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTTradingRangePlotFieldX];
}

-(CPTMutableNumericData *)xValues
{
    return [self cachedNumbersForField:CPTTradingRangePlotFieldX];
}

-(CPTMutableNumericData *)openValues
{
    return [self cachedNumbersForField:CPTTradingRangePlotFieldOpen];
}

-(void)setOpenValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTTradingRangePlotFieldOpen];
}

-(CPTMutableNumericData *)highValues
{
    return [self cachedNumbersForField:CPTTradingRangePlotFieldHigh];
}

-(void)setHighValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTTradingRangePlotFieldHigh];
}

-(CPTMutableNumericData *)lowValues
{
    return [self cachedNumbersForField:CPTTradingRangePlotFieldLow];
}

-(void)setLowValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTTradingRangePlotFieldLow];
}

-(CPTMutableNumericData *)closeValues
{
    return [self cachedNumbersForField:CPTTradingRangePlotFieldClose];
}

-(void)setCloseValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTTradingRangePlotFieldClose];
}

-(NSArray *)increaseFills
{
    return [self cachedArrayForKey:CPTTradingRangePlotBindingIncreaseFills];
}

-(void)setIncreaseFills:(NSArray *)newFills
{
    [self cacheArray:newFills forKey:CPTTradingRangePlotBindingIncreaseFills];
    [self setNeedsDisplay];
}

-(NSArray *)decreaseFills
{
    return [self cachedArrayForKey:CPTTradingRangePlotBindingDecreaseFills];
}

-(void)setDecreaseFills:(NSArray *)newFills
{
    [self cacheArray:newFills forKey:CPTTradingRangePlotBindingDecreaseFills];
    [self setNeedsDisplay];
}

-(NSArray *)lineStyles
{
    return [self cachedArrayForKey:CPTTradingRangePlotBindingLineStyles];
}

-(void)setLineStyles:(NSArray *)newLineStyles
{
    [self cacheArray:newLineStyles forKey:CPTTradingRangePlotBindingLineStyles];
    [self setNeedsDisplay];
}

-(NSArray *)increaseLineStyles
{
    return [self cachedArrayForKey:CPTTradingRangePlotBindingIncreaseLineStyles];
}

-(void)setIncreaseLineStyles:(NSArray *)newLineStyles
{
    [self cacheArray:newLineStyles forKey:CPTTradingRangePlotBindingIncreaseLineStyles];
    [self setNeedsDisplay];
}

-(NSArray *)decreaseLineStyles
{
    return [self cachedArrayForKey:CPTTradingRangePlotBindingDecreaseLineStyles];
}

-(void)setDecreaseLineStyles:(NSArray *)newLineStyles
{
    [self cacheArray:newLineStyles forKey:CPTTradingRangePlotBindingDecreaseLineStyles];
    [self setNeedsDisplay];
}

/// @endcond

@end
