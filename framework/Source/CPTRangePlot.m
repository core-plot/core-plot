#import "CPTRangePlot.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

/** @defgroup plotAnimationRangePlot Range Plot
 *  @brief Range plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsRangePlot Range Plot Bindings
 *  @brief Binding identifiers for range plots.
 *  @ingroup plotBindings
 *  @endif
 **/

NSString *const CPTRangePlotBindingXValues       = @"xValues";       ///< X values.
NSString *const CPTRangePlotBindingYValues       = @"yValues";       ///< Y values.
NSString *const CPTRangePlotBindingHighValues    = @"highValues";    ///< High values.
NSString *const CPTRangePlotBindingLowValues     = @"lowValues";     ///< Low values.
NSString *const CPTRangePlotBindingLeftValues    = @"leftValues";    ///< Left price values.
NSString *const CPTRangePlotBindingRightValues   = @"rightValues";   ///< Right price values.
NSString *const CPTRangePlotBindingBarLineStyles = @"barLineStyles"; ///< Bar line styles.

/// @cond
struct CGPointError {
    CGFloat x;
    CGFloat y;
    CGFloat high;
    CGFloat low;
    CGFloat left;
    CGFloat right;
};
typedef struct CGPointError CGPointError;

@interface CPTRangePlot()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *leftValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *rightValues;
@property (nonatomic, readwrite, copy) NSArray *barLineStyles;

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount;
-(void)alignViewPointsToUserSpace:(CGPointError *)viewPoints withContent:(CGContextRef)context drawPointFlags:(BOOL *)drawPointFlag numberOfPoints:(NSUInteger)dataCounts;
-(NSInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound;

-(void)drawRangeInContext:(CGContextRef)context lineStyle:(CPTLineStyle *)lineStyle viewPoint:(CGPointError *)viewPoint halfGapSize:(CGSize)halfGapSize halfBarWidth:(CGFloat)halfBarWidth alignPoints:(BOOL)alignPoints;
-(CPTLineStyle *)barLineStyleForIndex:(NSUInteger)idx;

@end

/// @endcond

#pragma mark -

/** @brief A plot class representing a range of values in one coordinate,
 *  such as typically used to show errors.
 *  A range plot can show bars (error bars), or an area fill, or both.
 *  @see See @ref plotAnimationRangePlot "Range Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsRangePlot "Range Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTRangePlot

@dynamic xValues;
@dynamic yValues;
@dynamic highValues;
@dynamic lowValues;
@dynamic leftValues;
@dynamic rightValues;
@dynamic barLineStyles;

/** @property CPTFill *areaFill
 *  @brief The fill used to render the area.
 *  Set to @nil to have no fill. Default is @nil.
 **/
@synthesize areaFill;

/** @property CPTLineStyle *barLineStyle
 *  @brief The line style of the range bars.
 *  Set to @nil to have no bars. Default is a black line style.
 **/
@synthesize barLineStyle;

/** @property CGFloat barWidth
 *  @brief Width of the lateral sections of the bars.
 *  @ingroup plotAnimationRangePlot
 **/
@synthesize barWidth;

/** @property CGFloat gapHeight
 *  @brief Height of the central gap.
 *  Set to zero to have no gap.
 *  @ingroup plotAnimationRangePlot
 **/
@synthesize gapHeight;

/** @property CGFloat gapWidth
 *  @brief Width of the central gap.
 *  Set to zero to have no gap.
 *  @ingroup plotAnimationRangePlot
 **/
@synthesize gapWidth;

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTRangePlot class] ) {
        [self exposeBinding:CPTRangePlotBindingXValues];
        [self exposeBinding:CPTRangePlotBindingYValues];
        [self exposeBinding:CPTRangePlotBindingHighValues];
        [self exposeBinding:CPTRangePlotBindingLowValues];
        [self exposeBinding:CPTRangePlotBindingLeftValues];
        [self exposeBinding:CPTRangePlotBindingRightValues];
        [self exposeBinding:CPTRangePlotBindingBarLineStyles];
    }
}

#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTRangePlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref barLineStyle = default line style
 *  - @ref areaFill = @nil
 *  - @ref labelField = #CPTRangePlotFieldX
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTRangePlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        barLineStyle = [[CPTLineStyle alloc] init];
        areaFill     = nil;

        self.labelField = CPTRangePlotFieldX;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTRangePlot *theLayer = (CPTRangePlot *)layer;
        barLineStyle = [theLayer->barLineStyle retain];
        areaFill     = nil;
    }
    return self;
}

-(void)dealloc
{
    [barLineStyle release];
    [areaFill release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.barLineStyle forKey:@"CPTRangePlot.barLineStyle"];
    [coder encodeCGFloat:self.barWidth forKey:@"CPTRangePlot.barWidth"];
    [coder encodeCGFloat:self.gapHeight forKey:@"CPTRangePlot.gapHeight"];
    [coder encodeCGFloat:self.gapWidth forKey:@"CPTRangePlot.gapWidth"];
    [coder encodeObject:self.areaFill forKey:@"CPTRangePlot.areaFill"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        barLineStyle = [[coder decodeObjectForKey:@"CPTRangePlot.barLineStyle"] copy];
        barWidth     = [coder decodeCGFloatForKey:@"CPTRangePlot.barWidth"];
        gapHeight    = [coder decodeCGFloatForKey:@"CPTRangePlot.gapHeight"];
        gapWidth     = [coder decodeCGFloatForKey:@"CPTRangePlot.gapWidth"];
        areaFill     = [[coder decodeObjectForKey:@"CPTRangePlot.areaFill"] copy];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Determining Which Points to Draw

/// @cond

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{
    if ( dataCount == 0 ) {
        return;
    }

    CPTPlotRangeComparisonResult *xRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
    CPTPlotRangeComparisonResult *yRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
    BOOL *nanFlags                            = malloc( dataCount * sizeof(BOOL) );

    CPTPlotRange *xRange = xyPlotSpace.xRange;
    CPTPlotRange *yRange = xyPlotSpace.yRange;

    // Determine where each point lies in relation to range
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            const double x = *xBytes++;
            const double y = *yBytes++;
            xRangeFlags[i] = [xRange compareToDouble:x];
            yRangeFlags[i] = [yRange compareToDouble:y];
            nanFlags[i]    = isnan(x) || isnan(y);
        }
    }
    else {
        // Determine where each point lies in relation to range
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;

        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            const NSDecimal *x = xBytes++;
            const NSDecimal *y = yBytes++;

            xRangeFlags[i] = [xRange compareToDecimal:*x];
            yRangeFlags[i] = [yRange compareToDecimal:*y];
            nanFlags[i]    = NSDecimalIsNotANumber(x); // || NSDecimalIsNotANumber(high) || NSDecimalIsNotANumber(low);
        }
    }

    // Ensure that whenever the path crosses over a region boundary, both points
    // are included. This ensures no lines are left out that shouldn't be.
    pointDrawFlags[0] = (xRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
                         yRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
                         !nanFlags[0]);
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        pointDrawFlags[i] = NO;
        if ( !visibleOnly && !nanFlags[i - 1] && !nanFlags[i] && ( (xRangeFlags[i - 1] != xRangeFlags[i]) || (xRangeFlags[i - 1] != xRangeFlags[i]) ) ) {
            pointDrawFlags[i - 1] = YES;
            pointDrawFlags[i]     = YES;
        }
        else if ( (xRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                  (yRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                  !nanFlags[i] ) {
            pointDrawFlags[i] = YES;
        }
    }

    free(xRangeFlags);
    free(yRangeFlags);
    free(nanFlags);
}

-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    CPTPlotArea *thePlotArea   = self.plotArea;
    CPTPlotSpace *thePlotSpace = self.plotSpace;
    CGPoint originTransformed  = [self convertPoint:self.frame.origin fromLayer:thePlotArea];

    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes     = (const double *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const double *yBytes     = (const double *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
        const double *highBytes  = (const double *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
        const double *lowBytes   = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
        const double *leftBytes  = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
        const double *rightBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            const double x     = *xBytes++;
            const double y     = *yBytes++;
            const double high  = *highBytes++;
            const double low   = *lowBytes++;
            const double left  = *leftBytes++;
            const double right = *rightBytes++;
            if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
                viewPoints[i].x = NAN; // depending coordinates
                viewPoints[i].y = NAN;
            }
            else {
                double plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
                viewPoints[i].x           = pos.x + originTransformed.x;
                viewPoints[i].y           = pos.y + originTransformed.y;
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y + high;
                pos                       = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
                viewPoints[i].high        = pos.y + originTransformed.y;
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y - low;
                pos                       = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
                viewPoints[i].low         = pos.y + originTransformed.y;
                plotPoint[CPTCoordinateX] = x - left;
                plotPoint[CPTCoordinateY] = y;
                pos                       = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
                viewPoints[i].left        = pos.x + originTransformed.x;
                plotPoint[CPTCoordinateX] = x + right;
                plotPoint[CPTCoordinateY] = y;
                pos                       = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
                viewPoints[i].right       = pos.x + originTransformed.x;
            }
        }
    }
    else {
        const NSDecimal *xBytes     = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const NSDecimal *yBytes     = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
        const NSDecimal *highBytes  = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
        const NSDecimal *lowBytes   = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
        const NSDecimal *leftBytes  = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
        const NSDecimal *rightBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            const NSDecimal x     = *xBytes++;
            const NSDecimal y     = *yBytes++;
            const NSDecimal high  = *highBytes++;
            const NSDecimal low   = *lowBytes++;
            const NSDecimal left  = *leftBytes++;
            const NSDecimal right = *rightBytes++;

            if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
                viewPoints[i].x = NAN; // depending coordinates
                viewPoints[i].y = NAN;
            }
            else {
                NSDecimal plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
                viewPoints[i].x = pos.x + originTransformed.x;
                viewPoints[i].y = pos.y + originTransformed.y;

                if ( !NSDecimalIsNotANumber(&high) ) {
                    plotPoint[CPTCoordinateX] = x;
                    NSDecimal yh;
                    NSDecimalAdd(&yh, &y, &high, NSRoundPlain);
                    plotPoint[CPTCoordinateY] = yh;
                    pos                       = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
                    viewPoints[i].high        = pos.y + originTransformed.y;
                }
                else {
                    viewPoints[i].high = NAN;
                }

                if ( !NSDecimalIsNotANumber(&low) ) {
                    plotPoint[CPTCoordinateX] = x;
                    NSDecimal yl;
                    NSDecimalSubtract(&yl, &y, &low, NSRoundPlain);
                    plotPoint[CPTCoordinateY] = yl;
                    pos                       = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
                    viewPoints[i].low         = pos.y + originTransformed.y;
                }
                else {
                    viewPoints[i].low = NAN;
                }

                if ( !NSDecimalIsNotANumber(&left) ) {
                    NSDecimal xl;
                    NSDecimalSubtract(&xl, &x, &left, NSRoundPlain);
                    plotPoint[CPTCoordinateX] = xl;
                    plotPoint[CPTCoordinateY] = y;
                    pos                       = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
                    viewPoints[i].left        = pos.x + originTransformed.x;
                }
                else {
                    viewPoints[i].left = NAN;
                }
                if ( !NSDecimalIsNotANumber(&right) ) {
                    NSDecimal xr;
                    NSDecimalAdd(&xr, &x, &right, NSRoundPlain);
                    plotPoint[CPTCoordinateX] = xr;
                    plotPoint[CPTCoordinateY] = y;
                    pos                       = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
                    viewPoints[i].right       = pos.x + originTransformed.y;
                }
                else {
                    viewPoints[i].right = NAN;
                }
            }
        }
    }
}

-(void)alignViewPointsToUserSpace:(CGPointError *)viewPoints withContent:(CGContextRef)context drawPointFlags:(BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    // Align to device pixels if there is a data line.
    // Otherwise, align to view space, so fills are sharp at edges.
    if ( self.barLineStyle.lineWidth > 0.0 ) {
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            if ( drawPointFlags[i] ) {
                CGFloat x   = viewPoints[i].x;
                CGFloat y   = viewPoints[i].y;
                CGPoint pos = CPTAlignPointToUserSpace( context, CPTPointMake(viewPoints[i].x, viewPoints[i].y) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;

                pos                 = CPTAlignPointToUserSpace( context, CPTPointMake(x, viewPoints[i].high) );
                viewPoints[i].high  = pos.y;
                pos                 = CPTAlignPointToUserSpace( context, CPTPointMake(x, viewPoints[i].low) );
                viewPoints[i].low   = pos.y;
                pos                 = CPTAlignPointToUserSpace( context, CPTPointMake(viewPoints[i].left, y) );
                viewPoints[i].left  = pos.x;
                pos                 = CPTAlignPointToUserSpace( context, CPTPointMake(viewPoints[i].right, y) );
                viewPoints[i].right = pos.x;
            }
        }
    }
    else {
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            if ( drawPointFlags[i] ) {
                CGFloat x   = viewPoints[i].x;
                CGFloat y   = viewPoints[i].y;
                CGPoint pos = CPTAlignIntegralPointToUserSpace( context, CPTPointMake(viewPoints[i].x, viewPoints[i].y) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;

                pos                 = CPTAlignIntegralPointToUserSpace( context, CPTPointMake(x, viewPoints[i].high) );
                viewPoints[i].high  = pos.y;
                pos                 = CPTAlignIntegralPointToUserSpace( context, CPTPointMake(x, viewPoints[i].low) );
                viewPoints[i].low   = pos.y;
                pos                 = CPTAlignIntegralPointToUserSpace( context, CPTPointMake(viewPoints[i].left, y) );
                viewPoints[i].left  = pos.x;
                pos                 = CPTAlignIntegralPointToUserSpace( context, CPTPointMake(viewPoints[i].right, y) );
                viewPoints[i].right = pos.x;
            }
        }
    }
}

-(NSInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound
{
    NSInteger result = NSNotFound;
    NSInteger delta  = (isLowerBound ? 1 : -1);

    if ( dataCount > 0 ) {
        NSUInteger initialIndex = (isLowerBound ? 0 : dataCount - 1);
        for ( NSInteger i = (NSInteger)initialIndex; i < (NSInteger)dataCount; i += delta ) {
            if ( pointDrawFlags[i] ) {
                result = i;
                break;
            }
            if ( (delta < 0) && (i == 0) ) {
                break;
            }
        }
    }
    return result;
}

/// @endcond

#pragma mark -
#pragma mark Data Loading

/// @cond

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
    [super reloadDataInIndexRange:indexRange];

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:indexRange] ) {
        id<CPTRangePlotDataSource> theDataSource = (id<CPTRangePlotDataSource>)self.dataSource;

        if ( theDataSource ) {
            id newXValues = [self numbersFromDataSourceForField:CPTRangePlotFieldX recordIndexRange:indexRange];
            [self cacheNumbers:newXValues forField:CPTRangePlotFieldX atRecordIndex:indexRange.location];
            id newYValues = [self numbersFromDataSourceForField:CPTRangePlotFieldY recordIndexRange:indexRange];
            [self cacheNumbers:newYValues forField:CPTRangePlotFieldY atRecordIndex:indexRange.location];
            id newHighValues = [self numbersFromDataSourceForField:CPTRangePlotFieldHigh recordIndexRange:indexRange];
            [self cacheNumbers:newHighValues forField:CPTRangePlotFieldHigh atRecordIndex:indexRange.location];
            id newLowValues = [self numbersFromDataSourceForField:CPTRangePlotFieldLow recordIndexRange:indexRange];
            [self cacheNumbers:newLowValues forField:CPTRangePlotFieldLow atRecordIndex:indexRange.location];
            id newLeftValues = [self numbersFromDataSourceForField:CPTRangePlotFieldLeft recordIndexRange:indexRange];
            [self cacheNumbers:newLeftValues forField:CPTRangePlotFieldLeft atRecordIndex:indexRange.location];
            id newRightValues = [self numbersFromDataSourceForField:CPTRangePlotFieldRight recordIndexRange:indexRange];
            [self cacheNumbers:newRightValues forField:CPTRangePlotFieldRight atRecordIndex:indexRange.location];

            // Bar line styles
            if ( [theDataSource respondsToSelector:@selector(barLineStylesForRangePlot:recordIndexRange:)] ) {
                [self cacheArray:[theDataSource barLineStylesForRangePlot:self recordIndexRange:indexRange] forKey:CPTRangePlotBindingBarLineStyles atRecordIndex:indexRange.location];
            }
            else if ( [theDataSource respondsToSelector:@selector(barLineStyleForRangePlot:recordIndex:)] ) {
                id nilObject          = [CPTPlot nilData];
                NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
                NSUInteger maxIndex   = NSMaxRange(indexRange);

                for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
                    CPTLineStyle *dataSourceLineStyle = [theDataSource barLineStyleForRangePlot:self recordIndex:idx];
                    if ( dataSourceLineStyle ) {
                        [array addObject:dataSourceLineStyle];
                    }
                    else {
                        [array addObject:nilObject];
                    }
                }

                [self cacheArray:array forKey:CPTRangePlotBindingBarLineStyles atRecordIndex:indexRange.location];
                [array release];
            }
        }
        else {
            self.xValues     = nil;
            self.yValues     = nil;
            self.highValues  = nil;
            self.lowValues   = nil;
            self.leftValues  = nil;
            self.rightValues = nil;
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTRangePlotFieldX];
    CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTRangePlotFieldY];

    if ( (xValueData == nil) || (yValueData == nil) ) {
        return;
    }
    NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) {
        return;
    }
    if ( xValueData.numberOfSamples != yValueData.numberOfSamples ) {
        [NSException raise:CPTException format:@"Number of x and y values do not match"];
    }

    [super renderAsVectorInContext:context];

    // Calculate view points, and align to user space
    CGPointError *viewPoints = calloc( dataCount, sizeof(CGPointError) );
    BOOL *drawPointFlags     = calloc( dataCount, sizeof(BOOL) );

    CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];
    if ( self.alignsPointsToPixels ) {
        [self alignViewPointsToUserSpace:viewPoints withContent:context drawPointFlags:drawPointFlags numberOfPoints:dataCount];
    }

    // Get extreme points
    NSInteger lastDrawnPointIndex  = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:NO];
    NSInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];

    if ( firstDrawnPointIndex != NSNotFound ) {
        if ( self.areaFill ) {
            CGMutablePathRef fillPath = CGPathCreateMutable();

            // First do the top points
            for ( NSUInteger i = (NSUInteger)firstDrawnPointIndex; i <= (NSUInteger)lastDrawnPointIndex; i++ ) {
                CGFloat x = viewPoints[i].x;
                CGFloat y = viewPoints[i].high;
                if ( isnan(y) ) {
                    y = viewPoints[i].y;
                }

                if ( !isnan(x) && !isnan(y) ) {
                    if ( i == (NSUInteger)firstDrawnPointIndex ) {
                        CGPathMoveToPoint(fillPath, NULL, x, y);
                    }
                    else {
                        CGPathAddLineToPoint(fillPath, NULL, x, y);
                    }
                }
            }

            // Then reverse over bottom points
            for ( NSUInteger j = (NSUInteger)lastDrawnPointIndex; j >= (NSUInteger)firstDrawnPointIndex; j-- ) {
                CGFloat x = viewPoints[j].x;
                CGFloat y = viewPoints[j].low;
                if ( isnan(y) ) {
                    y = viewPoints[j].y;
                }

                if ( !isnan(x) && !isnan(y) ) {
                    CGPathAddLineToPoint(fillPath, NULL, x, y);
                }
                if ( j == (NSUInteger)firstDrawnPointIndex ) {
                    // This could be done a bit more elegant
                    break;
                }
            }

            CGContextBeginPath(context);
            CGContextAddPath(context, fillPath);

            // Close the path to have a closed loop
            CGPathCloseSubpath(fillPath);

            CGContextSaveGState(context);

            // Pick the current line style with a low alpha component
            [self.areaFill fillPathInContext:context];

            CGPathRelease(fillPath);
        }

        CGSize halfGapSize   = CPTSizeMake( self.gapWidth * CPTFloat(0.5), self.gapHeight * CPTFloat(0.5) );
        CGFloat halfBarWidth = self.barWidth * CPTFloat(0.5);
        BOOL alignPoints     = self.alignsPointsToPixels;

        for ( NSUInteger i = (NSUInteger)firstDrawnPointIndex; i <= (NSUInteger)lastDrawnPointIndex; i++ ) {
            [self drawRangeInContext:context
                           lineStyle:[self barLineStyleForIndex:i]
                           viewPoint:&viewPoints[i]
                         halfGapSize:halfGapSize
                        halfBarWidth:halfBarWidth
                         alignPoints:alignPoints];
        }
    }

    free(viewPoints);
    free(drawPointFlags);
}

-(void)drawRangeInContext:(CGContextRef)context
                lineStyle:(CPTLineStyle *)lineStyle
                viewPoint:(CGPointError *)viewPoint
              halfGapSize:(CGSize)halfGapSize
             halfBarWidth:(CGFloat)halfBarWidth
              alignPoints:(BOOL)alignPoints
{
    if ( [lineStyle isKindOfClass:[CPTLineStyle class]] && !isnan(viewPoint->x) && !isnan(viewPoint->y) ) {
        CGMutablePathRef path = CGPathCreateMutable();

        // centre-high
        if ( !isnan(viewPoint->high) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x, viewPoint->y + halfGapSize.height);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->x, viewPoint->high);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // centre-low
        if ( !isnan(viewPoint->low) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x, viewPoint->y - halfGapSize.height);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->x, viewPoint->low);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // top bar
        if ( !isnan(viewPoint->high) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x - halfBarWidth, viewPoint->high);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->x + halfBarWidth, viewPoint->high);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // bottom bar
        if ( !isnan(viewPoint->low) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x - halfBarWidth, viewPoint->low);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->x + halfBarWidth, viewPoint->low);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // centre-left
        if ( !isnan(viewPoint->left) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x - halfGapSize.width, viewPoint->y);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->left, viewPoint->y);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // centre-right
        if ( !isnan(viewPoint->right) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->x + halfGapSize.width, viewPoint->y);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->right, viewPoint->y);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // left bar
        if ( !isnan(viewPoint->left) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->left, viewPoint->y - halfBarWidth);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->left, viewPoint->y + halfBarWidth);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        // right bar
        if ( !isnan(viewPoint->right) ) {
            CGPoint alignedHighPoint = CPTPointMake(viewPoint->right, viewPoint->y - halfBarWidth);
            CGPoint alignedLowPoint  = CPTPointMake(viewPoint->right, viewPoint->y + halfBarWidth);
            if ( alignPoints ) {
                alignedHighPoint = CPTAlignPointToUserSpace(context, alignedHighPoint);
                alignedLowPoint  = CPTAlignPointToUserSpace(context, alignedLowPoint);
            }
            CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
            CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
        }

        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
        CGPathRelease(path);
    }
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(CGContextRef)context
{
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    CPTFill *theFill = self.areaFill;

    if ( theFill ) {
        CGPathRef swatchPath;
        CGFloat radius = legend.swatchCornerRadius;
        if ( radius > 0.0 ) {
            radius     = MIN( MIN( radius, rect.size.width / CPTFloat(2.0) ), rect.size.height / CPTFloat(2.0) );
            swatchPath = CreateRoundedRectPath(rect, radius);
        }
        else {
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            CGPathAddRect(mutablePath, NULL, rect);
            swatchPath = mutablePath;
        }

        CGContextBeginPath(context);
        CGContextAddPath(context, swatchPath);
        [theFill fillPathInContext:context];

        CGPathRelease(swatchPath);
    }

    CPTLineStyle *theBarLineStyle = [self barLineStyleForIndex:idx];

    if ( [theBarLineStyle isKindOfClass:[CPTLineStyle class]] ) {
        CGPointError viewPoint;
        viewPoint.x     = CGRectGetMidX(rect);
        viewPoint.y     = CGRectGetMidY(rect);
        viewPoint.high  = CGRectGetMaxY(rect);
        viewPoint.low   = CGRectGetMinY(rect);
        viewPoint.left  = CGRectGetMinX(rect);
        viewPoint.right = CGRectGetMaxX(rect);

        [self drawRangeInContext:context
                       lineStyle:theBarLineStyle
                       viewPoint:&viewPoint
                     halfGapSize:CPTSizeMake( MIN( self.gapWidth, rect.size.width / CPTFloat(2.0) ) * CPTFloat(0.5), MIN( self.gapHeight, rect.size.height / CPTFloat(2.0) ) * CPTFloat(0.5) )
                    halfBarWidth:MIN(MIN(self.barWidth, rect.size.width), rect.size.height) * CPTFloat(0.5)
                     alignPoints:YES];
    }
}

-(CPTLineStyle *)barLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theBarLineStyle = [self cachedValueForKey:CPTRangePlotBindingBarLineStyles recordIndex:idx];

    if ( (theBarLineStyle == nil) || (theBarLineStyle == [CPTPlot nilData]) ) {
        theBarLineStyle = self.barLineStyle;
    }

    return theBarLineStyle;
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
                @"barWidth",
                @"gapHeight",
                @"gapWidth",
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
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
    return 6;
}

-(NSArray *)fieldIdentifiers
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldX],
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldY],
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldHigh],
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldLow],
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldLeft],
            [NSNumber numberWithUnsignedInt:CPTRangePlotFieldRight],
            nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
    NSArray *result = nil;

    switch ( coord ) {
        case CPTCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTRangePlotFieldX]];
            break;

        case CPTCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTRangePlotFieldY]];
            break;

        default:
            [NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

/// @endcond

#pragma mark -
#pragma mark Data Labels

/// @cond

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
{
    NSNumber *xValue = [self cachedNumberForField:CPTRangePlotFieldX recordIndex:idx];

    BOOL positiveDirection = YES;
    CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

    if ( CPTDecimalLessThan( yRange.length, CPTDecimalFromInteger(0) ) ) {
        positiveDirection = !positiveDirection;
    }

    NSNumber *yValue;
    NSArray *yValues       = [NSArray arrayWithObject:[self cachedNumberForField:CPTRangePlotFieldY recordIndex:idx]];
    NSArray *yValuesSorted = [yValues sortedArrayUsingSelector:@selector(compare:)];
    if ( positiveDirection ) {
        yValue = [yValuesSorted lastObject];
    }
    else {
        yValue = [yValuesSorted objectAtIndex:0];
    }

    label.anchorPlotPoint     = [NSArray arrayWithObjects:xValue, yValue, nil];
    label.contentLayer.hidden = self.hidden || isnan([xValue doubleValue]) || isnan([yValue doubleValue]);

    if ( positiveDirection ) {
        label.displacement = CPTPointMake(0.0, self.labelOffset);
    }
    else {
        label.displacement = CPTPointMake(0.0, -self.labelOffset);
    }
}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User Interaction

/// @cond

-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
{
    NSUInteger dataCount     = self.cachedDataCount;
    CGPointError *viewPoints = calloc( dataCount, sizeof(CGPointError) );
    BOOL *drawPointFlags     = malloc( dataCount * sizeof(BOOL) );

    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    NSInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];
    if ( result != NSNotFound ) {
        CGPointError lastViewPoint;
        CGFloat minimumDistanceSquared = NAN;
        for ( NSUInteger i = (NSUInteger)result; i < dataCount; ++i ) {
            if ( drawPointFlags[i] ) {
                lastViewPoint = viewPoints[i];
                CGPoint lastPoint       = CPTPointMake(lastViewPoint.x, lastViewPoint.y);
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, lastPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = (NSInteger)i;
                }
            }
        }
        if ( result != NSNotFound ) {
            lastViewPoint = viewPoints[result];

            if ( !isnan(lastViewPoint.left) && (point.x < lastViewPoint.left) ) {
                result = NSNotFound;
            }
            if ( !isnan(lastViewPoint.right) && (point.x > lastViewPoint.right) ) {
                result = NSNotFound;
            }
            if ( !isnan(lastViewPoint.high) && (point.y > lastViewPoint.high) ) {
                result = NSNotFound;
            }
            if ( !isnan(lastViewPoint.low) && (point.y < lastViewPoint.low) ) {
                result = NSNotFound;
            }
        }
    }

    free(viewPoints);
    free(drawPointFlags);

    return (NSUInteger)result;
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
 *  @link CPTRangePlotDelegate::rangePlot:rangeWasSelectedAtRecordIndex: -rangePlot:rangeWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTRangePlotDelegate::rangePlot:rangeWasSelectedAtRecordIndex:withEvent: -rangePlot:rangeWasSelectedAtRecordIndex:withEvent: @endlink
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

    id<CPTRangePlotDelegate> theDelegate = self.delegate;
    if ( [theDelegate respondsToSelector:@selector(rangePlot:rangeWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(rangePlot:rangeWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            if ( [theDelegate respondsToSelector:@selector(rangePlot:rangeWasSelectedAtRecordIndex:)] ) {
                [theDelegate rangePlot:self rangeWasSelectedAtRecordIndex:idx];
            }
            if ( [theDelegate respondsToSelector:@selector(rangePlot:rangeWasSelectedAtRecordIndex:withEvent:)] ) {
                [theDelegate rangePlot:self rangeWasSelectedAtRecordIndex:idx withEvent:event];
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

-(void)setBarLineStyle:(CPTLineStyle *)newLineStyle
{
    if ( barLineStyle != newLineStyle ) {
        [barLineStyle release];
        barLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setAreaFill:(CPTFill *)newFill
{
    if ( newFill != areaFill ) {
        [areaFill release];
        areaFill = [newFill copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setBarWidth:(CGFloat)newBarWidth
{
    if ( barWidth != newBarWidth ) {
        barWidth = newBarWidth;
        [self setNeedsDisplay];
    }
}

-(void)setGapHeight:(CGFloat)newGapHeight
{
    if ( gapHeight != newGapHeight ) {
        gapHeight = newGapHeight;
        [self setNeedsDisplay];
    }
}

-(void)setGapWidth:(CGFloat)newGapWidth
{
    if ( gapWidth != newGapWidth ) {
        gapWidth = newGapWidth;
        [self setNeedsDisplay];
    }
}

-(void)setXValues:(NSArray *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldX];
}

-(NSArray *)xValues
{
    return [[self cachedNumbersForField:CPTRangePlotFieldX] sampleArray];
}

-(void)setYValues:(NSArray *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldY];
}

-(NSArray *)yValues
{
    return [[self cachedNumbersForField:CPTRangePlotFieldY] sampleArray];
}

-(CPTMutableNumericData *)highValues
{
    return [self cachedNumbersForField:CPTRangePlotFieldHigh];
}

-(void)setHighValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldHigh];
}

-(CPTMutableNumericData *)lowValues
{
    return [self cachedNumbersForField:CPTRangePlotFieldLow];
}

-(void)setLowValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldLow];
}

-(CPTMutableNumericData *)leftValues
{
    return [self cachedNumbersForField:CPTRangePlotFieldLeft];
}

-(void)setLeftValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldLeft];
}

-(CPTMutableNumericData *)rightValues
{
    return [self cachedNumbersForField:CPTRangePlotFieldRight];
}

-(void)setRightValues:(CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTRangePlotFieldRight];
}

-(NSArray *)barLineStyles
{
    return [self cachedArrayForKey:CPTRangePlotBindingBarLineStyles];
}

-(void)setBarLineStyles:(NSArray *)newLineStyles
{
    [self cacheArray:newLineStyles forKey:CPTRangePlotBindingBarLineStyles];
    [self setNeedsDisplay];
}

/// @endcond

@end
