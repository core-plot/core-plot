//
//  CPTContourPlot.mm
//  CorePlot Mac
//
//  Created by Steve Wainwright on 19/12/2020.
//
// This Class needs the libCorePlot-Contours.a c++ static library to use the contours algorithm
// and hence its extension is mm.
//
#import "CPTContourPlot.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTColor.h"
#import "CPTLineStyle.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTMutableTextStyle.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTShadow.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"
#import "Contours.h"
#import "CPTFieldFunctionDataSource.h"
#import "tgmath.h"

#define MAXISOCURVES 21

/** @defgroup plotAnimationContourPlot Contour Plot
 *  @brief Contour plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsContourPlot Range Plot Bindings
 *  @brief Binding identifiers for contour plots.
 *  @ingroup plotBindings
 *  @endif
 **/

CPTContourPlotBinding const CPTContourPlotBindingXValues       = @"xValues";       ///< X values.
CPTContourPlotBinding const CPTContourPlotBindingYValues       = @"yValues";       ///< Y values.
CPTContourPlotBinding const CPTContourPlotBindingFunctionValues    = @"functionValues"; //< Contour base point function values.

/// @cond

/** @brief A structure used internally by CPTContourPlot to plot isoCurves.
 **/

typedef struct {
    CGPoint *array;
    size_t used;
    size_t size;
} ContourPoints;

void initContourPoints(ContourPoints *a, size_t initialSize);
void insertContourPoints(ContourPoints *a, CGPoint element);
void clearContourPoints(ContourPoints *a);
void freeContourPoints(ContourPoints *a);

void initContourPoints(ContourPoints *a, size_t initialSize) {
    a->array = static_cast<CGPoint*>(calloc(initialSize, sizeof(CGPoint)));
    a->used = 0;
    a->size = initialSize;
}

void insertContourPoints(ContourPoints *a, CGPoint element) {
    // a->used is the number of used entries, because a->array[a->used++] updates a->used only *after* the array has been accessed.
    // Therefore a->used can go up to a->size
    if (a->used == a->size) {
        a->size *= 2;
        a->array = static_cast<CGPoint*>(realloc(a->array, a->size * sizeof(CGPoint)));
    }
    a->array[a->used++] = element;
}

void clearContourPoints(ContourPoints *a) {
    a->used = 0;
}

void freeContourPoints(ContourPoints *a) {
    free(a->array);
    a->array = NULL;
    a->used = a->size = 0;
}


@interface CPTContourPlot() {
    @private
    // Accessibles variables
    
    int noColumnsFirst;            // primary    grid, number of columns
    int noRowsFirst;               // primary    grid, number of rows
    int noColumnsSecondary;        // secondary grid, number of columns
    int noRowsSecondary;           // secondary grid, number of rows
    
    // Work functions and variables
    

}
@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *xValues;
@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *yValues;
@property (nonatomic, readwrite, copy, nullable) CPTMutableNumericData *functionValues;
@property (nonatomic, readwrite, assign) NSUInteger pointingDeviceDownIndex;

@property (nonatomic, readwrite, assign) BOOL needsIsoCurvesRelabel;
@property (nonatomic, readwrite, assign) NSRange isoCurvesLabelIndexRange;
@property (nonatomic, readwrite, strong, nullable) NSMutableArray<CPTMutableAnnotationArray*> *isoCurvesLabelAnnotations;
@property (nonatomic, readwrite, strong, nullable) CPTMutableLineStyleArray *isoCurvesLineStyles;
@property (nonatomic, readwrite, strong, nullable) CPTMutableFillArray *isoCurvesFills;
@property (nonatomic, readwrite, strong, nullable) CPTMutableLayerArray *isoCurvesLabels;
@property (nonatomic, readwrite, strong, nullable) CPTMutableNumberArray *isoCurvesValues;
@property (nonatomic, readwrite, strong, nullable) CPTMutableNumberArray *isoCurvesNoStrips;
@property (nonatomic, readwrite, strong, nullable) NSMutableArray<CPTMutableValueArray*> *isoCurvesLabelsPositions;

@property (nonatomic, readwrite, assign) double stepX;
@property (nonatomic, readwrite, assign) double stepY;
@property (nonatomic, readwrite, assign) double scaleX;
@property (nonatomic, readwrite, assign) double scaleY;
@property (nonatomic, readwrite, assign) double maxWidthPixels;
@property (nonatomic, readwrite, assign) double maxHeightPixels;

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(nonnull CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(nonnull CGPoint*)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount;
-(void)alignViewPointsToUserSpace:(nonnull CGPoint*)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlag numberOfPoints:(NSUInteger)dataCounts;
-(NSInteger)extremeDrawnPointIndexForFlags:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound;


-(CPTLineStyle *)isoCurveLineStyleForIndex:(NSUInteger)idx;

@end

/// @endcond

#pragma mark -

/** @brief A plot class representing a contour of values in one coordinate,
 *  such as typically used to show contours.
 *  @see See @ref plotAnimationContourPlot "Contour Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsContourPlot "Contour Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTContourPlot

@dynamic xValues;
@dynamic yValues;
@dynamic functionValues;


/** @property nullable id<CPTPlotDataSource> contourAppearanceDataSource
 *  @brief The appearance data source for the plot.
 **/
@synthesize contourAppearanceDataSource;

/** @property CPTLineStyle *isoCurveLineStyle
 *  @brief The line style of the contours.
 *  Set to @nil to have no Contours. Default is a black line style.
 **/
@synthesize isoCurveLineStyle;

/** @property double minFunctionValue
 *  @brief The minimum value of the Contour Function.
 **/
@synthesize minFunctionValue;

/** @property double maxFunctionValue
 *  @brief The maximum value of the Contour Function.
 **/
@synthesize maxFunctionValue;

/** @property NSUInteger  noIsoCurves
 *  @brief The number of isocurves to look for.
 **/
@synthesize noIsoCurves;

/** @property CPTContourPlotInterpolation interpolation
 *  @brief The interpolation algorithm used for lines between data points.
 *  Default is #CPTContourPlotInterpolationLinear.
 **/
@synthesize interpolation;

/** @property CPTContourPlotCurvedInterpolationOption curvedInterpolationOption
 *  @brief The interpolation method used to generate the curved plot line (@ref interpolation = #CPTContourPlotInterpolationCurved)
 *  Default is #CPTContourPlotCurvedInterpolationNormal
 **/
@synthesize curvedInterpolationOption;

/** @property CGFloat curvedInterpolationCustomAlpha
 *  @brief The custom alpha value used when the #CPTContourPlotCurvedInterpolationCatmullCustomAlpha interpolation is selected.
 *  Default is @num{0.5}.
 *  @note Must be between @num{0.0} and @num{1.0}.
 **/
@synthesize curvedInterpolationCustomAlpha;

/** @internal
 *  @property NSUInteger pointingDeviceDownIndex
 *  @brief The index that was selected on the pointing device down event.
 **/
@synthesize pointingDeviceDownIndex;

/** @property BOOL needsIsoCurveRelabel
 *  @brief If @YES, the plot needs to have isoCurves relabeled before the layer content is drawn.
 **/
@synthesize needsIsoCurvesRelabel;

/** @property NSRange isoCurvesLabelIndexRange
 *  @brief Range of isoCurves to be relabeled.
 **/
@synthesize isoCurvesLabelIndexRange;

/** @property CPTMutableAnnotationArray *isoCurvesLabelAnnotations
 *  @brief Mutable annotation array for isoCurves labels.
 **/
@synthesize isoCurvesLabelAnnotations;

/** @property CPTMutableLayerArray *isoCurvesLabels
 *  @brief CPTLayer array for isoCurves annotation content.
 **/
@synthesize isoCurvesLabels;

/** @property NSMutableArray<CPTMutableValueArray*> *isoCurvesLabelsPositions;
 *  @brief a mutable Array of NSValue CGPoint arrays for positions of isoCurves label annotation.
 **/
@synthesize isoCurvesLabelsPositions;

/** @property CPTMutableLineStyleArray *isoCurvesLineStyles
 *  @brief Mutable annotation array for isoCurves line styles.
 **/
@synthesize isoCurvesLineStyles;

/** @property CPTMutableFillArray *isoCurvesFills
 *  @brief Mutable annotation array for isoCurves fills.
 **/
@synthesize isoCurvesFills;

/** @property CPTMutableNumberArray *isoCurvesValues
 *  @brief Mutable number array to store the value of an isoCurve contour.
 **/
@synthesize isoCurvesValues;

/** @property CPTMutableNumberArray *isoCurvesNoStrips
 *  @brief Mutable number array to store the number of strips per isoCurve contour.
 **/
@synthesize isoCurvesNoStrips;

/** @property CGFloat isoCurveLabelOffset
 *  @brief The distance that labels should be offset from their anchor points. The direction of the offset is defined by subclasses.
 *  @ingroup plotAnimationAllPlots
 **/
@synthesize isoCurvesLabelOffset;

/** @property CGFloat isoCurveLabelRotation
 *  @brief The rotation of the data labels in radians.
 *  Set this property to @num{π/2} to have labels read up the screen, for example.
 *  @ingroup plotAnimationAllPlots
 **/
@synthesize isoCurvesLabelRotation;

/** @property nullable CPTTextStyle *isoCurveLabelTextStyle
 *  @brief The text style used to draw the data labels.
 *  Set this property to @nil to hide the isoCurve labels.
 **/
@synthesize isoCurvesLabelTextStyle;

/** @property nullable NSFormatter *isoCurveLabelFormatter
 *  @brief The number formatter used to format the data labels.
 *  Set this property to @nil to hide the data labels.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (e.g., @quote{Jan 10, 2010}).
 *  The CPTCalendarFormatter and CPTTimeFormatter classes are useful for this purpose.
 **/
@synthesize isoCurvesLabelFormatter;

/** @property nullable CPTShadow *isoCurveLabelShadow
 *  @brief The shadow applied to each isoCurve label.
 **/
@synthesize isoCurvesLabelShadow;

/** @property BOOL showIsoCurveLabels
 *  @brief If @YES, the plot will label the isoCurves.
 **/
@synthesize showIsoCurvesLabels;

/** @property CPTContourDataSourceBlock  dataSourceBlock
 *  @brief block to supply contours with function evaluator.
 **/
@synthesize dataSourceBlock;

/** @property CPTMutableNumberArray *limits
 *  @brief limits of the plot range
 **/
@synthesize limits;

@synthesize stepX;
@synthesize stepY;
@synthesize scaleX;
@synthesize scaleY;
@synthesize maxWidthPixels;
@synthesize maxHeightPixels;

/// @cond

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTContourPlot class] ) {
        [self exposeBinding:CPTContourPlotBindingXValues];
        [self exposeBinding:CPTContourPlotBindingYValues];
        [self exposeBinding:CPTContourPlotBindingFunctionValues];
    }
}

#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTContourPlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref isoCurveLineStyle = default line style
 *  - @ref labelField = #CPTContourPlotFieldX
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTContourPlot object.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        isoCurveLineStyle        = [[CPTLineStyle alloc] init];
        self.noIsoCurves = MAXISOCURVES;

        scaleX = CPTDecimalDoubleValue(self.plotArea.widthDecimal);
        scaleY = CPTDecimalDoubleValue(self.plotArea.heightDecimal);
        maxWidthPixels = CPTDecimalDoubleValue(self.plotArea.widthDecimal);
        maxHeightPixels = CPTDecimalDoubleValue(self.plotArea.heightDecimal);
        limits = [CPTMutableNumberArray arrayWithObjects:@0, @0, @0, @0, nil];
        maxFunctionValue = 0.0;
        minFunctionValue = 0.0;
        
        self.labelField = CPTContourPlotFieldX; // but also need CPTContourPlotFieldY as 2 dimensional
    }
    return self;
}

/// @}

/// @cond

-(nonnull instancetype)initWithLayer:(nonnull id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTContourPlot *theLayer = static_cast<CPTContourPlot*>(layer);

        isoCurveLineStyle        = theLayer->isoCurveLineStyle;
//        usesEvenOddClipRule = theLayer->usesEvenOddClipRule;

        pointingDeviceDownIndex = NSNotFound;
    }
    return self;
}

- (void)dealloc {
    if(isoCurvesValues != nil){
        [isoCurvesValues removeAllObjects];
        isoCurvesValues = nil;
    }
    if(isoCurvesLineStyles != nil) {
        [isoCurvesLineStyles removeAllObjects];
        isoCurvesLineStyles = nil;
    }
    if(isoCurvesFills != nil) {
        [isoCurvesFills removeAllObjects];
        isoCurvesFills = nil;
    }
    if(isoCurvesLabels != nil) {
        [isoCurvesLabels removeAllObjects];
        isoCurvesLabels = nil;
    }
    if(isoCurvesLabelAnnotations != nil) {
        [isoCurvesLabelAnnotations removeAllObjects];
        isoCurvesLabelAnnotations = nil;
    }
    if(isoCurvesLabelsPositions != nil) {
        [isoCurvesLabelsPositions removeAllObjects];
        isoCurvesLabelsPositions = nil;
    }
    if(isoCurvesNoStrips != nil) {
        [isoCurvesNoStrips removeAllObjects];
        isoCurvesNoStrips = nil;
    }
}

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.isoCurveLineStyle forKey:@"CPTContourPlot.isoCurveLineStyle"];

    // No need to archive these properties:
    // pointingDeviceDownIndex
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        isoCurveLineStyle = [[coder decodeObjectOfClass:[CPTLineStyle class]
                                            forKey:@"CPTContourPlot.isoCurveLineStyle"] copy];
        
        pointingDeviceDownIndex = NSNotFound;
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

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount forPlotSpace:(nonnull CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly {
    if ( dataCount == 0 ) {
        return;
    }

    CPTPlotRangeComparisonResult *xRangeFlags = static_cast<CPTPlotRangeComparisonResult*>(calloc(dataCount, sizeof(CPTPlotRangeComparisonResult) ));
    CPTPlotRangeComparisonResult *yRangeFlags = static_cast<CPTPlotRangeComparisonResult*>(calloc(dataCount, sizeof(CPTPlotRangeComparisonResult) ));
    BOOL *nanFlags                            = static_cast<BOOL*>(calloc(dataCount, sizeof(BOOL) ));

    CPTPlotRange *xRange = xyPlotSpace.xRange;
    CPTPlotRange *yRange = xyPlotSpace.yRange;

    // Determine where each point lies in relation to range
    if ( self.doublePrecisionCache ) {
        const double *xBytes = static_cast<const double *>([self cachedNumbersForField:CPTContourPlotFieldX].data.bytes);
        const double *yBytes = static_cast<const double *>([self cachedNumbersForField:CPTContourPlotFieldY].data.bytes);

        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const double x = xBytes[i];
            const double y = yBytes[i];

            xRangeFlags[i] = [xRange compareToDouble:x];
            yRangeFlags[i] = [yRange compareToDouble:y];
            nanFlags[i]    = isnan(x) || isnan(y);
        });
    }
    else {
        const NSDecimal *xBytes = static_cast<const NSDecimal *>([self cachedNumbersForField:CPTContourPlotFieldX].data.bytes);
        const NSDecimal *yBytes = static_cast<const NSDecimal *>([self cachedNumbersForField:CPTContourPlotFieldY].data.bytes);

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

-(void)calculateViewPoints:(nonnull CGPoint*)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount {
    CPTPlotSpace *thePlotSpace = self.plotSpace;

    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes     = static_cast<const double *>([self cachedNumbersForField:CPTContourPlotFieldX].data.bytes);
        const double *yBytes     = static_cast<const double *>([self cachedNumbersForField:CPTContourPlotFieldY].data.bytes);
        const double *functionValueBytes   = static_cast<const double *>([self cachedNumbersForField:CPTContourPlotFieldFunctionValue].data.bytes);
        
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const double x     = xBytes[i];
            const double y     = yBytes[i];
            const double functionValue  = functionValueBytes[i];
            
            if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
                viewPoints[i].x = static_cast<CGFloat>(NAN); // depending coordinates
                viewPoints[i].y = static_cast<CGFloat>(NAN);
            }
            else {
                double plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos               = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i].x           = pos.x;
                viewPoints[i].y           = pos.y;
                self.minFunctionValue = MIN(self.minFunctionValue, functionValue);
                self.maxFunctionValue = MAX(self.maxFunctionValue, functionValue);
            }
        });
    }
    else {
        const NSDecimal *xBytes     = static_cast<const NSDecimal *>([self cachedNumbersForField:CPTContourPlotFieldX].data.bytes);
        const NSDecimal *yBytes     = static_cast<const NSDecimal *>([self cachedNumbersForField:CPTContourPlotFieldY].data.bytes);
        const NSDecimal *functionValueBytes  = static_cast<const NSDecimal *>([self cachedNumbersForField:CPTContourPlotFieldFunctionValue].data.bytes);
        
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            const NSDecimal x     = xBytes[i];
            const NSDecimal y     = yBytes[i];
            const NSDecimal functionValue  = functionValueBytes[i];

            if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
                viewPoints[i].x = static_cast<CGFloat>(NAN);//CPTNAN; // depending coordinates
                viewPoints[i].y = static_cast<CGFloat>(NAN);
            }
            else {
                NSDecimal plotPoint[2];
                plotPoint[CPTCoordinateX] = x;
                plotPoint[CPTCoordinateY] = y;
                CGPoint pos               = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i].x           = pos.x;
                viewPoints[i].y           = pos.y;
                self.minFunctionValue = MIN(self.minFunctionValue, CPTDecimalDoubleValue(functionValue));
                self.maxFunctionValue = MAX(self.maxFunctionValue, CPTDecimalDoubleValue(functionValue));
            }
        });
    }
}

-(void)alignViewPointsToUserSpace:(nonnull CGPoint*)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount {
    // Align to device pixels if there is a data line.
    // Otherwise, align to view space, so fills are sharp at edges.
    if ( self.isoCurveLineStyle.lineWidth > static_cast<CGFloat>(0.0) ) {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                CGFloat x       = viewPoints[i].x;
                CGFloat y       = viewPoints[i].y;
                CGPoint pos     = CPTAlignPointToUserSpace(context,  CGPointMake( static_cast<CGFloat>(x), static_cast<CGFloat>(y)) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;
            }
        });
    }
    else {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                CGFloat x       = viewPoints[i].x;
                CGFloat y       = viewPoints[i].y;
                CGPoint pos     = CPTAlignIntegralPointToUserSpace(context, CGPointMake( static_cast<CGFloat>(x), static_cast<CGFloat>(y)) );
                viewPoints[i].x = pos.x;
                viewPoints[i].y = pos.y;
            }
        });
    }
}

-(NSInteger)extremeDrawnPointIndexForFlags:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound {
    NSInteger result = NSNotFound;
    NSInteger delta  = (isLowerBound ? 1 : -1);

    if ( dataCount > 0 ) {
        NSUInteger initialIndex = (isLowerBound ? 0 : dataCount - 1);
        for ( NSInteger i = static_cast<NSInteger>(initialIndex); i < static_cast<NSInteger>(dataCount); i += delta ) {
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
    
    // Contour line styles
    [self reloadContourLineStylesInIsoCurveIndexRange:NSMakeRange(0, self.isoCurvesValues.count)];
    
    // Labels for each isocurve
    [self reloadContourLabelsInIsoCurveIndexRange:NSMakeRange(0, self.isoCurvesValues.count)];
}

-(void)reloadPlotDataInIndexRange:(NSRange)indexRange {
    [super reloadPlotDataInIndexRange:indexRange];

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:indexRange] ) {
        id<CPTContourPlotDataSource> theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.dataSource);

        if ( theDataSource ) {
            id newXValues = [self numbersFromDataSourceForField:CPTContourPlotFieldX recordIndexRange:indexRange];
            [self cacheNumbers:newXValues forField:CPTContourPlotFieldX atRecordIndex:indexRange.location];
            id newYValues = [self numbersFromDataSourceForField:CPTContourPlotFieldY recordIndexRange:indexRange];
            [self cacheNumbers:newYValues forField:CPTContourPlotFieldY atRecordIndex:indexRange.location];
            id newFunctionValues = [self numbersFromDataSourceForField:CPTContourPlotFieldFunctionValue recordIndexRange:indexRange];
            [self cacheNumbers:newFunctionValues forField:CPTContourPlotFieldFunctionValue atRecordIndex:indexRange.location];
        }
//        else {
//            self.xValues     = nil;
//            self.yValues     = nil;
//            self.functionValues  = nil;
//        }
    }
}

/// @endcond


/**
 *  @brief Reload all contour styles from the data source immediately.
 **/
-(void)reloadContourLineStyles {
    [self reloadContourLineStylesInIsoCurveIndexRange:NSMakeRange(0, self.noIsoCurves)];
}

/** @brief Reload contour line styles in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadContourLineStylesInIsoCurveIndexRange:(NSRange)indexRange {
    id<CPTContourPlotDataSource> theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.dataSource);
    
    if ([theDataSource isKindOfClass:[CPTFieldFunctionDataSource class]]) {
        theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.contourAppearanceDataSource);
    }

    BOOL needsLegendUpdate = NO;

    if ( [theDataSource respondsToSelector:@selector(lineStylesForContourPlot:isoCurveIndexRange:)] ) {
        needsLegendUpdate = YES;

        id nilObject                    = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);
        
        CPTLineStyleArray *dataSourceLineStyles = [theDataSource lineStylesForContourPlot:self isoCurveIndexRange:indexRange];
        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTMutableLineStyle *dataSourceLineStyle = [CPTMutableLineStyle lineStyleWithStyle: [dataSourceLineStyles objectAtIndex:idx]];
            if ( dataSourceLineStyle ) {
                [self.isoCurvesLineStyles replaceObjectAtIndex:idx withObject:dataSourceLineStyle];
            }
            else {
                [self.isoCurvesLineStyles replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }
    else if ( [theDataSource respondsToSelector:@selector(lineStyleForContourPlot:isoCurveIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject                    = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTMutableLineStyle *dataSourceLineStyle = [CPTMutableLineStyle lineStyleWithStyle: [theDataSource lineStyleForContourPlot:self isoCurveIndex:idx]];
            if ( dataSourceLineStyle ) {
                [self.isoCurvesLineStyles replaceObjectAtIndex:idx withObject:dataSourceLineStyle];
            }
            else {
                [self.isoCurvesLineStyles replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }

    // Legend
    if ( needsLegendUpdate ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }

    [self setNeedsDisplay];
}

/**
 *  @brief Reload all fills  from the data source immediately.
 **/
-(void)reloadContourFills {
    [self reloadContourFillsInIsoCurveIndexRange:NSMakeRange(0, self.noIsoCurves)];
}

/** @brief Reload contour fill in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadContourFillsInIsoCurveIndexRange:(NSRange)indexRange {
    id<CPTContourPlotDataSource> theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.dataSource);
    
    if ([theDataSource isKindOfClass:[CPTFieldFunctionDataSource class]]) {
        theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.contourAppearanceDataSource);
    }

    if ( [theDataSource respondsToSelector:@selector(fillsForContourPlot:isoCurveIndexRange:)] ) {

        id nilObject                    = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);
        
        CPTFillArray *dataSourceFills = [theDataSource fillsForContourPlot:self isoCurveIndexRange:indexRange];
        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTFill *dataSourceFill = [dataSourceFills objectAtIndex:idx];
            if ( dataSourceFill ) {
                [self.isoCurvesFills replaceObjectAtIndex:idx withObject:dataSourceFill];
            }
            else {
                [self.isoCurvesFills replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }
    else if ( [theDataSource respondsToSelector:@selector(fillForContourPlot:isoCurveIndex:)] ) {

        id nilObject                    = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTFill *dataSourceFill = [theDataSource fillForContourPlot:self isoCurveIndex:idx];
            if ( dataSourceFill ) {
                [self.isoCurvesFills replaceObjectAtIndex:idx withObject:dataSourceFill];
            }
            else {
                [self.isoCurvesFills replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }

    [self setNeedsDisplay];
}


/**
 *  @brief Reload all data labels from the data source immediately.
 **/
-(void)reloadContourLabels
{
    [self reloadContourLabelsInIsoCurveIndexRange:NSMakeRange(0, self.isoCurvesValues.count)];
}

/**
 *  @brief Reload all IsoCurve labels in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadContourLabelsInIsoCurveIndexRange:(NSRange)indexRange
{
    if (self.isoCurvesValues == nil) {
        return;
    }
    id<CPTContourPlotDataSource> theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.dataSource);
    
    if ([theDataSource isKindOfClass:[CPTFieldFunctionDataSource class]]) {
        theDataSource = static_cast<id<CPTContourPlotDataSource>>(self.contourAppearanceDataSource);
    }

    if ( [theDataSource respondsToSelector:@selector(isoCurveLabelsForPlot:isoCurveIndexRange:)] ) {
        
        id nilObject                    = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);
        
        CPTLayerArray *dataSourceLabels = [theDataSource isoCurveLabelsForPlot:self isoCurveIndexRange:indexRange];
        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLayer *labelLayer = [dataSourceLabels objectAtIndex:idx];
            if ( labelLayer ) {
                [self.isoCurvesLabels replaceObjectAtIndex:idx withObject:labelLayer];
            }
            else {
                [self.isoCurvesLabels replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }
    else if ( [theDataSource respondsToSelector:@selector(isoCurveLabelForPlot:isoCurveIndex:)] ) {
        id nilObject                = [CPTPlot nilData];
        NSUInteger maxIndex             = NSMaxRange(indexRange);
        
        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTLayer *labelLayer = [theDataSource isoCurveLabelForPlot:self isoCurveIndex:idx];
            if ( labelLayer ) {
                [self.isoCurvesLabels replaceObjectAtIndex:idx withObject:labelLayer];
            }
            else {
                [self.isoCurvesLabels replaceObjectAtIndex:idx withObject:nilObject];
            }
        }
    }

    [self relabelIsoCurvesIndexRange:indexRange];
}


#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(nonnull CGContextRef)context {
    if ( self.hidden ) {
        return;
    }

    CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTContourPlotFieldX];
    CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTContourPlotFieldY];

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
    CGPoint *viewPoints = static_cast<CGPoint*>(calloc(dataCount, sizeof(CGPoint) ));
    BOOL *drawPointFlags     = static_cast<BOOL*>(calloc(dataCount, sizeof(BOOL) ));

    CPTXYPlotSpace *thePlotSpace = static_cast<CPTXYPlotSpace *>(self.plotSpace);
    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    // Get extreme points
    NSInteger lastDrawnPointIndex  = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:NO];
    NSInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];

    if ( firstDrawnPointIndex != NSNotFound && lastDrawnPointIndex != NSNotFound ) {
        
        BOOL pixelAlign = self.alignsPointsToPixels;
        
        if ( self.dataSourceBlock == nil ) {
            CPTFieldFunctionDataSource *contourFunctionDataSource = static_cast<CPTFieldFunctionDataSource*>(self.dataSource);
            self.dataSourceBlock = contourFunctionDataSource.dataSourceBlock;
        }
        
        // here we are going to generate contour planes based on max/min FunctionValue
        // then go through each plane and plot the points
        double _adjustedMinFunctionValue = lrint(floor(self.minFunctionValue));
        double _adjustedMaxFunctionValue = lrint(ceil(self.maxFunctionValue));
        double step = (_adjustedMaxFunctionValue - _adjustedMinFunctionValue) / static_cast<double>(self.noIsoCurves - 1 < 2 ? 1 : self.noIsoCurves - 1);
        
        double *planesValues = static_cast<double*>(calloc(self.noIsoCurves, sizeof(double)));
        for (NSUInteger iPlane = 0; iPlane < self.noIsoCurves; iPlane++) {
            planesValues[iPlane] = _adjustedMinFunctionValue + static_cast<double>(iPlane) * step;
        }
        
        double limit0, limit1;
        if (thePlotSpace.xRange.lengthDouble > thePlotSpace.yRange.lengthDouble) {
            if ([self.limits[0] doubleValue] == -DBL_MAX && [self.limits[1] doubleValue] == DBL_MAX) {
                limit0 = [thePlotSpace.xRange.location doubleValue];
                limit1 = [thePlotSpace.xRange.end doubleValue];
            }
            else {
                limit0 = [self.limits[0] doubleValue];
                limit1 = [self.limits[1] doubleValue];
            }
        }
        else {
            if ([self.limits[2] doubleValue] == -DBL_MAX && [self.limits[3] doubleValue] == DBL_MAX) {
                limit0 = [thePlotSpace.yRange.location doubleValue];
                limit1 = [thePlotSpace.yRange.end doubleValue];
            }
            else {
                limit0 = [self.limits[2] doubleValue];
                limit1 = [self.limits[3] doubleValue];
            }
        }
        double _limits[4] = { limit0 * 1.01, limit1 * 1.01, limit0 * 1.01, limit1 * 1.01 };
        COREPLOT_CONTOURS::CContours *contours = new COREPLOT_CONTOURS::CContours(static_cast<const int>(self.noIsoCurves), planesValues, static_cast<double*>(_limits));
        contours->setFieldBlock(self.dataSourceBlock);
        contours->generate();
        
        // draw line strips
        COREPLOT_CONTOURS::CLineStripList* pStripList;
        COREPLOT_CONTOURS::CLineStrip* pStrip;
        unsigned int index;
        COREPLOT_CONTOURS::CLineStripList::iterator pos;
        COREPLOT_CONTOURS::CLineStrip::iterator pos2;
        double x, y;
        CGPoint point;
        ContourPoints stripContours;
        initContourPoints(&stripContours, 50);
        
        self.scaleX = CPTDecimalDoubleValue(self.plotArea.widthDecimal) / thePlotSpace.xRange.lengthDouble;
        self.scaleY = CPTDecimalDoubleValue(self.plotArea.heightDecimal) / thePlotSpace.yRange.lengthDouble;
        self.maxWidthPixels = CPTDecimalDoubleValue(self.plotArea.widthDecimal);
        self.maxHeightPixels = CPTDecimalDoubleValue(self.plotArea.heightDecimal);
        
//        if(self.isoCurvesValues == nil) {
            self.isoCurvesLineStyles = [[CPTMutableLineStyleArray alloc] init];
            for(NSUInteger i = 0; i < self.noIsoCurves; i++) {
                CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyleWithStyle: self.isoCurveLineStyle];
                [self.isoCurvesLineStyles addObject: lineStyle];
            }
            self.isoCurvesFills = [[CPTMutableFillArray alloc] init];
            for(NSUInteger i = 0; i < self.noIsoCurves; i++) {
                id nilObject                    = [CPTPlot nilData];
                [self.isoCurvesFills addObject: nilObject];
            }
            
            self.isoCurvesLabels = [[CPTMutableLayerArray alloc] init];
            for(NSUInteger i = 0; i < self.noIsoCurves; i++) {
                id nilObject                    = [CPTPlot nilData];
                [self.isoCurvesLabels addObject: nilObject];
            }
            self.needsIsoCurvesRelabel = YES;
            
            self.isoCurvesValues = [CPTMutableNumberArray arrayWithCapacity:self.noIsoCurves];
            self.isoCurvesNoStrips = [CPTMutableNumberArray arrayWithCapacity:self.noIsoCurves];
            self.isoCurvesLabelsPositions = static_cast<NSMutableArray<CPTMutableValueArray*>*>([NSMutableArray arrayWithCapacity:self.noIsoCurves]);
            for ( unsigned int iPlane = 0; iPlane < contours->getNPlanes(); iPlane++ ) {
                pStripList = contours->getListContour()->GetLines(iPlane);
                if (pStripList->size() != 0) {
                    NSNumber *isoCurveValue = [NSNumber numberWithDouble: contours->getPlane(iPlane)];
                    [self.isoCurvesValues addObject:isoCurveValue];
                    
                    CPTMutableValueArray *positionsPerStrip = [CPTMutableValueArray arrayWithCapacity:pStripList->size()];
                    for (pos=pStripList->begin(); pos != pStripList->end() ; pos++) {
                        pStrip = (*pos);
                        pos2 = next(pStrip->begin(), pStrip->size() / 2);
                        index=(*pos2); // retreiving index
                        x = contours->getListContour()->GetXi(static_cast<int>(index));
                        y = contours->getListContour()->GetYi(static_cast<int>(index));
                        point = CGPointMake(x, y);
#if TARGET_OS_OSX
                        NSValue *positionValue = [NSValue valueWithPoint:point];
#else
                        NSValue *positionValue = [NSValue valueWithCGPoint:point];
#endif
//                        if (x >= limit0 && x <= limit1 && y >= limit0 && y <= limit1) {
                            [positionsPerStrip addObject:positionValue];
//                        }
                    }
                    if (positionsPerStrip.count > 0) {
                        NSNumber *isoCurveNoStrips = [NSNumber numberWithDouble: positionsPerStrip.count];
                        [self.isoCurvesNoStrips addObject:isoCurveNoStrips];
                        [self.isoCurvesLabelsPositions addObject:positionsPerStrip];
                    }
                }
            }
//        }
        [self reloadContourLineStyles];
        [self reloadContourFills];
        [self reloadContourLabels];
        
        CGPathRef previousDataLinePath = NULL; // used for filling
        CGPathRef dataLinePath = NULL;
        for ( unsigned int iPlane = 0; iPlane < contours->getNPlanes(); iPlane++ ) {
//            contours->dumpPlane(iPlane);
            CPTMutableLineStyle *theContourLineStyle = [CPTMutableLineStyle lineStyleWithStyle: [self isoCurveLineStyleForIndex:iPlane]];
            if(theContourLineStyle == nil) {
                theContourLineStyle          = [self.isoCurveLineStyle mutableCopy];
                theContourLineStyle.lineColor = [CPTColor colorWithComponentRed:static_cast<CGFloat>(static_cast<float>(iPlane) / static_cast<float>(contours->getNPlanes())) green:static_cast<CGFloat>(1.0f - static_cast<float>(iPlane) / static_cast<float>(contours->getNPlanes())) blue:0.0 alpha:1.0];
            }
            theContourLineStyle.lineWidth = self.isoCurveLineStyle.lineWidth;
            
//            CPTFill *theFill = [self.isoCurvesFills objectAtIndex:iPlane];
            
            pStripList = contours->getListContour()->GetLines(iPlane);
//            NSAssertParameter(pStripList);
            for (pos=pStripList->begin(); pos != pStripList->end() ; pos++) {
                pStrip = (*pos);
//                NSAssertParameter(pStrip);
                if (pStrip->empty()) {
                    continue;
                }
                
                for (pos2=pStrip->begin(); pos2 != pStrip->end() ; pos2++) {
                    // retreiving index
                    index=(*pos2);
                    // drawing
                    x = contours->getListContour()->GetXi(static_cast<int>(index));
                    y = contours->getListContour()->GetYi(static_cast<int>(index));
//                    if (x >= limit0 && x <= limit1 && y >= limit0 && y <= limit1) {
                        point = CGPointMake((x - thePlotSpace.xRange.locationDouble) * self.scaleX, (y - thePlotSpace.yRange.locationDouble) * self.scaleY);
                        insertContourPoints(&stripContours, point);
//                    }
                }

                if ( pixelAlign ) {
                    [self alignViewPointsToUserSpace:stripContours.array withContext:context drawPointFlags:drawPointFlags numberOfPoints:stripContours.used];
                }

                if ( stripContours.used > 0 ) {
                    dataLinePath = [self newDataLinePathForViewPoints:stripContours.array indexRange: NSMakeRange(0, stripContours.used)];
                }
                
//                if ( theFill && previousDataLinePath != NULL ) {
//                    CGContextSaveGState(context);
//
//                    CGContextBeginPath(context);
//                    CGContextAddPath(context, previousDataLinePath);
//                    CGContextAddPath(context, dataLinePath);
//                    [theFill fillPathInContext:context];
//
//                    CGContextRestoreGState(context);
//                }
//
//                if (theFill) {
//                    CGPathRelease(previousDataLinePath);
//                    previousDataLinePath = CGPathCreateCopy(dataLinePath);
//                }
                
                // Draw line
                if ( theContourLineStyle && dataLinePath != NULL ) {
                    
                    CGContextBeginPath(context);
                    CGContextAddPath(context, dataLinePath);
                    [theContourLineStyle setLineStyleInContext:context];
                    [theContourLineStyle strokePathInContext:context];
                }
                CGPathRelease(dataLinePath);
                dataLinePath = NULL;
                clearContourPoints(&stripContours);
            }
        }
        freeContourPoints(&stripContours);
        if (previousDataLinePath != NULL) {
            CGPathRelease(previousDataLinePath);
            previousDataLinePath = NULL;
        }
            
        
        if(contours != NULL) {
            delete contours;
            contours = NULL;
        }
        free(planesValues);
    }

    free(viewPoints);
    free(drawPointFlags);
}

-(nonnull CGPathRef)newDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange {

    CPTContourPlotInterpolation theInterpolation = self.interpolation;

    if ( theInterpolation == CPTContourPlotInterpolationCurved ) {
        return [self newCurvedDataLinePathForViewPoints:viewPoints indexRange:indexRange];
    }
    
    CPTFieldFunctionDataSource *contourFunctionDataSource = static_cast<CPTFieldFunctionDataSource*>(self.dataSource);
    CGFloat deltaXLimit = static_cast<CGFloat>(self.maxWidthPixels / static_cast<double>([contourFunctionDataSource getDataXCount])) * 2.0;
    CGFloat deltaYLimit = static_cast<CGFloat>(self.maxHeightPixels / static_cast<double>([contourFunctionDataSource getDataYCount])) * 2.0;
    
    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    
    CGPoint lastPoint = viewPoints[indexRange.location];
    CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
    for ( NSUInteger i = indexRange.location + 1; i <= NSMaxRange(indexRange); i++ ) {
        
        CGPoint viewPoint = viewPoints[i];
        if( CGPointEqualToPoint(viewPoint, lastPoint) ) {
            ;
        }
        else if (fabs(lastPoint.x - viewPoint.x) > deltaXLimit || fabs(lastPoint.y - viewPoint.y) > deltaYLimit) {
            CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
        }
        else {
            CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
        }
        lastPoint = viewPoint;
    }

    return dataLinePath;
}

-(nonnull CGPathRef)newCurvedDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange {
    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    BOOL lastPointSkipped          = YES;
    CGPoint firstPoint             = CGPointZero;
    CGPoint lastPoint              = CGPointZero;
    NSUInteger firstIndex          = indexRange.location;
    NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);

    CPTContourPlotCurvedInterpolationOption interpolationOption = self.curvedInterpolationOption;

    if ( lastDrawnPointIndex > 0 ) {
        CGPoint *controlPoints1 = static_cast<CGPoint*>(calloc(lastDrawnPointIndex, sizeof(CGPoint) ));
        CGPoint *controlPoints2 = static_cast<CGPoint*>(calloc(lastDrawnPointIndex, sizeof(CGPoint) ));

        lastDrawnPointIndex--;

        // Compute control points for each sub-range
        for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
            CGPoint viewPoint = viewPoints[i];

            if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
                if ( !lastPointSkipped ) {
                    switch ( interpolationOption ) {
                        case CPTContourPlotCurvedInterpolationNormal:
                            [self computeBezierControlPoints:controlPoints1
                                                     points2:controlPoints2
                                               forViewPoints:viewPoints
                                                  indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTContourPlotCurvedInterpolationCatmullRomUniform:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:static_cast<CGFloat>(0.0)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTContourPlotCurvedInterpolationCatmullRomCentripetal:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:static_cast<CGFloat>(0.5)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTContourPlotCurvedInterpolationCatmullRomChordal:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:static_cast<CGFloat>(1.0)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];

                            break;

                        case CPTContourPlotCurvedInterpolationHermiteCubic:
                            [self computeHermiteControlPoints:controlPoints1
                                                      points2:controlPoints2
                                                forViewPoints:viewPoints
                                                   indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTContourPlotCurvedInterpolationCatmullCustomAlpha:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:self.curvedInterpolationCustomAlpha
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;
                    }

                    lastPointSkipped = YES;
                }
            }
            else {
                if ( lastPointSkipped ) {
                    lastPointSkipped = NO;
                    firstIndex       = i;
                }
            }
        }

        if ( !lastPointSkipped ) {
            switch ( interpolationOption ) {
                case CPTContourPlotCurvedInterpolationNormal:
                    [self computeBezierControlPoints:controlPoints1
                                             points2:controlPoints2
                                       forViewPoints:viewPoints
                                          indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTContourPlotCurvedInterpolationCatmullRomUniform:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:static_cast<CGFloat>(0.0)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];

                    break;

                case CPTContourPlotCurvedInterpolationCatmullRomCentripetal:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:static_cast<CGFloat>(0.5)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTContourPlotCurvedInterpolationCatmullRomChordal:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:static_cast<CGFloat>(1.0)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];

                    break;

                case CPTContourPlotCurvedInterpolationHermiteCubic:
                    [self computeHermiteControlPoints:controlPoints1
                                              points2:controlPoints2
                                        forViewPoints:viewPoints
                                           indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTContourPlotCurvedInterpolationCatmullCustomAlpha:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:self.curvedInterpolationCustomAlpha
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;
            }
        }

        // Build the path
        lastPointSkipped = YES;
        for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
            CGPoint viewPoint = viewPoints[i];

            if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
                if ( !lastPointSkipped ) {
                    lastPointSkipped = YES;
                }
            }
            else {
                if ( lastPointSkipped ) {
                    CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                    lastPointSkipped = NO;
                    firstPoint       = viewPoint;
                }
                else {
                    CGPoint cp1 = controlPoints1[i];
                    CGPoint cp2 = controlPoints2[i];

#ifdef DEBUG_CURVES
                    CGPoint currentPoint = CGPathGetCurrentPoint(dataLinePath);

                    // add the control points
                    CGPathMoveToPoint(dataLinePath, NULL, cp1.x - CPTFloat(5.0), cp1.y);
                    CGPathAddLineToPoint(dataLinePath, NULL, cp1.x + CPTFloat(5.0), cp1.y);
                    CGPathMoveToPoint(dataLinePath, NULL, cp1.x, cp1.y - CPTFloat(5.0) );
                    CGPathAddLineToPoint(dataLinePath, NULL, cp1.x, cp1.y + CPTFloat(5.0) );

                    CGPathMoveToPoint(dataLinePath, NULL, cp2.x - CPTFloat(3.5), cp2.y - CPTFloat(3.5) );
                    CGPathAddLineToPoint(dataLinePath, NULL, cp2.x + CPTFloat(3.5), cp2.y + CPTFloat(3.5) );
                    CGPathMoveToPoint(dataLinePath, NULL, cp2.x + CPTFloat(3.5), cp2.y - CPTFloat(3.5) );
                    CGPathAddLineToPoint(dataLinePath, NULL, cp2.x - CPTFloat(3.5), cp2.y + CPTFloat(3.5) );

                    // add a line connecting the control points
                    CGPathMoveToPoint(dataLinePath, NULL, cp1.x, cp1.y);
                    CGPathAddLineToPoint(dataLinePath, NULL, cp2.x, cp2.y);

                    CGPathMoveToPoint(dataLinePath, NULL, currentPoint.x, currentPoint.y);
#endif

                    CGPathAddCurveToPoint(dataLinePath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, viewPoint.x, viewPoint.y);
                }
                lastPoint = viewPoint;
            }
        }

        free(controlPoints1);
        free(controlPoints2);
    }

    return dataLinePath;
}

/** @brief Compute the control points using a catmull-rom spline.
 *  @param points A pointer to the array which should hold the first control points.
 *  @param points2 A pointer to the array which should hold the second control points.
 *  @param alpha The alpha value used for the catmull-rom interpolation.
 *  @param viewPoints A pointer to the array which holds all view points for which the interpolation should be calculated.
 *  @param indexRange The range in which the interpolation should occur.
 *  @warning The @par{indexRange} must be valid for all passed arrays otherwise this method crashes.
 **/
-(void)computeCatmullRomControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 withAlpha:(CGFloat)alpha forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange {
    if ( indexRange.length >= 2 ) {
        NSUInteger startIndex   = indexRange.location;
        NSUInteger endIndex     = NSMaxRange(indexRange) - 1; // the index starts at zero
        NSUInteger segmentCount = endIndex - 1;               // there are n - 1 segments

        CGFloat epsilon = static_cast<CGFloat>(1.0e-5); // the minimum point distance. below that no interpolation happens.

        for ( NSUInteger index = startIndex; index <= segmentCount; index++ ) {
            // calculate the control for the segment from index -> index + 1
            CGPoint p0, p1, p2, p3; // the view point

            // the internal points are always valid
            p1 = viewPoints[index];
            p2 = viewPoints[index + 1];
            // account for first and last segment
            if ( index == startIndex ) {
                p0 = p1;
            }
            else {
                p0 = viewPoints[index - 1];
            }
            if ( index == segmentCount ) {
                p3 = p2;
            }
            else {
                p3 = viewPoints[index + 2];
            }

            // distance between the points
            CGFloat d1 = hypot(p1.x - p0.x, p1.y - p0.y);
            CGFloat d2 = hypot(p2.x - p1.x, p2.y - p1.y);
            CGFloat d3 = hypot(p3.x - p2.x, p3.y - p2.y);
            // constants
            CGFloat d1_a  = pow(d1, alpha);            // d1^alpha
            CGFloat d2_a  = pow(d2, alpha);            // d2^alpha
            CGFloat d3_a  = pow(d3, alpha);            // d3^alpha
            CGFloat d1_2a = pow(d1_a, static_cast<CGFloat>(2.0) ); // d1^alpha^2 = d1^2*alpha
            CGFloat d2_2a = pow(d2_a, static_cast<CGFloat>(2.0) ); // d2^alpha^2 = d2^2*alpha
            CGFloat d3_2a = pow(d3_a, static_cast<CGFloat>(2.0) ); // d3^alpha^2 = d3^2*alpha

            // calculate the control points
            // see : http://www.cemyuksel.com/research/catmullrom_param/catmullrom.pdf under point 3.
            CGPoint cp1, cp2; // the calculated view points;
            if ( fabs(d1) <= epsilon ) {
                cp1 = p1;
            }
            else {
                CGFloat divisor = static_cast<CGFloat>(3.0) * d1_a * (d1_a + d2_a);
                cp1 = CGPointMake( static_cast<CGFloat>((p2.x * d1_2a - p0.x * d2_2a + (2 * d1_2a + 3 * d1_a * d2_a + d2_2a) * p1.x) / divisor),
                                  static_cast<CGFloat>((p2.y * d1_2a - p0.y * d2_2a + (2 * d1_2a + 3 * d1_a * d2_a + d2_2a) * p1.y) / divisor)
                                     );
            }

            if ( fabs(d3) <= epsilon ) {
                cp2 = p2;
            }
            else {
                CGFloat divisor = 3 * d3_a * (d3_a + d2_a);
                cp2 = CGPointMake( static_cast<CGFloat>((d3_2a * p1.x - d2_2a * p3.x + (2 * d3_2a + 3 * d3_a * d2_a + d2_2a) * p2.x) / divisor),
                                  static_cast<CGFloat>((d3_2a * p1.y - d2_2a * p3.y + (2 * d3_2a + 3 * d3_a * d2_a + d2_2a) * p2.y) / divisor ));
            }

            points[index + 1]  = cp1;
            points2[index + 1] = cp2;
        }
    }
}

/** @brief Compute the control points using a hermite cubic spline.
 *
 *  If the view points are monotonically increasing or decreasing in both @par{x} and @par{y},
 *  the smoothed curve will be also.
 *
 *  @param points A pointer to the array which should hold the first control points.
 *  @param points2 A pointer to the array which should hold the second control points.
 *  @param viewPoints A pointer to the array which holds all view points for which the interpolation should be calculated.
 *  @param indexRange The range in which the interpolation should occur.
 *  @warning The @par{indexRange} must be valid for all passed arrays otherwise this method crashes.
 **/
-(void)computeHermiteControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange {
    // See https://en.wikipedia.org/wiki/Cubic_Hermite_spline and https://en.m.wikipedia.org/wiki/Monotone_cubic_interpolation for a discussion of algorithms used.
    if ( indexRange.length >= 2 ) {
        NSUInteger startIndex = indexRange.location;
        NSUInteger lastIndex  = NSMaxRange(indexRange) - 1; // last accessible element in view points

        BOOL monotonic = [self monotonicViewPoints:viewPoints indexRange:indexRange];

        for ( NSUInteger index = startIndex; index <= lastIndex; index++ ) {
            CGVector m;
            CGPoint p1 = viewPoints[index];

            if ( index == startIndex ) {
                CGPoint p2 = viewPoints[index + 1];

                m.dx = p2.x - p1.x;
                m.dy = p2.y - p1.y;
            }
            else if ( index == lastIndex ) {
                CGPoint p0 = viewPoints[index - 1];

                m.dx = p1.x - p0.x;
                m.dy = p1.y - p0.y;
            }
            else { // index > startIndex && index < numberOfPoints
                CGPoint p0 = viewPoints[index - 1];
                CGPoint p2 = viewPoints[index + 1];

                m.dx = p2.x - p0.x;
                m.dy = p2.y - p0.y;

                if ( monotonic ) {
                    if ( m.dx > 0.0 ) {
                        m.dx = MIN(p2.x - p1.x, p1.x - p0.x);
                    }
                    else if ( m.dx < 0.0 ) {
                        m.dx = MAX(p2.x - p1.x, p1.x - p0.x);
                    }

                    if ( m.dy > 0.0 ) {
                        m.dy = MIN(p2.y - p1.y, p1.y - p0.y);
                    }
                    else if ( m.dy < 0.0 ) {
                        m.dy = MAX(p2.y - p1.y, p1.y - p0.y);
                    }
                }
            }

            // get control points
            m.dx /= static_cast<CGFloat>(6.0);
            m.dy /= static_cast<CGFloat>(6.0);

            CGPoint rhsControlPoint = CGPointMake(static_cast<CGFloat>(p1.x + m.dx), static_cast<CGFloat>(p1.y + m.dy));
            CGPoint lhsControlPoint = CGPointMake(static_cast<CGFloat>(p1.x - m.dx), static_cast<CGFloat>(p1.y - m.dy));

            // We calculated the lhs & rhs control point. The rhs control point is the first control point for the curve to the next point. The lhs control point is the second control point for the curve to the current point.

            points2[index] = lhsControlPoint;
            if ( index + 1 <= lastIndex ) {
                points[index + 1] = rhsControlPoint;
            }
        }
    }
}

/** @brief Determine whether the plot points form a monotonic series.
 *  @param viewPoints A pointer to the array which holds all view points for which the interpolation should be calculated.
 *  @param indexRange The range in which the interpolation should occur.
 *  @return Returns @YES if the viewpoints are monotonically increasing or decreasing in both @par{x} and @par{y}.
 *  @warning The @par{indexRange} must be valid for all passed arrays otherwise this method crashes.
 **/
-(BOOL)monotonicViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange {
    if ( indexRange.length < 2 ) {
        return YES;
    }

    NSUInteger startIndex = indexRange.location;
    NSUInteger lastIndex  = NSMaxRange(indexRange) - 2;

    BOOL foundTrendX   = NO;
    BOOL foundTrendY   = NO;
    BOOL isIncreasingX = NO;
    BOOL isIncreasingY = NO;

    for ( NSUInteger index = startIndex; index <= lastIndex; index++ ) {
        CGPoint p1 = viewPoints[index];
        CGPoint p2 = viewPoints[index + 1];

        if ( !foundTrendX ) {
            if ( p2.x > p1.x ) {
                isIncreasingX = YES;
                foundTrendX   = YES;
            }
            else if ( p2.x < p1.x ) {
                foundTrendX = YES;
            }
        }

        if ( foundTrendX ) {
            if ( isIncreasingX ) {
                if ( p2.x < p1.x ) {
                    return NO;
                }
            }
            else {
                if ( p2.x > p1.x ) {
                    return NO;
                }
            }
        }

        if ( !foundTrendY ) {
            if ( p2.y > p1.y ) {
                isIncreasingY = YES;
                foundTrendY   = YES;
            }
            else if ( p2.y < p1.y ) {
                foundTrendY = YES;
            }
        }

        if ( foundTrendY ) {
            if ( isIncreasingY ) {
                if ( p2.y < p1.y ) {
                    return NO;
                }
            }
            else {
                if ( p2.y > p1.y ) {
                    return NO;
                }
            }
        }
    }

    return YES;
}

// Compute the control points using the algorithm described at http://www.particleincell.com/blog/2012/bezier-splines/
// cp1, cp2, and viewPoints should point to arrays of points with at least NSMaxRange(indexRange) elements each.
-(void)computeBezierControlPoints:(nonnull CGPoint *)cp1 points2:(nonnull CGPoint *)cp2 forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange
{
    if ( indexRange.length == 2 ) {
        NSUInteger rangeEnd = NSMaxRange(indexRange) - 1;
        cp1[rangeEnd] = viewPoints[indexRange.location];
        cp2[rangeEnd] = viewPoints[rangeEnd];
    }
    else if ( indexRange.length > 2 ) {
        NSUInteger n = indexRange.length - 1;

        // rhs vector
        CGPoint *a = static_cast<CGPoint*>(calloc(n, sizeof(CGPoint) ));
        CGPoint *b = static_cast<CGPoint*>(calloc(n, sizeof(CGPoint) ));
        CGPoint *c = static_cast<CGPoint*>(calloc(n, sizeof(CGPoint) ));
        CGPoint *r = static_cast<CGPoint*>(calloc(n, sizeof(CGPoint) ));

        // left most segment
        a[0] = CGPointZero;
        b[0] = CGPointMake(static_cast<CGFloat>(2.0), static_cast<CGFloat>(2.0));
        c[0] = CGPointMake(static_cast<CGFloat>(1.0), static_cast<CGFloat>(1.0));

        CGPoint pt0 = viewPoints[indexRange.location];
        CGPoint pt1 = viewPoints[indexRange.location + 1];
        r[0] = CGPointMake(pt0.x + static_cast<CGFloat>(2.0) * pt1.x,
                           pt0.y + static_cast<CGFloat>(2.0) * pt1.y);

        // internal segments
        for ( NSUInteger i = 1; i < n - 1; i++ ) {
            a[i] = CGPointMake(1.0, 1.0);
            b[i] = CGPointMake(4.0, 4.0);
            c[i] = CGPointMake(1.0, 1.0);

            CGPoint pti  = viewPoints[indexRange.location + i];
            CGPoint pti1 = viewPoints[indexRange.location + i + 1];
            r[i] = CGPointMake(static_cast<CGFloat>(4.0) * pti.x + static_cast<CGFloat>(2.0) * pti1.x,
                               static_cast<CGFloat>(4.0) * pti.y + static_cast<CGFloat>(2.0) * pti1.y);
        }

        // right segment
        a[n - 1] = CGPointMake(2.0, 2.0);
        b[n - 1] = CGPointMake(7.0, 7.0);
        c[n - 1] = CGPointZero;

        CGPoint ptn1 = viewPoints[indexRange.location + n - 1];
        CGPoint ptn  = viewPoints[indexRange.location + n];
        r[n - 1] = CGPointMake(static_cast<CGFloat>(8.0) * ptn1.x + ptn.x,
                               static_cast<CGFloat>(8.0) * ptn1.y + ptn.y);

        // solve Ax=b with the Thomas algorithm (from Wikipedia)
        for ( NSUInteger i = 1; i < n; i++ ) {
            CGPoint m = CGPointMake(a[i].x / b[i - 1].x,
                                    a[i].y / b[i - 1].y);
            b[i] = CGPointMake(b[i].x - m.x * c[i - 1].x,
                               b[i].y - m.y * c[i - 1].y);
            r[i] = CGPointMake(r[i].x - m.x * r[i - 1].x,
                               r[i].y - m.y * r[i - 1].y);
        }

        cp1[indexRange.location + n] = CGPointMake(r[n - 1].x / b[n - 1].x,
                                                   r[n - 1].y / b[n - 1].y);
        for ( NSUInteger i = n - 2; i > 0; i-- ) {
            cp1[indexRange.location + i + 1] = CGPointMake( (r[i].x - c[i].x * cp1[indexRange.location + i + 2].x) / b[i].x,
                                                            (r[i].y - c[i].y * cp1[indexRange.location + i + 2].y) / b[i].y );
        }
        cp1[indexRange.location + 1] = CGPointMake( (r[0].x - c[0].x * cp1[indexRange.location + 2].x) / b[0].x,
                                                    (r[0].y - c[0].y * cp1[indexRange.location + 2].y) / b[0].y );

        // we have p1, now compute p2
        NSUInteger rangeEnd = NSMaxRange(indexRange) - 1;
        for ( NSUInteger i = indexRange.location + 1; i < rangeEnd; i++ ) {
            cp2[i] = CGPointMake(static_cast<CGFloat>(2.0) * viewPoints[i].x - cp1[i + 1].x,
                                 static_cast<CGFloat>(2.0) * viewPoints[i].y - cp1[i + 1].y);
        }

        cp2[rangeEnd] = CGPointMake(static_cast<CGFloat>(0.5) * (viewPoints[rangeEnd].x + cp1[rangeEnd].x),
                                    static_cast<CGFloat>(0.5) * (viewPoints[rangeEnd].y + cp1[rangeEnd].y) );

        // clean up
        free(a);
        free(b);
        free(c);
        free(r);
    }
}



-(void)drawSwatchForLegend:(nonnull CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(nonnull CGContextRef)context {
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    if ( self.drawLegendSwatchDecoration ) {
        
        CPTLineStyle *theContourLineStyle = [self isoCurveLineStyleForIndex:idx];

        if ( theContourLineStyle ) {
            [theContourLineStyle setLineStyleInContext:context];

            CGPoint alignedStartPoint = CPTAlignPointToUserSpace(context, CGPointMake(static_cast<CGFloat>(CGRectGetMinX(rect)), static_cast<CGFloat>(CGRectGetMidY(rect)) ) );
            CGPoint alignedEndPoint   = CPTAlignPointToUserSpace(context, CGPointMake(static_cast<CGFloat>(CGRectGetMaxX(rect)), static_cast<CGFloat>(CGRectGetMidY(rect)) ) );
            CGContextMoveToPoint(context, alignedStartPoint.x, alignedStartPoint.y);
            CGContextAddLineToPoint(context, alignedEndPoint.x, alignedEndPoint.y);

            [theContourLineStyle strokePathInContext:context];
        }
    }
}

-(nonnull CPTLineStyle *)isoCurveLineStyleForIndex:(NSUInteger)idx
{
    CPTLineStyle *theLineStyle = [self.isoCurvesLineStyles objectAtIndex:idx];
    
    if ( (theLineStyle == nil) || (theLineStyle == [CPTPlot nilData]) ) {
        theLineStyle = self.isoCurveLineStyle;
    }

    return theLineStyle;
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

//+(BOOL)needsDisplayForKey:(nonnull NSString *)aKey
//{
//    static NSSet<NSString *> *keys   = nil;
//    static dispatch_once_t onceToken = 0;
//
//    dispatch_once(&onceToken, ^{
//        keys = [NSSet setWithArray:@[@"arrowSize",
//                                     @"arrowType"]];
//    });
//
//    if ( [keys containsObject:aKey] ) {
//        return YES;
//    }
//    else {
//        return [super needsDisplayForKey:aKey];
//    }
//}

/// @endcond

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields {
    return 3;
}

-(nonnull CPTNumberArray *)fieldIdentifiers {
    return @[@(CPTContourPlotFieldX),
             @(CPTContourPlotFieldY),
             @(CPTContourPlotFieldFunctionValue)];
}

-(nonnull CPTNumberArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord {
    CPTNumberArray *result = nil;

    switch ( coord ) {
        case CPTCoordinateX:
            result = @[@(CPTContourPlotFieldX)];
            break;

        case CPTCoordinateY:
            result = @[@(CPTContourPlotFieldY)];
            break;

        default:
            [NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

-(CPTCoordinate)coordinateForFieldIdentifier:(NSUInteger)field {
    CPTCoordinate coordinate = CPTCoordinateNone;

    switch ( field ) {
        case CPTContourPlotFieldX:
            coordinate = CPTCoordinateX;
            break;

        case CPTContourPlotFieldY:
            coordinate = CPTCoordinateY;
            break;

        default:
            break;
    }

    return coordinate;
}

/// @endcond

#pragma mark -
#pragma mark isoCurve Labels

/**
 *  @brief Marks the receiver as needing to update all data labels before the content is next drawn.
 *  @see @link CPTPlot::relabelIndexRange: -relabelIndexRange: @endlink
 **/
-(void)setIsoCurvesNeedsRelabel
{
    self.isoCurvesLabelIndexRange = NSMakeRange(0, self.isoCurvesValues.count);
    self.needsIsoCurvesRelabel    = YES;
}

/**
 *  @brief Updates the iso Curves labels in the labelIndexRange.
 **/
-(void)reLabelIsoCurves
{
    if ( !self.needsIsoCurvesRelabel ) {
        return;
    }

    self.needsIsoCurvesRelabel = NO;

    id nullObject         = [NSNull null];
    Class nullClass       = [NSNull class];
    Class annotationClass = [CPTAnnotation class];

    CPTTextStyle *labelTextStyle = self.isoCurvesLabelTextStyle;
    NSFormatter *labelFormatter  = self.isoCurvesLabelFormatter;
    BOOL plotProvidesLabels          = labelTextStyle && labelFormatter;

    if ( !self.showIsoCurvesLabels || !plotProvidesLabels || self.isoCurvesValues == nil) {
        for ( CPTAnnotationArray *annotations in self.isoCurvesLabelAnnotations ) {
            for ( CPTAnnotation *annotation in annotations ) {
                if ( [annotation isKindOfClass:annotationClass] ) {
                    [self removeAnnotation:annotation];
                }
            }
        }
        self.isoCurvesLabelAnnotations = nil;
        return;
    }

    CPTDictionary *textAttributes = labelTextStyle.attributes;
    BOOL hasAttributedFormatter   = ([labelFormatter attributedStringForObjectValue:[NSDecimalNumber zero]
                                                                  withDefaultAttributes:textAttributes] != nil);

    NSUInteger sampleCount = self.isoCurvesValues.count;
    NSRange indexRange     = self.isoCurvesLabelIndexRange;
    NSUInteger maxIndex    = NSMaxRange(indexRange);

    if ( !self.isoCurvesLabelAnnotations ) {
        self.isoCurvesLabelAnnotations = [NSMutableArray arrayWithCapacity:sampleCount];
    }

    CPTPlotSpace *thePlotSpace            = self.plotSpace;
    CGFloat theRotation                   = self.isoCurvesLabelRotation;
    NSMutableArray *labelAnnotationsArray = self.isoCurvesLabelAnnotations;
    NSUInteger oldLabelCount              = labelAnnotationsArray.count;
    id nilObject                          = [CPTPlot nilData];

    CPTShadow *theShadow                       = self.isoCurvesLabelShadow;

    for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
        NSNumber *dataValue = [self.isoCurvesValues objectAtIndex:i];
        CPTLayer *newLabelLayer;
        if ( isnan([dataValue doubleValue]) ) {
            newLabelLayer = nil;
        }
        else {
            newLabelLayer = [self.isoCurvesLabels objectAtIndex:i];

            if ( ( (newLabelLayer == nil) || (newLabelLayer == nilObject) ) && plotProvidesLabels ) {
                if ( hasAttributedFormatter ) {
                    NSAttributedString *labelString = [labelFormatter attributedStringForObjectValue:dataValue withDefaultAttributes:textAttributes];
                    newLabelLayer = [[CPTTextLayer alloc] initWithAttributedText:labelString];
                }
                else {
                    NSString *labelString = [labelFormatter stringForObjectValue:dataValue];
                    if ( labelTextStyle.color == nil ) {
                        CPTMutableTextStyle *mutLabelTextStyle = [CPTMutableTextStyle textStyleWithStyle: labelTextStyle];
                        mutLabelTextStyle.color = [CPTColor colorWithComponentRed:static_cast<CGFloat>(static_cast<float>(i) / static_cast<float>(self.isoCurvesLabels.count)) green:static_cast<CGFloat>(1.0f - static_cast<float>(i) / static_cast<float>(self.isoCurvesLabels.count)) blue:0.0 alpha:1.0];
                        newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:mutLabelTextStyle];
                    }
                    else {
                        newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:labelTextStyle];
                    }
                }
            }

            if ( [newLabelLayer isKindOfClass:nullClass] || (newLabelLayer == nilObject) ) {
                newLabelLayer = nil;
            }
        }

        newLabelLayer.shadow = theShadow;

        if ( i < oldLabelCount ) {
            for(NSUInteger j = 0; j < [[self.isoCurvesNoStrips objectAtIndex:i] unsignedIntegerValue]; j++) {
                CPTPlotSpaceAnnotation *labelAnnotation = [[labelAnnotationsArray objectAtIndex:i] objectAtIndex:j];
                if ( newLabelLayer ) {
                    if ( [labelAnnotation isKindOfClass:nullClass] ) {
                        labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                        [[labelAnnotationsArray objectAtIndex:i] replaceObjectAtIndex:j withObject:labelAnnotation];
                        [self addAnnotation:labelAnnotation];
                    }
                }
                else {
                    if ( [labelAnnotation isKindOfClass:annotationClass] ) {
                        [[labelAnnotationsArray objectAtIndex:i] replaceObjectAtIndex:j withObject:nullObject];
                        [self removeAnnotation:labelAnnotation];
                    }
                }
            }
        }
        else {
            CPTMutableAnnotationArray *stripAnnotations = [CPTMutableAnnotationArray arrayWithCapacity:[[self.isoCurvesNoStrips objectAtIndex:i] unsignedIntegerValue]];
            [labelAnnotationsArray addObject:stripAnnotations];
            for(NSUInteger j = 0; j < [[self.isoCurvesNoStrips objectAtIndex:i] unsignedIntegerValue]; j++) {
                if ( newLabelLayer ) {
                    CPTPlotSpaceAnnotation *labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                    [[labelAnnotationsArray objectAtIndex:i] addObject:labelAnnotation];
                    [self addAnnotation:labelAnnotation];
                }
                else {
                    [[labelAnnotationsArray objectAtIndex:i] addObject:nullObject];
                }
            }
        }

        if ( newLabelLayer ) {
            for(NSUInteger j = 0; j < [[self.isoCurvesNoStrips objectAtIndex:i] unsignedIntegerValue]; j++) {
                CPTPlotSpaceAnnotation *labelAnnotation = [[labelAnnotationsArray objectAtIndex:i] objectAtIndex:j];
                labelAnnotation.contentLayer = newLabelLayer;
                labelAnnotation.rotation     = theRotation;
                [self positionIsoCurvesLabelAnnotation:labelAnnotation forStrip:i forIndex:j];
                [self updateContentAnchorForLabel:labelAnnotation];
            }
        }
    }

    // remove labels that are no longer needed
    while ( labelAnnotationsArray.count > sampleCount ) {
        CPTMutableAnnotationArray *oldAnnotations = labelAnnotationsArray[labelAnnotationsArray.count - 1];
        for(NSUInteger j = 0; j < [[self.isoCurvesNoStrips objectAtIndex:labelAnnotationsArray.count - 1] unsignedIntegerValue]; j++) {
            CPTAnnotation *oldAnnotation = oldAnnotations[j];
            if ( [oldAnnotation isKindOfClass:annotationClass] ) {
                [self removeAnnotation:oldAnnotation];
            }
            [oldAnnotations removeObject:oldAnnotation];
        }
        [labelAnnotationsArray removeLastObject];
    }
}

/** @brief Marks the receiver as needing to update a range of isCurves labels before the content is next drawn.
 *  @param indexRange The index range needing update.
 *  @see setNeedsRelabel()
 **/
-(void)relabelIsoCurvesIndexRange:(NSRange)indexRange
{
    self.isoCurvesLabelIndexRange = indexRange;
    self.needsIsoCurvesRelabel = YES;
}

/// @cond

-(void)updateContentAnchorForLabel:(nonnull CPTPlotSpaceAnnotation *)label
{
    if ( label && self.adjustLabelAnchors ) {
        CGPoint displacement = label.displacement;
        if ( CGPointEqualToPoint(displacement, CGPointZero) ) {
            displacement.y = static_cast<CGFloat>(1.0); // put the label above the data point if zero displacement
        }
        CGFloat angle      = static_cast<CGFloat>(M_PI) + atan2(displacement.y, displacement.x) - label.rotation;
        CGFloat newAnchorX = cos(angle);
        CGFloat newAnchorY = sin(angle);

        if ( ABS(newAnchorX) <= ABS(newAnchorY) ) {
            newAnchorX /= ABS(newAnchorY);
            newAnchorY  = signbit(newAnchorY) ? static_cast<CGFloat>(-1.0) : static_cast<CGFloat>(1.0);
        }
        else {
            newAnchorY /= ABS(newAnchorX);
            newAnchorX  = signbit(newAnchorX) ? static_cast<CGFloat>(-1.0) : static_cast<CGFloat>(1.0);
        }

        label.contentAnchorPoint = CGPointMake( (newAnchorX + static_cast<CGFloat>(1.0) ) / static_cast<CGFloat>(2.0), (newAnchorY + static_cast<CGFloat>(1.0) ) / static_cast<CGFloat>(2.0) );
    }
}

/// @endcond

/// @cond


-(void)positionLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx {
    NSNumber *xValue = [self cachedNumberForField:CPTContourPlotFieldX recordIndex:idx];
    NSNumber *yValue = [self cachedNumberForField:CPTContourPlotFieldY recordIndex:idx];

    BOOL positiveDirection = YES;
    CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

    if ( CPTDecimalLessThan(yRange.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
        positiveDirection = !positiveDirection;
    }

    label.anchorPlotPoint     = @[xValue, yValue];
    label.contentLayer.hidden = self.hidden || isnan([xValue doubleValue]) || isnan([yValue doubleValue]);

    if ( positiveDirection ) {
        label.displacement = CGPointMake(0.0, static_cast<CGFloat>(self.labelOffset));
    }
    else {
        label.displacement = CGPointMake(0.0, static_cast<CGFloat>(-self.labelOffset));
    }
}

-(void)positionIsoCurvesLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forStrip:(NSUInteger)strip forIndex:(NSUInteger)idx {
    
    if( self.isoCurvesLabelsPositions != nil) {
        NSValue *positionValue = [[self.isoCurvesLabelsPositions objectAtIndex:strip] objectAtIndex:idx];
#if TARGET_OS_OSX
        CGPoint position = [positionValue pointValue];
#else
        CGPoint position = [positionValue CGPointValue];
#endif
        label.anchorPlotPoint     = @[[NSNumber numberWithDouble: position.x], [NSNumber numberWithDouble: position.y]];
        label.contentLayer.hidden = self.hidden || isnan(position.x) || isnan( position.y);

        label.displacement = CGPointMake(0.0, 0.0);
        label.contentAnchorPoint = CGPointMake(0.0, 0.0);
    }
}


/// @endcond

#pragma mark -
#pragma mark Responder Chain and User Interaction

/// @cond

-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point {
    NSUInteger dataCount     = self.cachedDataCount;
    CGPoint *viewPoints     = static_cast<CGPoint*>(calloc(dataCount, sizeof(CGPoint) ));
    BOOL *drawPointFlags     = static_cast<BOOL*>(calloc(dataCount, sizeof(BOOL) ));

    [self calculatePointsToDraw:drawPointFlags numberOfPoints:dataCount forPlotSpace:static_cast<id>(self.plotSpace) includeVisiblePointsOnly:YES];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    NSInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];
    if ( result != NSNotFound ) {
        CGPoint lastViewPoint;
        CGFloat minimumDistanceSquared = static_cast<CGFloat>(NAN);
        for ( NSUInteger i = static_cast<NSUInteger>(result); i < dataCount; ++i ) {
            if ( drawPointFlags[i] ) {
                lastViewPoint = viewPoints[i];
                CGPoint lastPoint       = CGPointMake(lastViewPoint.x, lastViewPoint.y);
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(point, lastPoint);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = static_cast<NSInteger>(i);
                }
            }
        }
    }

    free(viewPoints);
    free(drawPointFlags);

    return static_cast<NSUInteger>(result);
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
 *  @link CPTContourPlotDelegate:: contourPlot:contourTouchDownAtRecordIndex: - contourPlot:contourTouchDownAtRecordIndex: @endlink or
 *  @link CPTContourPlotDelegate:: contourPlot:contourTouchDownAtRecordIndex:withEvent: - contourPlot:contourTouchDownAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each bar in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint {
    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTContourPlotDelegate> theDelegate = static_cast<id<CPTContourPlotDelegate>>(self.delegate);
    if ( [theDelegate respondsToSelector:@selector( contourPlot:contourTouchDownAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector( contourPlot:contourTouchDownAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector( contourPlot:contourWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector( contourPlot:contourWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];
        self.pointingDeviceDownIndex = idx;

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector( contourPlot:contourTouchDownAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate  contourPlot:self contourTouchDownAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector( contourPlot:contourTouchDownAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate  contourPlot:self contourTouchDownAtRecordIndex:idx withEvent:event];
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
 *  @link CPTContourPlotDelegate::contourPlot: contourTouchUpAtRecordIndex: -contourPlot:contourTouchUpAtRecordIndex: @endlink and/or
 *  @link CPTContourPlotDelegate::contourPlot: contourTouchUpAtRecordIndex:withEvent: -contourPlot:contourTouchUpAtRecordIndex:withEvent: @endlink
 *  methods, the @par{interactionPoint} is compared with each contour base point in index order.
 *  The delegate method will be called and this method returns @YES for the first
 *  index where the @par{interactionPoint} is inside a bar.
 *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
 *
 *  If the bar being released is the same as the one that was pressed (see
 *  @link CPTContourPlot::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
 *  @link CPTContourPlotDelegate:: contourPlot:contourWasSelectedAtRecordIndex: -contourPlot:contourWasSelectedAtRecordIndex: @endlink and/or
 *  @link CPTContourPlotDelegate:: contourPlot:contourWasSelectedAtRecordIndex:withEvent: -contourPlot:contourWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, these will be called.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint {
    NSUInteger selectedDownIndex = self.pointingDeviceDownIndex;

    self.pointingDeviceDownIndex = NSNotFound;

    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTContourPlotDelegate> theDelegate = static_cast<id<CPTContourPlotDelegate>>(self.delegate);
    if ( [theDelegate respondsToSelector:@selector(contourPlot:contourTouchUpAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(contourPlot:contourTouchUpAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(contourPlot:contourWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(contourPlot:contourWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            BOOL handled = NO;

            if ( [theDelegate respondsToSelector:@selector(contourPlot: contourTouchUpAtRecordIndex:)] ) {
                handled = YES;
                [theDelegate contourPlot:self contourTouchUpAtRecordIndex:idx];
            }

            if ( [theDelegate respondsToSelector:@selector(contourPlot: contourTouchUpAtRecordIndex:withEvent:)] ) {
                handled = YES;
                [theDelegate contourPlot:self contourTouchUpAtRecordIndex:idx withEvent:event];
            }

            if ( idx == selectedDownIndex ) {
                if ( [theDelegate respondsToSelector:@selector(contourPlot:contourWasSelectedAtRecordIndex:)] ) {
                    handled = YES;
                    [theDelegate contourPlot:self contourWasSelectedAtRecordIndex:idx];
                }

                if ( [theDelegate respondsToSelector:@selector(contourPlot:contourWasSelectedAtRecordIndex:withEvent:)] ) {
                    handled = YES;
                    [theDelegate contourPlot:self contourWasSelectedAtRecordIndex:idx withEvent:event];
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

-(void)setIsoCurveLineStyle:(nullable CPTLineStyle *)newLineStyle {
    if ( isoCurveLineStyle != newLineStyle ) {
        isoCurveLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setXValues:(nullable CPTNumberArray *)newValues {
    [self cacheNumbers:newValues forField:CPTContourPlotFieldX];
}

-(nullable CPTNumberArray *)xValues {
    return [[self cachedNumbersForField:CPTContourPlotFieldX] sampleArray];
}

-(void)setYValues:(nullable CPTNumberArray *)newValues {
    [self cacheNumbers:newValues forField:CPTContourPlotFieldY];
}

-(nullable CPTNumberArray *)yValues {
    return [[self cachedNumbersForField:CPTContourPlotFieldY] sampleArray];
}

-(nullable CPTMutableNumericData *)functionValues {
    return [self cachedNumbersForField:CPTContourPlotFieldFunctionValue];
}

-(void)setFunctionValues:(nullable CPTMutableNumericData *)newValues {
    [self cacheNumbers:newValues forField:CPTContourPlotFieldFunctionValue];
}

-(nullable CPTLineStyleArray *)isoCurveLineStyles {
    return self.isoCurvesLineStyles;
}

-(void)setLineStyles:(nullable CPTLineStyleArray *)newLineStyles {
    id nilObject                    = [CPTPlot nilData];
    for(NSUInteger i = 0; i < self.noIsoCurves; i++) {
        if( i >= newLineStyles.count ) {
            [self.isoCurvesLineStyles replaceObjectAtIndex:i withObject:nilObject];
        }
        else {
            [self.isoCurvesLineStyles replaceObjectAtIndex:i withObject:[CPTMutableLineStyle lineStyleWithStyle: newLineStyles[i]]];
        }
    }
    [self setNeedsDisplay];
}

-(nullable CPTNumberArray *)getIsoCurveValues {
    return self.isoCurvesValues;
}

-(NSUInteger)getNoDataPointsUsedForIsoCurves {
    return 0;
}

-(void)setNeedsIsoCurvesRelabel:(BOOL)newNeedsRelabel
{
    if ( newNeedsRelabel != needsIsoCurvesRelabel ) {
        needsIsoCurvesRelabel = newNeedsRelabel;
        if ( needsIsoCurvesRelabel ) {
            [self reLabelIsoCurves];
            [self setNeedsLayout];
        }
    }
}

-(void)setShowIsoCurvesLabels:(BOOL)newShowLabels
{
    if ( newShowLabels != showIsoCurvesLabels ) {
        showIsoCurvesLabels = newShowLabels;
        [self setNeedsIsoCurvesRelabel:newShowLabels];
    }
}

/// @endcond


@end
