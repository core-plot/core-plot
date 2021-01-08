//
//  CPTVectorFieldPlot.m
//  CorePlot Mac
//
//  Created by Steve Wainwright on 13/12/2020.
//

#import "CPTVectorFieldPlot.h"

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
#import "CPTFieldFunctionDataSource.h"
#import "tgmath.h"

/** @defgroup plotAnimationVectorFieldPlot Vector Field Plot
 *  @brief Vector Field plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsVectorFieldPlot Vector Field Plot Bindings
 *  @brief Binding identifiers for vector field plots.
 *  @ingroup plotBindings
 *  @endif
 **/

CPTVectorFieldPlotBinding const CPTVectorFieldPlotBindingXValues       = @"xValues";       ///< X values.
CPTVectorFieldPlotBinding const CPTVectorFieldPlotBindingYValues       = @"yValues";       ///< Y values.
CPTVectorFieldPlotBinding const CPTVectorFieldPlotBindingVectorLengthValues    = @"lengthValues";    ///< Vector length values.
CPTVectorFieldPlotBinding const CPTVectorFieldPlotBindingVectorDirectionValues     = @"directionValues";     ///< Vector direction values.
CPTVectorFieldPlotBinding const CPTVectorFieldPlotBindingVectorLineStyles = @"lineStyles"; ///< Vector line styles.

/// @cond
struct CGPointVector {
    CGFloat x;
    CGFloat y;
    CGFloat tip_x;
    CGFloat tip_y;
};
typedef struct CGPointVector CGPointVector;

@interface CPTVectorFieldPlot()

@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *xValues;
@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *yValues;
@property (nonatomic, readwrite, copy, nullable) CPTMutableNumericData *lengthValues;
@property (nonatomic, readwrite, copy, nullable) CPTMutableNumericData *directionValues;
@property (nonatomic, readwrite, copy, nullable) CPTLineStyleArray *lineStyles;
@property (nonatomic, readwrite, assign) NSUInteger pointingDeviceDownIndex;
@property (nonatomic, readwrite, assign, nullable) CGPathRef cachedArrowHeadPath;

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(nonnull CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(nonnull CGPointVector *)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount;
-(void)alignViewPointsToUserSpace:(nonnull CGPointVector *)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlag numberOfPoints:(NSUInteger)dataCounts;
-(NSInteger)extremeDrawnPointIndexForFlags:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound;

-(void)drawVectorInContext:(nonnull CGContextRef)context lineStyle:(nonnull CPTLineStyle *)lineStyle viewPoint:(CGPointVector *)viewPoint alignPoints:(BOOL)alignPoints;
-(CPTLineStyle *)vectorLineStyleForIndex:(NSUInteger)idx;
-(nullable CGPathRef)newArrowHeadPath;

@end

/// @endcond

#pragma mark -

/** @brief A plot class representing a contour of values in one coordinate,
 *  such as typically used to show vector fields.
 *  @see See @ref plotAnimationVectorFieldPlot "Vector Field Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsVectorFieldPlot "Vector Field Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTVectorFieldPlot

@dynamic xValues;
@dynamic yValues;
@dynamic lengthValues;
@dynamic directionValues;
@dynamic lineStyles;

/** @property nullable id<CPTPlotDataSource> vectorLineStylesDataSource
 *  @brief The vectorLineStyles data source for the plot.
 **/
@synthesize vectorLineStylesDataSource;

/** @property CGFloat *normalisedVectorLength
 *  @brief The vector length in the vector field.
 *  Set to @Value to use the normalisedVectorLength to calculate multiplied by length vector in the lengthValues array of vector fields. Default is 1.0.
 **/
@synthesize normalisedVectorLength;

/** @property CGFloat maxVectorLength
 *  @brief The maximum calculated vector length for normalising.
 **/
@synthesize maxVectorLength;

/** @property CPTLineStyle *vectorLineStyle
 *  @brief The line style of the vector field.
 *  Set to @nil to have no vector fields. Default is a black line style.
 **/
@synthesize vectorLineStyle;

/** @property CGSize arrowSize
 *  @brief The size of the arrowhead of the vector field.
 *  Set @CGSize(0,0) to have no arrowheads, default is CGSize(5,5)
 **/
@synthesize arrowSize;

/** @property CPTVectorFieldArrowType arrowType
 *  @brief The type of the arrowhead of the vector field.
 *  Set to @CPTVectorFieldArrowTypeNone to have no arrowheads. Default is a CPTVectorFieldArrowTypeOpen.
 **/
@synthesize  arrowType;

/** @property nullable CPTFill *arrowFill
 *  @brief The fill for the interior of the arrowhead.
 *  If @nil, the symbol is not filled.
 **/
@synthesize arrowFill;

/** @property BOOL usesEvenOddClipRule
 *  @brief If @YES, the even-odd rule is used to draw the arrow, otherwise the non-zero winding number rule is used.
 *  @see <a href="http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF106">Filling a Path</a> in the Quartz 2D Programming Guide.
 **/
@synthesize  usesEvenOddClipRule;

/** @internal
 *  @property NSUInteger pointingDeviceDownIndex
 *  @brief The index that was selected on the pointing device down event.
 **/
@synthesize pointingDeviceDownIndex;

@synthesize cachedArrowHeadPath;

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTVectorFieldPlot class] ) {
        [self exposeBinding:CPTVectorFieldPlotBindingXValues];
        [self exposeBinding:CPTVectorFieldPlotBindingYValues];
        [self exposeBinding:CPTVectorFieldPlotBindingVectorLengthValues];
        [self exposeBinding:CPTVectorFieldPlotBindingVectorDirectionValues];
        [self exposeBinding:CPTVectorFieldPlotBindingVectorLineStyles];
    }
}

#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTVectorFieldPlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref vectorLineStyle = default line style
 *  - @ref labelField = #CPTVectorFieldPlotFieldX
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTVectorFieldPlot object.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        normalisedVectorLength = 1.0;
        vectorLineStyle        = [[CPTLineStyle alloc] init];
        arrowSize              = CGSizeMake(5.0, 5.0);
        arrowType               = CPTVectorFieldArrowTypeSolid;
        arrowFill = nil;
        usesEvenOddClipRule = NO;
        pointingDeviceDownIndex = NSNotFound;
        cachedArrowHeadPath = NULL;

        self.labelField = CPTVectorFieldPlotFieldX;
    }
    return self;
}

/// @}

/// @cond

-(nonnull instancetype)initWithLayer:(nonnull id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTVectorFieldPlot *theLayer = (CPTVectorFieldPlot *)layer;

        normalisedVectorLength          = theLayer->normalisedVectorLength;
        vectorLineStyle        = theLayer->vectorLineStyle;
        arrowSize      = theLayer->arrowSize;
        arrowType             = theLayer->arrowType;
        arrowFill = theLayer->arrowFill;
        usesEvenOddClipRule = theLayer->usesEvenOddClipRule;
        
        pointingDeviceDownIndex = NSNotFound;
        cachedArrowHeadPath = NULL;
    }
    return self;
}

-(void)dealloc
{
    CGPathRelease(cachedArrowHeadPath);
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeCGFloat:self.normalisedVectorLength forKey:@"CPTVectorFieldPlot.normalisedVectorLength"];
    [coder encodeObject:self.vectorLineStyle forKey:@"CPTVectorFieldPlot.vectorLineStyle"];
    [coder encodeCPTSize:self.arrowSize forKey:@"CPTVectorFieldPlot.arrowSize"];
    [coder encodeInteger:self.arrowType forKey:@"CPTVectorFieldPlot.arrowType"];
    [coder encodeObject:self.arrowFill forKey:@"CPTVectorFieldPlot.arrowFill"];
    [coder encodeBool:self.usesEvenOddClipRule forKey:@"CPTVectorFieldPlot.usesEvenOddClipRule"];
   
    // No need to archive these properties:
    // pointingDeviceDownIndex
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        normalisedVectorLength = [coder decodeCGFloatForKey:@"CPTVectorFieldPlot.normalisedVectorLength"];
        vectorLineStyle = [[coder decodeObjectOfClass:[CPTLineStyle class]
                                            forKey:@"CPTVectorFieldPlot.vectorLineStyle"] copy];
        arrowSize        = [coder decodeCPTSizeForKey:@"CPTVectorFieldPlot.arrowSize"];
        arrowType = (CPTVectorFieldArrowType)[coder decodeIntegerForKey:@"CPTVectorFieldPlot.arrowType"];
        arrowFill = [coder decodeObjectOfClass:[CPTFill class]
                                   forKey:@"CPTVectorFieldPlot.fill"];
        usesEvenOddClipRule = [coder decodeBoolForKey:@"CPTVectorFieldPlot.usesEvenOddClipRule"];
        
        pointingDeviceDownIndex = NSNotFound;
        cachedArrowHeadPath = NULL;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Determining Which Points to Draw

/// @cond

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(nonnull CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{
    if ( dataCount == 0 ) {
        return;
    }

    CPTPlotRangeComparisonResult *xRangeFlags = calloc(dataCount, sizeof(CPTPlotRangeComparisonResult) );
    CPTPlotRangeComparisonResult *yRangeFlags = calloc(dataCount, sizeof(CPTPlotRangeComparisonResult) );
    BOOL *nanFlags                            = calloc(dataCount, sizeof(BOOL) );

    CPTPlotRange *xRange = xyPlotSpace.xRange;
    CPTPlotRange *yRange = xyPlotSpace.yRange;

    // Determine where each point lies in relation to range
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldY].data.bytes;

        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const double x = xBytes[i];
            const double y = yBytes[i];

            xRangeFlags[i] = [xRange compareToDouble:x];
            yRangeFlags[i] = [yRange compareToDouble:y];
            nanFlags[i]    = isnan(x) || isnan(y);
        });
    }
    else {
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldY].data.bytes;

        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const NSDecimal x = xBytes[i];
            const NSDecimal y = yBytes[i];

            xRangeFlags[i] = [xRange compareToDecimal:x];
            yRangeFlags[i] = [yRange compareToDecimal:y];
            nanFlags[i]    = NSDecimalIsNotANumber(&x);
        });
    }

    for ( NSUInteger i = 0; i < dataCount; i++ ) {
        BOOL drawPoint = (xRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                         (yRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                         !nanFlags[i];

        pointDrawFlags[i] = drawPoint;
    }

    free(xRangeFlags);
    free(yRangeFlags);
    free(nanFlags);
}

-(void)calculateViewPoints:(nonnull CGPointVector *)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    CPTPlotSpace *thePlotSpace = self.plotSpace;

    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes     = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldX].data.bytes;
        const double *yBytes     = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldY].data.bytes;
        const double *lengthBytes   = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldVectorLength].data.bytes;
        const double *directionBytes   = (const double *)[self cachedNumbersForField:CPTVectorFieldPlotFieldVectorDirection].data.bytes;
        
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const double x     = xBytes[i];
            const double y     = yBytes[i];
            const double length  = (double)self.normalisedVectorLength * lengthBytes[i];
            const double direction   = directionBytes[i];
            
            if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
                viewPoints[i].x = CPTNAN; // depending coordinates
                viewPoints[i].y = CPTNAN;
            }
            else {
                double plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos               = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i].x           = pos.x;
                viewPoints[i].y           = pos.y;

                plotPoint[CPTCoordinateX] = x + length * cos(direction);
                plotPoint[CPTCoordinateY] = y + length * sin(direction);
                pos                       = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i].tip_x        = pos.x;
                viewPoints[i].tip_y        = pos.y;
            }
        });
    }
    else {
        const NSDecimal *xBytes     = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldX].data.bytes;
        const NSDecimal *yBytes     = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldY].data.bytes;
        const NSDecimal *lengthBytes  = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldVectorLength].data.bytes;
        const NSDecimal *directionBytes   = (const NSDecimal *)[self cachedNumbersForField:CPTVectorFieldPlotFieldVectorDirection].data.bytes;
        
        
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const NSDecimal x     = xBytes[i];
            const NSDecimal y     = yBytes[i];
            const NSDecimal length  = CPTDecimalMultiply(lengthBytes[i], CPTDecimalFromCGFloat(self.normalisedVectorLength));
            const NSDecimal direction   = directionBytes[i];

            if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
                viewPoints[i].x = CPTNAN; // depending coordinates
                viewPoints[i].y = CPTNAN;
            }
            else {
                NSDecimal plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos               = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i].x           = pos.x;
                viewPoints[i].y           = pos.y;

                if ( !NSDecimalIsNotANumber(&length) && !NSDecimalIsNotANumber(&direction)) {
                    plotPoint[CPTCoordinateX] = x;
                    double _length = CPTDecimalDoubleValue(length);
                    double _direction = CPTDecimalDoubleValue(direction);
                    
                    NSDecimal deltaX = CPTDecimalFromDouble(_length * cos(_direction));
                    NSDecimal deltaY = CPTDecimalFromDouble(_length * sin(_direction));
                    NSDecimal x_tip, y_tip;
                    NSDecimalAdd(&x_tip, &x, &deltaX, NSRoundPlain);
                    NSDecimalAdd(&y_tip, &y, &deltaY, NSRoundPlain);
                    plotPoint[CPTCoordinateX] = x_tip;
                    plotPoint[CPTCoordinateY] = y_tip;
                    pos                       = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                    viewPoints[i].tip_x        = pos.x;
                    viewPoints[i].tip_y        = pos.y;
                }
                else {
                    viewPoints[i].tip_x = CPTNAN;
                    viewPoints[i].tip_y = CPTNAN;
                }
            }
        });
    }
}

-(void)alignViewPointsToUserSpace:(nonnull CGPointVector *)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    // Align to device pixels if there is a data line.
    // Otherwise, align to view space, so fills are sharp at edges.
    if ( self.vectorLineStyle.lineWidth > CPTFloat(0.0) ) {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                CGFloat x       = viewPoints[i].x;
                CGFloat y       = viewPoints[i].y;
                CGPoint pos     = CPTAlignPointToUserSpace(context, CPTPointMake(x, y) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;
                
                CGFloat tip_x       = viewPoints[i].tip_x;
                CGFloat tip_y       = viewPoints[i].tip_y;
                pos                 = CPTAlignPointToUserSpace(context, CPTPointMake(tip_x, tip_y) );
                viewPoints[i].tip_x = pos.x;
                viewPoints[i].tip_y = pos.y;
            }
        });
    }
    else {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                CGFloat x       = viewPoints[i].x;
                CGFloat y       = viewPoints[i].y;
                CGPoint pos     = CPTAlignIntegralPointToUserSpace(context, CPTPointMake(x, y) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;

                CGFloat tip_x       = viewPoints[i].tip_x;
                CGFloat tip_y       = viewPoints[i].tip_y;

                pos                 = CPTAlignPointToUserSpace(context, CPTPointMake(tip_x, tip_y) );
                viewPoints[i].tip_x = pos.x;
                viewPoints[i].tip_y = pos.y;
            }
        });
    }
}

-(NSInteger)extremeDrawnPointIndexForFlags:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound
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

    // Vector line styles
    [self reloadVectorLineStylesInIndexRange:indexRange];
}

-(void)reloadPlotDataInIndexRange:(NSRange)indexRange
{
    [super reloadPlotDataInIndexRange:indexRange];

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:indexRange] ) {
        id<CPTVectorFieldPlotDataSource> theDataSource = (id<CPTVectorFieldPlotDataSource>)self.dataSource;

        if ( theDataSource ) {
            id newXValues = [self numbersFromDataSourceForField:CPTVectorFieldPlotFieldX recordIndexRange:indexRange];
            [self cacheNumbers:newXValues forField:CPTVectorFieldPlotFieldX atRecordIndex:indexRange.location];
            id newYValues = [self numbersFromDataSourceForField:CPTVectorFieldPlotFieldY recordIndexRange:indexRange];
            [self cacheNumbers:newYValues forField:CPTVectorFieldPlotFieldY atRecordIndex:indexRange.location];
            id newLengthValues = [self numbersFromDataSourceForField:CPTVectorFieldPlotFieldVectorLength recordIndexRange:indexRange];
            [self cacheNumbers:newLengthValues forField:CPTVectorFieldPlotFieldVectorLength atRecordIndex:indexRange.location];
            id newDirectionValues = [self numbersFromDataSourceForField:CPTVectorFieldPlotFieldVectorDirection recordIndexRange:indexRange];
            [self cacheNumbers:newDirectionValues forField:CPTVectorFieldPlotFieldVectorDirection atRecordIndex:indexRange.location];
        }
        else {
            self.xValues     = nil;
            self.yValues     = nil;
            self.lengthValues  = nil;
            self.directionValues   = nil;
        }
    }
}

/// @endcond

/**
 *  @brief Reload all vector line styles from the data source immediately.
 **/
-(void)reloadVectorLineStyles
{
    [self reloadVectorLineStylesInIndexRange:NSMakeRange(0, self.cachedDataCount)];
}

/** @brief Reload vector line styles in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadVectorLineStylesInIndexRange:(NSRange)indexRange
{
    id<CPTVectorFieldPlotDataSource> theDataSource = (id<CPTVectorFieldPlotDataSource>)self.dataSource;
    
    if ([theDataSource isKindOfClass:[CPTFieldFunctionDataSource class]]) {
        theDataSource = (id<CPTVectorFieldPlotDataSource>)self.vectorLineStylesDataSource;
    }

    BOOL needsLegendUpdate = NO;

    if ( [theDataSource respondsToSelector:@selector(lineStylesForVectorFieldPlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource lineStylesForVectorFieldPlot:self recordIndexRange:indexRange]
                  forKey:CPTVectorFieldPlotBindingVectorLineStyles
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(lineStyleForVectorFieldPlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject                    = [CPTPlot nilData];
        CPTMutableLineStyleArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex             = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLineStyle *dataSourceLineStyle = [theDataSource lineStyleForVectorFieldPlot:self recordIndex:idx];
            if ( dataSourceLineStyle ) {
                [array addObject:dataSourceLineStyle];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTVectorFieldPlotBindingVectorLineStyles atRecordIndex:indexRange.location];
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

-(void)renderAsVectorInContext:(nonnull CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTVectorFieldPlotFieldX];
    CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTVectorFieldPlotFieldY];

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
    CGPointVector *viewPoints = calloc(dataCount, sizeof(CGPointVector) );
    BOOL *drawPointFlags     = calloc(dataCount, sizeof(BOOL) );

    CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];
    if ( self.alignsPointsToPixels ) {
        [self alignViewPointsToUserSpace:viewPoints withContext:context drawPointFlags:drawPointFlags numberOfPoints:dataCount];
    }

    // Get extreme points
    NSInteger lastDrawnPointIndex  = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:NO];
    NSInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];

    if ( firstDrawnPointIndex != NSNotFound ) {
        
        BOOL alignPoints     = self.alignsPointsToPixels;

        for ( NSUInteger i = (NSUInteger)firstDrawnPointIndex; i <= (NSUInteger)lastDrawnPointIndex; i++ ) {
            [self drawVectorInContext:context
                           lineStyle:[self vectorLineStyleForIndex:i]
                           viewPoint:&viewPoints[i]
                         alignPoints:alignPoints];
        }
    }

    free(viewPoints);
    free(drawPointFlags);
}

-(void)drawVectorInContext:(nonnull CGContextRef)context
                lineStyle:(nonnull CPTLineStyle *)lineStyle
                viewPoint:(nonnull CGPointVector *)viewPoint
              alignPoints:(BOOL)alignPoints
{
    if ( [lineStyle isKindOfClass:[CPTLineStyle class]] && !isnan(viewPoint->x) && !isnan(viewPoint->y) ) {
        CPTAlignPointFunction alignmentFunction = CPTAlignPointToUserSpace;

        CGFloat lineWidth = lineStyle.lineWidth;
        if ( (self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
        
        CPTLineStyle *theLineStyle = nil;
        CPTFill *theFill           = nil;

        switch ( self.arrowType ) {
            case CPTVectorFieldArrowTypeSolid:
            case CPTVectorFieldArrowTypeSwept:
                theLineStyle = lineStyle;
                if( self.arrowFill == nil ) {
                    if( theLineStyle.lineColor != nil ) {
                        CPTColor *lineColor = theLineStyle.lineColor;
                        theFill      = [CPTFill fillWithColor:lineColor];
                    }
                }
                else {
                    theFill      = self.arrowFill;
                }
                break;
                
            case CPTVectorFieldArrowTypeOpen:
                theLineStyle = lineStyle;
                
            default:
                break;
        }

        // tip
        if ( !isnan(viewPoint->tip_x) && !isnan(viewPoint->tip_y) && ( theLineStyle || theFill ) ) {
            CGMutablePathRef path = CGPathCreateMutable();
            
            CGPoint alignedBasePoint = CPTPointMake(viewPoint->x, viewPoint->y);
            CGPoint alignedTipPoint = CPTPointMake(viewPoint->tip_x, viewPoint->tip_y);
            if ( alignPoints ) {
                alignedBasePoint = alignmentFunction(context, alignedBasePoint);
                alignedTipPoint  = alignmentFunction(context, alignedTipPoint);
            }
            if ( CGPointEqualToPoint(alignedBasePoint, alignedTipPoint) ) {
                CGPathMoveToPoint(path, NULL, alignedBasePoint.x-1, alignedBasePoint.y-1);
                CGPathAddEllipseInRect(path, NULL, CGRectMake(alignedBasePoint.x-1, alignedBasePoint.y-1, 2.0, 2.0));
                CGContextBeginPath(context);
                CGContextAddPath(context, path);
                [theLineStyle setLineStyleInContext:context];
                [theLineStyle strokePathInContext:context];
            }
            else {
                CGPathMoveToPoint(path, NULL, alignedBasePoint.x-1, alignedBasePoint.y-1);
                CGPathAddEllipseInRect(path, NULL, CGRectMake(alignedBasePoint.x-1, alignedBasePoint.y-1, 2.0, 2.0));
                CGPathMoveToPoint(path, NULL, alignedBasePoint.x, alignedBasePoint.y);
                CGPathAddLineToPoint(path, NULL, alignedTipPoint.x, alignedTipPoint.y);
                
                CGFloat direction = atan((alignedTipPoint.y - alignedBasePoint.y) / (alignedTipPoint.x - alignedBasePoint.x)) + ((alignedTipPoint.x - alignedBasePoint.x) < 0.0 ? M_PI : 0.0);

                CGContextBeginPath(context);
                CGContextAddPath(context, path);
                [theLineStyle setLineStyleInContext:context];
                [theLineStyle strokePathInContext:context];
                
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, alignedTipPoint.x, alignedTipPoint.y);
                CGContextRotateCTM(context, direction - CPTFloat(M_PI_2) ); // standard symbol points up
                
                CGPathRef theArrowHeadPath = self.cachedArrowHeadPath;

                if ( theFill ) {
                    // use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
                    CGSize arrowHeadSize = self.arrowSize;
                    CGSize halfSize   = CPTSizeMake(arrowHeadSize.width / CPTFloat(2.0), arrowHeadSize.height / CPTFloat(2.0) );
                    CGRect bounds     = CPTRectMake(-halfSize.width, -halfSize.height, arrowHeadSize.width, arrowHeadSize.height);

                    CGContextSaveGState(context);
                    if ( !CGPathIsEmpty(theArrowHeadPath) ) {
                        CGContextBeginPath(context);
                        CGContextAddPath(context, theArrowHeadPath);
                        if ( self.usesEvenOddClipRule ) {
                            CGContextEOClip(context);
                        }
                        else {
                            CGContextClip(context);
                        }
                    }
                    [theFill fillRect:bounds inContext:context];
                    CGContextRestoreGState(context);
                }

                if ( theLineStyle ) {
                    [theLineStyle setLineStyleInContext:context];
                    CGContextBeginPath(context);
                    CGContextAddPath(context, theArrowHeadPath);
                    [theLineStyle strokePathInContext:context];
                }

                CGContextRestoreGState(context);
            }
            CGPathRelease(path);
        }
    }
}

-(void)drawSwatchForLegend:(nonnull CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(nonnull CGContextRef)context
{
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    if ( self.drawLegendSwatchDecoration ) {
        
        CPTLineStyle *theVectorLineStyle = [self vectorLineStyleForIndex:idx];

        if ( [theVectorLineStyle isKindOfClass:[CPTLineStyle class]] ) {
            CGPointVector viewPoint;
            viewPoint.x     = CGRectGetMinX(rect);
            viewPoint.y     = CGRectGetMidY(rect);
            viewPoint.tip_x  = CGRectGetMaxX(rect);
            viewPoint.tip_y   = CGRectGetMidY(rect);

            [self drawVectorInContext:context
                           lineStyle:theVectorLineStyle
                           viewPoint:&viewPoint
                         alignPoints:YES];
        }
    }
}

-(nullable CPTLineStyle *)vectorLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theLineStyle = [self cachedValueForKey:CPTVectorFieldPlotBindingVectorLineStyles recordIndex:idx];

    if ( (theLineStyle == nil) || (theLineStyle == [CPTPlot nilData]) ) {
        theLineStyle = self.vectorLineStyle;
    }

    return theLineStyle;
}

/// @endcond

#pragma mark -
#pragma mark Private methods

/// @cond

/** @internal
 *  @brief Creates and returns a drawing path for the current arrowhead  type.
 *  The path is standardized for a line direction of @quote{up}.
 *  @return A path describing the outline of the current line cap type.
 **/
-(nullable CGPathRef)newArrowHeadPath
{
    CGSize arrowHeadSize = self.arrowSize;
    CGSize halfSize    = CPTSizeMake(arrowHeadSize.width / CPTFloat(2.0), arrowHeadSize.height / CPTFloat(2.0) );

    CGMutablePathRef arrowHeadPath = CGPathCreateMutable();

    switch ( self.arrowType ) {
        case CPTVectorFieldArrowTypeNone:
            // empty path
            break;

        case CPTVectorFieldArrowTypeOpen:
            CGPathMoveToPoint(arrowHeadPath, NULL, -halfSize.width, -halfSize.height);
            CGPathAddLineToPoint(arrowHeadPath, NULL, CPTFloat(0.0), CPTFloat(0.0) );
            CGPathAddLineToPoint(arrowHeadPath, NULL, halfSize.width, -halfSize.height);
            break;

        case CPTVectorFieldArrowTypeSolid:
            CGPathMoveToPoint(arrowHeadPath, NULL, -halfSize.width, -halfSize.height);
            CGPathAddLineToPoint(arrowHeadPath, NULL, CPTFloat(0.0), CPTFloat(0.0) );
            CGPathAddLineToPoint(arrowHeadPath, NULL, halfSize.width, -halfSize.height);
            CGPathCloseSubpath(arrowHeadPath);
            break;

        case CPTVectorFieldArrowTypeSwept:
            CGPathMoveToPoint(arrowHeadPath, NULL, -halfSize.width, -halfSize.height);
            CGPathAddLineToPoint(arrowHeadPath, NULL, CPTFloat(0.0), CPTFloat(0.0) );
            CGPathAddLineToPoint(arrowHeadPath, NULL, halfSize.width, -halfSize.height);
            CGPathAddLineToPoint(arrowHeadPath, NULL, CPTFloat(0.0), -arrowHeadSize.height * CPTFloat(0.375) );
            CGPathCloseSubpath(arrowHeadPath);
            break;

    }
    return arrowHeadPath;
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(nonnull NSString *)aKey
{
    static NSSet<NSString *> *keys   = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithArray:@[@"arrowSize",
                                     @"arrowType"]];
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
    return 4;
}

-(nonnull CPTNumberArray *)fieldIdentifiers
{
    return @[@(CPTVectorFieldPlotFieldX),
             @(CPTVectorFieldPlotFieldY),
             @(CPTVectorFieldPlotFieldVectorLength),
             @(CPTVectorFieldPlotFieldVectorDirection)];
}

-(nonnull CPTNumberArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
    CPTNumberArray *result = nil;

    switch ( coord ) {
        case CPTCoordinateX:
            result = @[@(CPTVectorFieldPlotFieldX)];
            break;

        case CPTCoordinateY:
            result = @[@(CPTVectorFieldPlotFieldY)];
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
        case CPTVectorFieldPlotFieldX:
            coordinate = CPTCoordinateX;
            break;

        case CPTVectorFieldPlotFieldY:
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

-(void)positionLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
{
    NSNumber *xValue = [self cachedNumberForField:CPTVectorFieldPlotFieldX recordIndex:idx];
    NSNumber *yValue = [self cachedNumberForField:CPTVectorFieldPlotFieldY recordIndex:idx];

    BOOL positiveDirection = YES;
    CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

    if ( CPTDecimalLessThan(yRange.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
        positiveDirection = !positiveDirection;
    }

    label.anchorPlotPoint     = @[xValue, yValue];
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
    CGPointVector *viewPoints = calloc(dataCount, sizeof(CGPointVector) );
    BOOL *drawPointFlags     = calloc(dataCount, sizeof(BOOL) );

    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    NSInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];
    if ( result != NSNotFound ) {
        CGPointVector lastViewPoint;
        CGFloat minimumDistanceSquared = CPTNAN;
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

            if ( !isnan(lastViewPoint.tip_x) && (point.x > lastViewPoint.tip_x) ) {
                result = NSNotFound;
            }
            if ( !isnan(lastViewPoint.tip_y) && (point.x > lastViewPoint.tip_y) ) {
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
 *  @if iOSOnly started touching the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldTouchDownAtRecordIndex: -vectorFieldPlot:vectorFieldTouchDownAtRecordIndex: @endlink or
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:withEvent: -vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each bar in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTVectorFieldPlotDelegate> theDelegate = (id<CPTVectorFieldPlotDelegate>)self.delegate;
    if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];
        self.pointingDeviceDownIndex = idx;

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate vectorFieldPlot:self vectorFieldTouchDownAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchDownAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate vectorFieldPlot:self vectorFieldTouchDownAtRecordIndex:idx withEvent:event];
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
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldTouchUpAtRecordIndex: -vectorFieldPlot:vectorFieldTouchUpAtRecordIndex: @endlink and/or
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:withEvent: -vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each vector in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  If the bar being released is the same as the one that was pressed (see
 *  @link CPTVectorFieldPlot::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex: -vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTVectorFieldPlotDelegate::vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:withEvent: -vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, these will be called.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    NSUInteger selectedDownIndex = self.pointingDeviceDownIndex;

    self.pointingDeviceDownIndex = NSNotFound;

    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTVectorFieldPlotDelegate> theDelegate = (id<CPTVectorFieldPlotDelegate>)self.delegate;
    if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate vectorFieldPlot:self vectorFieldTouchUpAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldTouchUpAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate vectorFieldPlot:self vectorFieldTouchUpAtRecordIndex:idx withEvent:event];
            }

            if ( idx == selectedDownIndex ) {
                if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:)] ) {
                    handled = YES;
                    [theDelegate vectorFieldPlot:self vectorFieldWasSelectedAtRecordIndex:idx];
                }

                if ( [theDelegate respondsToSelector:@selector(vectorFieldPlot:vectorFieldWasSelectedAtRecordIndex:withEvent:)] ) {
                    handled = YES;
                    [theDelegate vectorFieldPlot:self vectorFieldWasSelectedAtRecordIndex:idx withEvent:event];
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

-(void)setVectorLineStyle:(nullable CPTLineStyle *)newLineStyle
{
    if ( vectorLineStyle != newLineStyle ) {
        vectorLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setArrowSize:(CGSize)newArrowSize
{
    if ( !CGSizeEqualToSize(arrowSize, newArrowSize) ) {
        arrowSize = newArrowSize;
        [self setCachedArrowHeadPath:NULL];
        [self setNeedsDisplay];
    }
}

-(void)setArrowType:(CPTVectorFieldArrowType)newArrowType
{
    if ( arrowType != newArrowType ) {
        arrowType = newArrowType;
        [self setCachedArrowHeadPath:NULL];
        [self setNeedsDisplay];
    }
}

-(void)setXValues:(nullable CPTNumberArray *)newValues
{
    [self cacheNumbers:newValues forField:CPTVectorFieldPlotFieldX];
}

-(nullable CPTNumberArray *)xValues
{
    return [[self cachedNumbersForField:CPTVectorFieldPlotFieldX] sampleArray];
}

-(void)setYValues:(nullable CPTNumberArray *)newValues
{
    [self cacheNumbers:newValues forField:CPTVectorFieldPlotFieldY];
}

-(nullable CPTNumberArray *)yValues
{
    return [[self cachedNumbersForField:CPTVectorFieldPlotFieldY] sampleArray];
}

-(nullable CPTMutableNumericData *)lengthValues
{
    return [self cachedNumbersForField:CPTVectorFieldPlotFieldVectorLength];
}

-(void)setLengthValues:(nullable CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTVectorFieldPlotFieldVectorLength];
}

-(nullable CPTMutableNumericData *)directionValues
{
    return [self cachedNumbersForField:CPTVectorFieldPlotFieldVectorDirection];
}

-(void)setDirectionValues:(nullable CPTMutableNumericData *)newValues
{
    [self cacheNumbers:newValues forField:CPTVectorFieldPlotFieldVectorDirection];
}

-(nullable CPTLineStyleArray *)vectorLineStyles
{
    return [self cachedArrayForKey:CPTVectorFieldPlotBindingVectorLineStyles];
}

-(void)setLineStyles:(nullable CPTLineStyleArray *)newLineStyles
{
    [self cacheArray:newLineStyles forKey:CPTVectorFieldPlotBindingVectorLineStyles];
    [self setNeedsDisplay];
}

-(nullable CGPathRef)cachedArrowHeadPath
{
    if ( !cachedArrowHeadPath ) {
        cachedArrowHeadPath = [self newArrowHeadPath];
    }
    return cachedArrowHeadPath;
}

-(void)setCachedArrowHeadPath:(nullable CGPathRef)newPath
{
    if ( cachedArrowHeadPath != newPath ) {
        CGPathRelease(cachedArrowHeadPath);
        cachedArrowHeadPath = CGPathRetain(newPath);
    }
}

/// @endcond

@end
