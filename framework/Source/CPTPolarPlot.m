#import "CPTPolarPlot.h"

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
#import "CPTPolarPlotSpace.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/** @defgroup plotAnimationPolarPlot Scatter Plot
 *  @brief Polar plot properties that can be animated using Core Animation.
 *  @ingroup plotAnimation
 **/

/** @if MacOnly
 *  @defgroup plotBindingsPolarPlot Polar Plot Bindings
 *  @brief Binding identifiers for polar plots.
 *  @ingroup plotBindings
 *  @endif
 **/

NSString *const CPTPolarPlotBindingThetaValues     = @"thetaValues";     ///< Theta values.
NSString *const CPTPolarPlotBindingRadiusValues     = @"radiusValues";     ///< Radius values.
NSString *const CPTPolarPlotBindingPlotSymbols = @"plotSymbols"; ///< Plot symbols.

/// @cond
@interface CPTPolarPlot()


@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *thetaValues;
@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *radiusValues;
@property (nonatomic, readwrite, strong, nullable) CPTPlotSymbolArray *plotSymbols;
@property (nonatomic, readwrite, assign) NSUInteger pointingDeviceDownIndex;
@property (nonatomic, readwrite, assign) BOOL pointingDeviceDownOnLine;
@property (nonatomic, readwrite, strong) CPTMutableLimitBandArray *mutableAreaFillBands;

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags forPlotSpace:(nonnull CPTPolarPlotSpace *)polarPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly numberOfPoints:(NSUInteger)dataCount;
-(void)calculateViewPoints:(nonnull CGPoint *)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount;
-(void)alignViewPointsToUserSpace:(nonnull CGPoint *)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount;

-(NSInteger)extremeDrawnPointIndexForFlags:(nonnull BOOL *)pointDrawFlags numberOfPoints:(NSUInteger)dataCount extremeNumIsLowerBound:(BOOL)isLowerBound;

-(nonnull CGPathRef)newDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineRadiusValue:(CGFloat)baselineRadiusValue centrePoint:(CGPoint)centrePoint;
-(nonnull CGPathRef)newCurvedDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineRadiusValue:(CGFloat)baselineRadiusValue centrePoint:(CGPoint)centrePoint;
-(void)computeBezierControlPoints:(nonnull CGPoint *)cp1 points2:(nonnull CGPoint *)cp2 forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange;
-(void)computeCatmullRomControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 withAlpha:(CGFloat)alpha forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange;
-(void)computeHermiteControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange;
-(BOOL)monotonicViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A two-dimensional polar plot.
 *  @see See @ref plotAnimationPolarPlot "Polar Plot" for a list of animatable properties.
 *  @if MacOnly
 *  @see See @ref plotBindingsPolarPlot "Polar Plot Bindings" for a list of supported binding identifiers.
 *  @endif
 **/
@implementation CPTPolarPlot

@dynamic thetaValues;
@dynamic radiusValues;
@dynamic plotSymbols;

/** @property CPTPolarPlotInterpolation interpolation
 *  @brief The interpolation algorithm used for lines between data points.
 *  Default is #CPTPolarPlotInterpolationLinear.
 **/
@synthesize interpolation;

/** @property CPTPolarPlotHistogramOption histogramOption
 *  @brief The drawing style for a histogram plot line (@ref interpolation = #CPTPolarPlotInterpolationHistogram).
 *  Default is #CPTPolarPlotHistogramNormal.
 **/
@synthesize histogramOption;

/** @property CPTPolarPlotCurvedInterpolationOption curvedInterpolationOption
 *  @brief The interpolation method used to generate the curved plot line (@ref interpolation = #CPTPolarPlotInterpolationCurved)
 *  Default is #CPTPolarPlotCurvedInterpolationNormal
 **/
@synthesize curvedInterpolationOption;

/** @property CGFloat curvedInterpolationCustomAlpha
 *  @brief The custom alpha value used when the #CPTPolarPlotCurvedInterpolationCatmullCustomAlpha interpolation is selected.
 *  Default is @num{0.5}.
 *  @note Must be between @num{0.0} and @num{1.0}.
 **/
@synthesize curvedInterpolationCustomAlpha;

/** @property nullable CPTLineStyle *dataLineStyle
 *  @brief The line style for the data line.
 *  If @nil, the line is not drawn.
 **/
@synthesize dataLineStyle;

/** @property nullable CPTPlotSymbol *plotSymbol
 *  @brief The plot symbol drawn at each point if the data source does not provide symbols.
 *  If @nil, no symbol is drawn.
 **/
@synthesize plotSymbol;

/** @property nullable CPTFill *areaFill
 *  @brief The fill style for the area underneath the data line.
 *  If @nil, the area is not filled.
 **/
@synthesize areaFill;

/** @property nullable CPTFill *areaFill2
 *  @brief The fill style for the area above the data line.
 *  If @nil, the area is not filled.
 **/
@synthesize areaFill2;

/** @property nullable NSNumber *areaBaseValue
 *  @brief The Y coordinate of the straight boundary of the area fill.
 *  If not a number, the area is not filled.
 *
 *  Typically set to the minimum value of the Y range, but it can be any value that gives the desired appearance.
 *
 *  @ingroup plotBindingsPolarPlot
 **/
@synthesize areaBaseValue;

/** @property nullable NSNumber *areaBaseValue2
 *  @brief The Y coordinate of the straight boundary of the secondary area fill.
 *  If not a number, the area is not filled.
 *
 *  Typically set to the maximum value of the Y range, but it can be any value that gives the desired appearance.
 *
 *  @ingroup plotBindingsPolarPlot
 **/
@synthesize areaBaseValue2;

/** @property CGFloat plotSymbolMarginForHitDetection
 *  @brief A margin added to each side of a symbol when determining whether it has been hit.
 *
 *  Default is zero. The margin is set in plot area view coordinates.
 **/
@synthesize plotSymbolMarginForHitDetection;

/** @property nonnull CGPathRef newDataLinePath
 *  @brief The path used to draw the data line. The caller must release the returned path.
 **/
@dynamic newDataLinePath;

/** @property CGFloat plotLineMarginForHitDetection
 *  @brief A margin added to each side of a plot line when determining whether it has been hit.
 *
 *  Default is four points to each side of the line. The margin is set in plot area view coordinates.
 **/
@synthesize plotLineMarginForHitDetection;

/** @property BOOL allowSimultaneousSymbolAndPlotSelection
 *  @brief @YES if both symbol selection and line selection can happen on the same upEvent. If @NO
 *  then when an upEvent occurs on a symbol only the symbol will be selected, otherwise the line
 *  will be selected if the upEvent occured on the line.
 *
 *  Default is @NO.
 **/
@synthesize allowSimultaneousSymbolAndPlotSelection;

/** @internal
 *  @property NSUInteger pointingDeviceDownIndex
 *  @brief The index that was selected on the pointing device down event.
 **/
@synthesize pointingDeviceDownIndex;

/** @internal
 *  @property BOOL pointingDeviceDownOnLine
 *  @brief @YES if the pointing device down event occured on the plot line.
 **/
@synthesize pointingDeviceDownOnLine;

/** @property nullable CPTLimitBandArray *areaFillBands
 *  @brief An array of CPTLimitBand objects.
 *
 *  The limit bands are drawn between the plot line and areaBaseValue and on top of the areaFill.
 **/
@dynamic areaFillBands;

@synthesize mutableAreaFillBands;

#pragma mark -
#pragma mark Init/Dealloc

/// @cond

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
    if ( self == [CPTPolarPlot class] ) {
        [self exposeBinding:CPTPolarPlotBindingThetaValues];
        [self exposeBinding:CPTPolarPlotBindingRadiusValues];
        [self exposeBinding:CPTPolarPlotBindingPlotSymbols];
    }
}
#endif

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPolarPlot object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref dataLineStyle = default line style
 *  - @ref plotSymbol = @nil
 *  - @ref areaFill = @nil
 *  - @ref areaFill2 = @nil
 *  - @ref areaBaseValue = @NAN
 *  - @ref areaBaseValue2 = @NAN
 *  - @ref plotSymbolMarginForHitDetection = @num{0.0}
 *  - @ref plotLineMarginForHitDetection = @num{4.0}
 *  - @ref allowSimultaneousSymbolAndPlotSelection = NO
 *  - @ref interpolation = #CPTPolarPlotInterpolationLinear
 *  - @ref histogramOption = #CPTPolarPlotHistogramNormal
 *  - @ref curvedInterpolationOption = #CPTPolarPlotCurvedInterpolationNormal
 *  - @ref curvedInterpolationCustomAlpha = @num{0.5}
 *  - @ref labelField = #CPTPolarPlotFieldY
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPolarPlot object.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        dataLineStyle                   = [[CPTLineStyle alloc] init];
        plotSymbol                      = nil;
        areaFill                        = nil;
        areaFill2                       = nil;
        areaBaseValue                   = @(NAN);
        areaBaseValue2                  = @(NAN);
        plotSymbolMarginForHitDetection = CPTFloat(0.0);
        plotLineMarginForHitDetection   = CPTFloat(4.0);
        interpolation                   = CPTPolarPlotInterpolationLinear;
        histogramOption                 = CPTPolarPlotHistogramNormal;
        curvedInterpolationOption       = CPTPolarPlotCurvedInterpolationNormal;
        curvedInterpolationCustomAlpha  = CPTFloat(0.5);
        pointingDeviceDownIndex         = NSNotFound;
        pointingDeviceDownOnLine        = NO;
        mutableAreaFillBands            = nil;
        self.labelField                 = CPTPolarPlotFieldRadius;
    }
    return self;
}

/// @}

/// @cond

-(nonnull instancetype)initWithLayer:(nonnull id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPolarPlot *theLayer = (CPTPolarPlot *)layer;

        dataLineStyle                           = theLayer->dataLineStyle;
        plotSymbol                              = theLayer->plotSymbol;
        areaFill                                = theLayer->areaFill;
        areaFill2                               = theLayer->areaFill2;
        areaBaseValue                           = theLayer->areaBaseValue;
        areaBaseValue2                          = theLayer->areaBaseValue2;
        plotSymbolMarginForHitDetection         = theLayer->plotSymbolMarginForHitDetection;
        plotLineMarginForHitDetection           = theLayer->plotLineMarginForHitDetection;
        allowSimultaneousSymbolAndPlotSelection = theLayer->allowSimultaneousSymbolAndPlotSelection;
        interpolation                           = theLayer->interpolation;
        histogramOption                         = theLayer->histogramOption;
        curvedInterpolationOption               = theLayer->curvedInterpolationOption;
        curvedInterpolationCustomAlpha          = theLayer->curvedInterpolationCustomAlpha;
        mutableAreaFillBands                    = theLayer->mutableAreaFillBands;
        pointingDeviceDownIndex                 = NSNotFound;
        pointingDeviceDownOnLine                = NO;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeInteger:self.interpolation forKey:@"CPTPolarPlot.interpolation"];
    [coder encodeInteger:self.histogramOption forKey:@"CPTPolarPlot.histogramOption"];
    [coder encodeInteger:self.curvedInterpolationOption forKey:@"CPTPolarPlot.curvedInterpolationOption"];
    [coder encodeCGFloat:self.curvedInterpolationCustomAlpha forKey:@"CPTPolarPlot.curvedInterpolationCustomAlpha"];
    [coder encodeObject:self.dataLineStyle forKey:@"CPTPolarPlot.dataLineStyle"];
    [coder encodeObject:self.plotSymbol forKey:@"CPTPolarPlot.plotSymbol"];
    [coder encodeObject:self.areaFill forKey:@"CPTPolarPlot.areaFill"];
    [coder encodeObject:self.areaFill2 forKey:@"CPTPolarPlot.areaFill2"];
    [coder encodeObject:self.mutableAreaFillBands forKey:@"CPTPolarPlot.mutableAreaFillBands"];
    [coder encodeObject:self.areaBaseValue forKey:@"CPTPolarPlot.areaBaseValue"];
    [coder encodeObject:self.areaBaseValue2 forKey:@"CPTPolarPlot.areaBaseValue2"];
    [coder encodeCGFloat:self.plotSymbolMarginForHitDetection forKey:@"CPTPolarPlot.plotSymbolMarginForHitDetection"];
    [coder encodeCGFloat:self.plotLineMarginForHitDetection forKey:@"CPTPolarPlot.plotLineMarginForHitDetection"];
    [coder encodeBool:self.allowSimultaneousSymbolAndPlotSelection forKey:@"CPTPolarPlot.allowSimultaneousSymbolAndPlotSelection"];

    // No need to archive these properties:
    // pointingDeviceDownIndex
    // pointingDeviceDownOnLine
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        
        interpolation                  = (CPTPolarPlotInterpolation)[coder decodeIntegerForKey:@"CPTPolarPlot.interpolation"];
        histogramOption                = (CPTPolarPlotHistogramOption)[coder decodeIntegerForKey:@"CPTPolarPlot.histogramOption"];
        curvedInterpolationOption      = (CPTPolarPlotCurvedInterpolationOption)[coder decodeIntegerForKey:@"CPTPolarPlot.curvedInterpolationOption"];
        curvedInterpolationCustomAlpha = [coder decodeCGFloatForKey:@"CPTPolarPlot.curvedInterpolationCustomAlpha"];
        dataLineStyle                  = [[coder decodeObjectOfClass:[CPTLineStyle class]
                                                              forKey:@"CPTPolarPlot.dataLineStyle"] copy];
        plotSymbol = [[coder decodeObjectOfClass:[CPTPlotSymbol class]
                                          forKey:@"CPTPolarPlot.plotSymbol"] copy];
        areaFill = [[coder decodeObjectOfClass:[CPTFill class]
                                        forKey:@"CPTPolarPlot.areaFill"] copy];
        areaFill2 = [[coder decodeObjectOfClass:[CPTFill class]
                                         forKey:@"CPTPolarPlot.areaFill2"] copy];
        mutableAreaFillBands = [[coder decodeObjectOfClasses:[NSSet setWithArray:@[[NSArray class], [CPTLimitBand class]]]
                                                      forKey:@"CPTPolarPlot.mutableAreaFillBands"] mutableCopy];
        areaBaseValue = [coder decodeObjectOfClass:[NSNumber class]
                                            forKey:@"CPTPolarPlot.areaBaseValue"];
        areaBaseValue2 = [coder decodeObjectOfClass:[NSNumber class]
                                             forKey:@"CPTPolarPlot.areaBaseValue2"];
        plotSymbolMarginForHitDetection         = [coder decodeCGFloatForKey:@"CPTPolarPlot.plotSymbolMarginForHitDetection"];
        plotLineMarginForHitDetection           = [coder decodeCGFloatForKey:@"CPTPolarPlot.plotLineMarginForHitDetection"];
        allowSimultaneousSymbolAndPlotSelection = [coder decodeBoolForKey:@"CPTPolarPlot.allowSimultaneousSymbolAndPlotSelection"];
        pointingDeviceDownIndex                 = NSNotFound;
        pointingDeviceDownOnLine                = NO;
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
#pragma mark Data Loading

/// @cond

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
    [super reloadDataInIndexRange:indexRange];

    // Update plot symbols
    [self reloadPlotSymbolsInIndexRange:indexRange];
}

-(void)reloadPlotDataInIndexRange:(NSRange)indexRange
{
    [super reloadPlotDataInIndexRange:indexRange];

    if ( ![self loadNumbersForAllFieldsFromDataSourceInRecordIndemajorRange:indexRange] ) {
        id<CPTPolarPlotDataSource> theDataSource = (id<CPTPolarPlotDataSource>)self.dataSource;

        if ( theDataSource ) {
            id newThetaValues = [self numbersFromDataSourceForField:CPTPolarPlotFieldRadialAngle recordIndexRange:indexRange];
            [self cacheNumbers:newThetaValues forField:CPTPolarPlotFieldRadialAngle atRecordIndex:indexRange.location];
            id newRadiusValues = [self numbersFromDataSourceForField:CPTPolarPlotFieldRadius recordIndexRange:indexRange];
            [self cacheNumbers:newRadiusValues forField:CPTPolarPlotFieldRadius atRecordIndex:indexRange.location];
        }
    }
}

/** @brief Gets a range of plot data for the given plot and field.
 *  @brief Adjust the theta value if in degrees to radians.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data points.
 **/
-(nullable id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    id numbers; // can be CPTNumericData, NSArray, or NSData
    
    id<CPTPlotDataSource> theDataSource = self.dataSource;
    
    if ( theDataSource ) {
        if ( [theDataSource respondsToSelector:@selector(dataForPlot:field:recordIndexRange:)] ) {
            if(fieldEnum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees){
                numbers = [theDataSource dataForPlot:self field:fieldEnum recordIndexRange:indexRange];
                const void *ptrFactor = NULL;
                NSUInteger numSamples = [[numbers sampleArray] count];
                switch ([numbers dataTypeFormat]) {
                    case CPTUndefinedDataType:
                    case CPTIntegerDataType:
                    case CPTUnsignedIntegerDataType:
                    case CPTComplexFloatingPointDataType:
                        break;
                        
                    case CPTFloatingPointDataType:
                        switch ( [numbers sampleBytes] ) {
                            case sizeof(float):
                            { // float
                                const float Factor = (float)M_PI/180.0f;
                                ptrFactor = &Factor;
                            }
                                break;
                                
                            case sizeof(double):
                            { // double
                                const double Factor = M_PI/180.0;
                                ptrFactor = &Factor;
                            }
                                break;
                        }
                        break;
                    
                    case CPTDecimalDataType:
                        switch ( [numbers sampleBytes] ) {
                            case sizeof(NSDecimal):
                            { // NSDecimal
                                NSDecimal Factor = [[NSNumber numberWithDouble:M_PI/180.0] decimalValue];
                                ptrFactor = &Factor;
                            }
                                break;
                        }
                        break;
                        
                }

                if(ptrFactor != NULL){
                    for(NSUInteger i = 0; i < numSamples; i++ ){
//                        [numbers multiplyByFactorSamplePointer:i Factor:ptrFactor];
                    }
                }
            }
            else
                numbers = [theDataSource dataForPlot:self field:fieldEnum recordIndexRange:indexRange];
        }
        else if ( [theDataSource respondsToSelector:@selector(doublesForPlot:field:recordIndexRange:)] ) {
            numbers = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            double *fieldValues  = [numbers mutableBytes];
            double *doubleValues = [theDataSource doublesForPlot:self field:fieldEnum recordIndexRange:indexRange];
            memcpy(fieldValues, doubleValues, sizeof(double) * indexRange.length);
            if(fieldEnum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees){
                NSUInteger recordIndex;
                for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                    fieldValues[recordIndex-indexRange.location] = fieldValues[recordIndex-indexRange.location]/180.0*M_PI;
                }
            }
        }
        else if ( [theDataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
            NSArray *numberArray = [theDataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange];
            if ( numberArray ) {
                if(fieldEnum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees){
                    NSMutableArray *mutableNumberArray = [NSMutableArray arrayWithArray:numberArray];
                    NSUInteger recordIndex;
                    for( recordIndex = 0; recordIndex < [mutableNumberArray count]; ++recordIndex )
                        [mutableNumberArray replaceObjectAtIndex:recordIndex withObject:[NSNumber numberWithDouble:[[mutableNumberArray objectAtIndex:recordIndex] doubleValue]/180.0*M_PI]];
                    numbers = [NSArray arrayWithArray:mutableNumberArray];
                }
                else
                    numbers = [NSArray arrayWithArray:numberArray];
            }
            else {
                numbers = nil;
            }
        }
        else if ( [theDataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
            NSUInteger recordIndex;
            NSMutableData *fieldData = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            double *fieldValues      = fieldData.mutableBytes;
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                double number = [theDataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
                if(fieldEnum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
                    *fieldValues++ = number/180.0*M_PI;
                else
                    *fieldValues++ = number;
            }
            numbers = fieldData;
        }
        else {
            BOOL respondsToSingleValueSelector = [theDataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
            NSNull *nullObject                 = [NSNull null];
            NSUInteger recordIndex;
            NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
                if ( respondsToSingleValueSelector ) {
                    id number = [theDataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
                    if ( number ) {
                        {
                            if(fieldEnum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
                                [fieldValues addObject:[NSNumber numberWithDouble:[(NSNumber*)number doubleValue]/180.0*M_PI]];
                            else
                                [fieldValues addObject:number];
                        }
                        
                    }
                    else {
                        [fieldValues addObject:nullObject];
                    }
                }
                else {
                    [fieldValues addObject:[NSDecimalNumber zero]];
                }
            }
            numbers = fieldValues;
        }
    }
    else {
        numbers = [super numbersFromDataSourceForField:fieldEnum recordIndexRange:indexRange];
        NSLog(@"%f", [numbers[0] doubleValue]);
        numbers = @[];
    }

    return numbers;
}

/** @brief Gets a range of plot data for the given plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return Returns @YES if the datasource implements the
 *  @link CPTPlotDataSource::dataForPlot:recordIndexRange: -dataForPlot:recordIndexRange: @endlink
 *  method and it returns valid data.
 **/
-(BOOL)loadNumbersForAllFieldsFromDataSourceInRecordIndemajorRange:(NSRange)indexRange
{
    BOOL hasData = NO;
    
    id<CPTPlotDataSource> theDataSource = self.dataSource;
    
    if ( [theDataSource respondsToSelector:@selector(dataForPlot:recordIndexRange:)] ) {
        CPTNumericData *data = [theDataSource dataForPlot:self recordIndexRange:indexRange];
        
        if ( [data isKindOfClass:[CPTNumericData class]] ) {
            const NSUInteger sampleCount = data.numberOfSamples;
            CPTNumericDataType dataType  = data.dataType;
            
            if ( (sampleCount > 0) && (data.numberOfDimensions == 2) ) {
                CPTNumberArray *theShape    = data.shape;
                const NSUInteger rowCount   = theShape[0].unsignedIntegerValue;
                const NSUInteger fieldCount = theShape[1].unsignedIntegerValue;
                
                if ( fieldCount > 0 ) {
                    // convert data type if needed
                    switch ( self.cachePrecision ) {
                        case CPTPlotCachePrecisionAuto:
                            if ( self.doublePrecisionCache ) {
                                if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
                                    CPTMutableNumericData *mutableData = [CPTMutableNumericData numericDataWithData:data.data dataType:data.dataType shape:theShape];
 //                                   mutableData.dataType = self.doubleDataType;
                                    data                 = mutableData;
                                }
                            }
                            else {
                                if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType) ) {
//                                    CPTMutableNumericData *mutableData = [data mutableCopy];
//                                    mutableData.dataType = self.decimalDataType;
                                    CPTMutableNumericData *mutableData = [CPTMutableNumericData numericDataWithData:data.data dataType:data.dataType shape:theShape];
                                    data                 = mutableData;
                                }
                            }
                            break;
                            
                        case CPTPlotCachePrecisionDecimal:
                            if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType) ) {
//                                CPTMutableNumericData *mutableData = [data mutableCopy];
//                                mutableData.dataType = self.decimalDataType;
                                CPTMutableNumericData *mutableData = [CPTMutableNumericData numericDataWithData:data.data dataType:data.dataType shape:theShape];
                                data                 = mutableData;
                            }
                            break;
                            
                        case CPTPlotCachePrecisionDouble:
                            if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
//                                CPTMutableNumericData *mutableData = [data mutableCopy];
//                                mutableData.dataType = self.doubleDataType;
                                CPTMutableNumericData *mutableData = [CPTMutableNumericData numericDataWithData:data.data dataType:data.dataType shape:theShape];
                                data                 = mutableData;
                            }
                            break;
                    }
                    
                    // add the data to the cache
                    const NSUInteger bufferLength = rowCount * dataType.sampleBytes;
                    
                    switch ( data.dataOrder ) {
                        case CPTDataOrderRowsFirst:
                        {
                            const void *sourceEnd = (const int8_t *)(data.bytes) + data.length;
                            
                            for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
                                NSMutableData *tempData = [[NSMutableData alloc] initWithLength:bufferLength];
                                
                                if ( CPTDataTypeEqualToDataType(dataType, self.doubleDataType) ) {
                                    const double *sourceData = [data samplePointerAtIndex:0, fieldNum];
                                    double *destData         = tempData.mutableBytes;
                                    
                                    while ( sourceData < (const double *)sourceEnd ) {
                                        if(fieldNum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
                                            *destData++ = *sourceData*M_PI/180.0;
                                        else
                                            *destData++ = *sourceData;
                                        sourceData += fieldCount;
                                    }
                                }
                                else {
                                    const NSDecimal *sourceData = [data samplePointerAtIndex:0, fieldNum];
                                    NSDecimal *destData         = tempData.mutableBytes;
                                    
                                    while ( sourceData < (const NSDecimal *)sourceEnd ) {
                                        if(fieldNum == CPTPolarPlotFieldRadialAngle && ((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees){
                                            NSDecimal result;
                                            NSNumber *factor = [NSNumber numberWithDouble:M_PI/180.0];
                                            NSDecimal decimalFactor = [factor decimalValue];
                                            //NSCalculationError error =
                                            NSDecimalMultiply ( &result, sourceData, &decimalFactor, NSRoundPlain);
                                            *destData++ = result;
                                        }
                                        else
                                            *destData++ = *sourceData;
                                        sourceData += fieldCount;
                                    }
                                }
                                
                                CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
                                                                                                            dataType:dataType
                                                                                                               shape:nil];
                                
                                [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
                            }
                            hasData = YES;
                        }
                            break;
                            
                        case CPTDataOrderColumnsFirst:
                            for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
                                const void *samples = [data samplePointerAtIndex:0, fieldNum];
                                NSData *tempData    = [[NSData alloc] initWithBytes:samples
                                                                             length:bufferLength];
                                
                                CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
                                                                                                            dataType:dataType
                                                                                                               shape:nil];
                                
                                [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
                            }
                            hasData = YES;
                            break;
                    }
                }
            }
        }
    }
    
    return hasData;
}

/// @endcond

/**
 *  @brief Reload all plot symbols from the data source immediately.
 **/
-(void)reloadPlotSymbols
{
    [self reloadPlotSymbolsInIndexRange:NSMakeRange(0, self.cachedDataCount)];
}

/** @brief Reload plot symbols in the given index range from the data source immediately.
 *  @param indexRange The index range to load.
 **/
-(void)reloadPlotSymbolsInIndexRange:(NSRange)indexRange
{
    id<CPTPolarPlotDataSource> theDataSource = (id<CPTPolarPlotDataSource>)self.dataSource;

    BOOL needsLegendUpdate = NO;

    if ( [theDataSource respondsToSelector:@selector(symbolsForPolarPlot:recordIndexRange:)] ) {
        needsLegendUpdate = YES;

        [self cacheArray:[theDataSource symbolsForPolarPlot:self recordIndexRange:indexRange]
                  forKey:CPTPolarPlotBindingPlotSymbols
           atRecordIndex:indexRange.location];
    }
    else if ( [theDataSource respondsToSelector:@selector(symbolForPolarPlot:recordIndex:)] ) {
        needsLegendUpdate = YES;

        id nilObject                     = [CPTPlot nilData];
        CPTMutablePlotSymbolArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
        NSUInteger maxIndex              = NSMaxRange(indexRange);

        for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
            CPTPlotSymbol *symbol = [theDataSource symbolForPolarPlot:self recordIndex:idx];
            if ( symbol ) {
                [array addObject:symbol];
            }
            else {
                [array addObject:nilObject];
            }
        }

        [self cacheArray:array forKey:CPTPolarPlotBindingPlotSymbols atRecordIndex:indexRange.location];
    }

    // Legend
    if ( needsLegendUpdate ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }

    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Symbols

/** @brief Returns the plot symbol to use for a given index.
 *  @param idx The index of the record.
 *  @return The plot symbol to use, or @nil if no plot symbol should be drawn.
 **/
-(nullable CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)idx
{
    CPTPlotSymbol *symbol = [self cachedValueForKey:CPTPolarPlotBindingPlotSymbols recordIndex:idx];

    if ( (symbol == nil) || (symbol == [CPTPlot nilData]) ) {
        symbol = self.plotSymbol;
    }

    return symbol;
}

#pragma mark -
#pragma mark Determining Which Points to Draw

/// @cond

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags forPlotSpace:(nonnull CPTPolarPlotSpace *)polarPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly numberOfPoints:(NSUInteger)dataCount
{
    if ( dataCount == 0 ) {
        return;
    }

    CPTLineStyle *lineStyle = self.dataLineStyle;

    if ( self.areaFill || self.areaFill2 || lineStyle.dashPattern || lineStyle.lineFill || (self.interpolation == CPTPolarPlotInterpolationCurved) ) {
        // show all points to preserve the line dash and area fills
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
            pointDrawFlags[i] = YES;
        }
    }
    else {
        CPTPlotRangeComparisonResult *majorRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
        CPTPlotRangeComparisonResult *minorRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
        CPTPlotRangeComparisonResult *radialRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
        BOOL *nanFlags                            = malloc( dataCount * sizeof(BOOL) );

        CPTPlotRange *majorRange = polarPlotSpace.majorRange;
        CPTPlotRange *minorRange = polarPlotSpace.minorRange;
        CPTPlotRange *radialRange = polarPlotSpace.radialRange;

        // Determine where each point lies in relation to range
        if ( self.doublePrecisionCache ) {
            const double *thetaBytes = (const double *)[self cachedNumbersForField:CPTPolarPlotFieldRadialAngle].data.bytes;
            const double *radiusBytes = (const double *)[self cachedNumbersForField:CPTPolarPlotFieldRadius].data.bytes;

            dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
                
                const double theta = thetaBytes[i];
                const double radius = radiusBytes[i];
                const double x = radius * sin(theta);
                const double y = radius * cos(theta);

                CPTPlotRangeComparisonResult majorFlag = [majorRange compareToDouble:x];
                CPTPlotRangeComparisonResult minorFlag = [minorRange compareToDouble:y];
                majorRangeFlags[i] = majorFlag;
                minorRangeFlags[i] = minorFlag;
                if ( majorFlag != CPTPlotRangeComparisonResultNumberInRange ) {
                    minorRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if x is out of range, then y doesn't matter
                }
                if ( minorFlag != CPTPlotRangeComparisonResultNumberInRange ) {
                    majorRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if y is out of range, then x doesn't matter
                }
                else {
                    radialRangeFlags[i] = [radialRange compareToDouble:theta];
                }
                nanFlags[i] = isnan(x) || isnan(y) || isnan(theta);
            });
        }
        else {
            // Determine where each point lies in relation to range
            const NSDecimal *thetaBytes = (const NSDecimal *)[self cachedNumbersForField:CPTPolarPlotFieldRadialAngle].data.bytes;
            const NSDecimal *radiusBytes = (const NSDecimal *)[self cachedNumbersForField:CPTPolarPlotFieldRadius].data.bytes;

            dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
                
                NSDecimalNumber *_theta = [NSDecimalNumber decimalNumberWithDecimal:thetaBytes[i]];
                NSDecimalNumber *_radius = [NSDecimalNumber decimalNumberWithDecimal:radiusBytes[i]];
                
                const double x = [_radius doubleValue] * sin([_theta doubleValue]);
                const double y = [_radius doubleValue] * cos([_theta doubleValue]);

                CPTPlotRangeComparisonResult xFlag = [majorRange compareToDouble:x];
                CPTPlotRangeComparisonResult yFlag = [minorRange compareToDouble:y];
                majorRangeFlags[i] = xFlag;
                minorRangeFlags[i] = yFlag;
                if ( xFlag != CPTPlotRangeComparisonResultNumberInRange ) {
                    minorRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if x is out of range, then y doesn't matter
                }
                else if ( yFlag != CPTPlotRangeComparisonResultNumberInRange ) {
                    majorRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if y is out of range, then x doesn't matter
                }
                else {
                    radialRangeFlags[i] = [radialRange compareToDecimal:thetaBytes[i]];
                }
                nanFlags[i] = isnan(x) || isnan(y) || NSDecimalIsNotANumber(&thetaBytes[i]);
//                CPTPlotRangeComparisonResult xFlag = [majorRange compareToDecimal:x];
//                majorRangeFlags[i] = xFlag;
//                if ( xFlag != CPTPlotRangeComparisonResultNumberInRange ) {
//                    minorRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if x is out of range, then y doesn't matter
//                }
//                else {
//                    minorRangeFlags[i] = [minorRange compareToDecimal:y];
//                }
//
//                nanFlags[i] = NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y);
            });
        }

        // Ensure that whenever the path crosses over a region boundary, both points
        // are included. This ensures no lines are left out that shouldn't be.
        CPTPolarPlotInterpolation theInterpolation = self.interpolation;

        memset( pointDrawFlags, NO, dataCount * sizeof(BOOL) );
        if ( dataCount > 0 ) {
            pointDrawFlags[0] = (majorRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
                                 minorRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
                                 radialRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
                                 !nanFlags[0]);
        }
        if ( visibleOnly ) {
            for ( NSUInteger i = 1; i < dataCount; i++ ) {
                if ( (majorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                     (minorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                    (radialRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                     !nanFlags[i] ) {
                    pointDrawFlags[i] = YES;
                }
            }
        }
        else {
            switch ( theInterpolation ) {
                case CPTPolarPlotInterpolationCurved:
                    // Keep 2 points outside of the visible area on each side to maintain the correct curvature of the line
                    if ( dataCount > 1 ) {
                        if ( !nanFlags[0] && !nanFlags[1] && ( (majorRangeFlags[0] != majorRangeFlags[1]) || (minorRangeFlags[0] != minorRangeFlags[1]) || (radialRangeFlags[0] != radialRangeFlags[1]) ) ) {
                            pointDrawFlags[0] = YES;
                            pointDrawFlags[1] = YES;
                        }
                        else if ( (majorRangeFlags[1] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  (minorRangeFlags[1] == CPTPlotRangeComparisonResultNumberInRange) &&
                                 (radialRangeFlags[1] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  !nanFlags[1] ) {
                            pointDrawFlags[1] = YES;
                        }
                    }

                    for ( NSUInteger i = 2; i < dataCount; i++ ) {
                        if ( !nanFlags[i - 2] && !nanFlags[i - 1] && !nanFlags[i] ) {
                            pointDrawFlags[i - 2] = YES;
                            pointDrawFlags[i - 1] = YES;
                            pointDrawFlags[i]     = YES;
                        }
                        else if ( !nanFlags[i - 1] && !nanFlags[i] && ( (majorRangeFlags[i - 1] != majorRangeFlags[i]) || (minorRangeFlags[i - 1] != minorRangeFlags[i]) || (radialRangeFlags[i - 1] != radialRangeFlags[i]) ) ) {
                            pointDrawFlags[i - 2] = YES;
                            pointDrawFlags[i - 1] = YES;
                            pointDrawFlags[i]     = YES;
                        }
                        else if ( (majorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  (minorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                 (radialRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  !nanFlags[i] ) {
                            pointDrawFlags[i] = YES;
                        }
                    }
                    break;

                default:
                    // Keep 1 point outside of the visible area on each side
                    for ( NSUInteger i = 1; i < dataCount; i++ ) {
                        if ( !nanFlags[i - 1] && !nanFlags[i] && ( (majorRangeFlags[i - 1] != majorRangeFlags[i]) || (minorRangeFlags[i - 1] != minorRangeFlags[i]) ) ) {
                            pointDrawFlags[i - 1] = YES;
                            pointDrawFlags[i]     = YES;
                        }
                        else if ( (majorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  (minorRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                 (radialRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                                  !nanFlags[i] ) {
                            pointDrawFlags[i] = YES;
                        }
                    }
                    break;
            }
        }

        free(majorRangeFlags);
        free(minorRangeFlags);
        free(radialRangeFlags);
        free(nanFlags);
    }
}

-(void)calculateViewPoints:(nonnull CGPoint *)viewPoints withDrawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    CPTPlotSpace *thePlotSpace = self.plotSpace;

    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *thetaBytes = (const double *)[self cachedNumbersForField:CPTPolarPlotFieldRadialAngle].data.bytes;
        const double *radiusBytes = (const double *)[self cachedNumbersForField:CPTPolarPlotFieldRadius].data.bytes;

        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
//            const double x = radiusBytes[i] * sin(thetaBytes[i]);
//            const double y = radiusBytes[i] * cos(thetaBytes[i]);
            const double theta = thetaBytes[i];
            const double radius = radiusBytes[i];
            if ( !drawPointFlags[i] || isnan(radius) || isnan(theta) /*|| isnan(x) || isnan(y)*/ ) {
                viewPoints[i] = CPTPointMake(NAN, NAN);
            }
            else {
                double plotPoint[2];
//                plotPoint[CPTCoordinateX] = x;
//                plotPoint[CPTCoordinateY] = y;
                plotPoint[CPTCoordinateX] = radius;
                plotPoint[CPTCoordinateY] = 0.0;
                
                double centrePlotPoint[2];
                centrePlotPoint[CPTCoordinateX] = 0.0;
                centrePlotPoint[CPTCoordinateY] = 0.0;
                
                CGPoint centrePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:centrePlotPoint numberOfCoordinates:2];
                CGPoint viewPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i] = CPTPointMake((viewPoint.x - centrePoint.x) * sin(theta) + centrePoint.x, (viewPoint.x - centrePoint.x) * cos(theta) + centrePoint.y);
//                viewPoints[i] = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }
        });
    }
    else {
        CPTMutableNumericData *thetaData = [self cachedNumbersForField:CPTPolarPlotFieldRadialAngle];
        CPTMutableNumericData *radiusData = [self cachedNumbersForField:CPTPolarPlotFieldRadius];
        
        const NSDecimal *thetaBytes = (const NSDecimal *)thetaData.data.bytes;
        const NSDecimal *radiusBytes = (const NSDecimal *)radiusData.data.bytes;

        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            
            NSDecimalNumber *_theta = [NSDecimalNumber decimalNumberWithDecimal:thetaBytes[i]];
            NSDecimalNumber *_radius = [NSDecimalNumber decimalNumberWithDecimal:radiusBytes[i]];
            
//            const double x = [_radius doubleValue] * sin([_theta doubleValue]);
//            const double y = [_radius doubleValue] * cos([_theta doubleValue]);
            const double theta = [_theta doubleValue];
            const double radius = [_radius doubleValue];
            if ( !drawPointFlags[i] || isnan(radius) || isnan(theta) /*|| isnan(x) || isnan(y)*/ ) {
                viewPoints[i] = CPTPointMake(NAN, NAN);
            }
            else {
                double plotPoint[2];
//                plotPoint[CPTCoordinateX] = x;
//                plotPoint[CPTCoordinateY] = y;
                plotPoint[CPTCoordinateX] = radius;
                plotPoint[CPTCoordinateY] = 0.0;
                
                double centrePlotPoint[2];
                centrePlotPoint[CPTCoordinateX] = 0.0;
                centrePlotPoint[CPTCoordinateY] = 0.0;
                
                CGPoint centrePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:centrePlotPoint numberOfCoordinates:2];
                CGPoint viewPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                viewPoints[i] = CPTPointMake((viewPoint.x - centrePoint.x) * sin(theta) + centrePoint.x, (viewPoint.x - centrePoint.x) * cos(theta) + centrePoint.y);
//                viewPoints[i] = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
            }
            
//            const NSDecimal x = radiusBytes[i] * sin(thetaBytes[i]);
//            const NSDecimal y = radiusBytes[i] * cos(thetaBytes[i]);
//            if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
//                viewPoints[i] = CPTPointMake(NAN, NAN);
//            }
//            else {
//                NSDecimal plotPoint[2];
//                plotPoint[CPTCoordinateX] = x;
//                plotPoint[CPTCoordinateY] = y;
//
//                viewPoints[i] = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
//            }
        });
    }
}

-(void)alignViewPointsToUserSpace:(nonnull CGPoint *)viewPoints withContext:(nonnull CGContextRef)context drawPointFlags:(nonnull BOOL *)drawPointFlags numberOfPoints:(NSUInteger)dataCount
{
    // Align to device pixels if there is a data line.
    // Otherwise, align to view space, so fills are sharp at edges.
    if ( self.dataLineStyle.lineWidth > CPTFloat(0.0) ) {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                viewPoints[i] = CPTAlignPointToUserSpace(context, viewPoints[i]);
            }
        });
    }
    else {
        dispatch_apply(dataCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            if ( drawPointFlags[i] ) {
                viewPoints[i] = CPTAlignIntegralPointToUserSpace(context, viewPoints[i]);
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
#pragma mark View Points

/// @cond

-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
{
    return [self indexOfVisiblePointClosestToPlotAreaPoint:point];
}

/// @endcond

/** @brief Returns the index of the closest visible point to the point passed in.
 *  @param viewPoint The reference point.
 *  @return The index of the closest point, or @ref NSNotFound if there is no visible point.
 **/
-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint
{
    NSUInteger dataCount = self.cachedDataCount;
    CGPoint *viewPoints  = calloc( dataCount, sizeof(CGPoint) );
    BOOL *drawPointFlags = calloc( dataCount, sizeof(BOOL) );

    [self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES numberOfPoints:dataCount];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    NSInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];
    if ( result != NSNotFound ) {
        CGFloat minimumDistanceSquared = CPTNAN;
        for ( NSUInteger i = (NSUInteger)result; i < dataCount; ++i ) {
            if ( drawPointFlags[i] ) {
                CGFloat distanceSquared = squareOfDistanceBetweenPoints(viewPoint, viewPoints[i]);
                if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
                    minimumDistanceSquared = distanceSquared;
                    result                 = (NSInteger)i;
                }
            }
        }
    }

    free(viewPoints);
    free(drawPointFlags);

    return (NSUInteger)result;
}

/** @brief Returns the plot area view point of a visible point.
 *  @param idx The index of the point.
 *  @return The view point of the visible point at the index passed.
 **/
-(CGPoint)plotAreaPointOfVisiblePointAtIndex:(NSUInteger)idx
{
    NSParameterAssert(idx < self.cachedDataCount);

    CPTPolarPlotSpace *thePlotSpace = (CPTPolarPlotSpace *)self.plotSpace;
    CGPoint viewPoint;
    CGPoint centrePoint;

    if ( self.doublePrecisionCache ) {
        double plotPolar[2];
        double plotPoint[2];
        plotPolar[CPTPolarPlotFieldRadialAngle] = [self cachedDoubleForField:CPTPolarPlotFieldRadialAngle recordIndex:idx];
        plotPolar[CPTPolarPlotFieldRadius] = [self cachedDoubleForField:CPTPolarPlotFieldRadius recordIndex:idx];
//        plotPoint[CPTPolarPlotCoordinatesX] = plotPolar[CPTPolarPlotFieldRadius] * sin(plotPolar[CPTPolarPlotFieldRadialAngle]);
//        plotPoint[CPTPolarPlotCoordinatesY] = plotPolar[CPTPolarPlotFieldRadius] * cos(plotPolar[CPTPolarPlotFieldRadialAngle]);
        plotPoint[CPTPolarPlotCoordinatesX] = plotPolar[CPTPolarPlotFieldRadius];
        plotPoint[CPTPolarPlotCoordinatesY] = 0.0;
        
        double centrePlotPoint[2];
        centrePlotPoint[CPTPolarPlotCoordinatesX] = 0.0;
        centrePlotPoint[CPTPolarPlotCoordinatesY] = 0.0;
        
        centrePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:centrePlotPoint numberOfCoordinates:2];
        viewPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
        viewPoint = CPTPointMake((viewPoint.x - centrePoint.x) * sin(plotPolar[CPTPolarPlotFieldRadialAngle]) + centrePoint.x, (viewPoint.x - centrePoint.x) * cos(plotPolar[CPTPolarPlotFieldRadialAngle]) + centrePoint.y);
//        viewPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
    }
    else {
        
        NSDecimal plotPolar[2];
        NSDecimal plotPoint[2];
        plotPolar[CPTPolarPlotFieldRadialAngle] = [self cachedDecimalForField:CPTPolarPlotFieldRadialAngle recordIndex:idx];
        plotPolar[CPTPolarPlotFieldRadius] = [self cachedDecimalForField:CPTPolarPlotFieldRadius recordIndex:idx];
        
        NSDecimalNumber *_theta = [NSDecimalNumber decimalNumberWithDecimal:plotPolar[CPTPolarPlotFieldRadialAngle]];
        NSDecimalNumber *_radius = [NSDecimalNumber decimalNumberWithDecimal:plotPolar[CPTPolarPlotFieldRadius]];
        
//        plotPoint[CPTPolarPlotCoordinatesX] = [[NSDecimalNumber numberWithDouble:[_radius doubleValue] * sin([_theta doubleValue])] decimalValue];
//        plotPoint[CPTPolarPlotCoordinatesY] = [[NSDecimalNumber numberWithDouble:[_radius doubleValue] * cos([_theta doubleValue])] decimalValue];
        plotPoint[CPTPolarPlotCoordinatesX] = [[NSDecimalNumber numberWithDouble:[_radius doubleValue]] decimalValue];
        plotPoint[CPTPolarPlotCoordinatesY] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];

        NSDecimal centrePlotPoint[2];
        centrePlotPoint[CPTPolarPlotCoordinatesX] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];
        centrePlotPoint[CPTPolarPlotCoordinatesY] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];
        
        centrePoint = [thePlotSpace plotAreaViewPointForPlotPoint:centrePlotPoint numberOfCoordinates:2];
        viewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
        viewPoint = CPTPointMake((viewPoint.x - centrePoint.x) * sin([_theta doubleValue]) + centrePoint.x, (viewPoint.x - centrePoint.x) * cos([_theta doubleValue]) + centrePoint.y);
//        viewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
    }

    return viewPoint;
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(nonnull CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }
    
    CPTMutableNumericData *thetaValueData = [self cachedNumbersForField:CPTPolarPlotFieldRadialAngle];
    CPTMutableNumericData *radiusValueData = [self cachedNumbersForField:CPTPolarPlotFieldRadius];

    if ( (thetaValueData == nil) || (radiusValueData == nil) ) {
        return;
    }
    NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) {
        return;
    }
    if ( !(self.dataLineStyle || self.areaFill || self.areaFill2 || self.plotSymbol || self.plotSymbols.count) ) {
        return;
    }
    if ( thetaValueData.numberOfSamples != radiusValueData.numberOfSamples ) {
        [NSException raise:CPTException format:@"Number of theta and radius values do not match"];
    }

    [super renderAsVectorInContext:context];

    // Calculate view points, and align to user space
    CGPoint *viewPoints  = malloc( dataCount * sizeof(CGPoint) );
    BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

    CPTPolarPlotSpace *thePlotSpace = (CPTPolarPlotSpace *)self.plotSpace;
    [self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:dataCount];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];

    BOOL pixelAlign = self.alignsPointsToPixels;
    if ( pixelAlign ) {
        [self alignViewPointsToUserSpace:viewPoints withContext:context drawPointFlags:drawPointFlags numberOfPoints:dataCount];
    }
    
    CGPoint centrePoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:[[NSDecimalNumber numberWithDouble:0.0] decimalValue] Radius:[[NSDecimalNumber numberWithDouble:0.0] decimalValue]];
    if ( pixelAlign ) {
        centrePoint = CPTAlignIntegralPointToUserSpace(context, centrePoint);
    }
    
    // Get extreme points
    NSInteger lastDrawnPointIndex  = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:NO];
    NSInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];

    if ( firstDrawnPointIndex != NSNotFound ) {
        NSRange viewIndexmajorRange = NSMakeRange( (NSUInteger)firstDrawnPointIndex, (NSUInteger)(lastDrawnPointIndex - firstDrawnPointIndex + 1) );

        CPTLineStyle *theLineStyle          = self.dataLineStyle;
        CPTMutableLimitBandArray *fillBands = self.mutableAreaFillBands;

        // Draw fills
        NSDecimal theAreaBaseValue;
        CPTFill *theFill = nil;
        
        CGFloat height = CPTFloat( CGBitmapContextGetHeight(context) );
        CGFloat width = CPTFloat( CGBitmapContextGetWidth(context) );
        
        double centreToTopLeft = sqrt(pow((double)centrePoint.x, 2.0) + pow((double)height-(double)centrePoint.y, 2.0));
        double centreToTopRight = sqrt(pow((double)width-(double)centrePoint.x, 2.0) + pow((double)height-(double)centrePoint.y, 2.0));
        double centreToBtmRight = sqrt(pow((double)width-(double)centrePoint.x, 2.0) + pow((double)centrePoint.y, 2.0));
        double centreToBtmLeft = sqrt(pow((double)centrePoint.x, 2.0) + pow((double)centrePoint.y, 2.0));
        
        double maxLength = centreToTopLeft > centreToTopRight ? centreToTopLeft : centreToTopRight;
        maxLength = centreToBtmRight > maxLength ? centreToBtmRight : maxLength;
        if(centreToBtmLeft > maxLength)
            maxLength = centreToBtmLeft;
        
        for ( NSUInteger i = 0; i < 2; i++ ) {
            switch ( i ) {
                case 0:
                    theAreaBaseValue = self.areaBaseValue.decimalValue;
                    theFill          = self.areaFill;
                    break;

                case 1:
                    theAreaBaseValue = self.areaBaseValue2.decimalValue;
                    theFill          = self.areaFill2;
                    break;

                default:
                    theAreaBaseValue = CPTDecimalNaN();
                    break;
            }
            if ( !NSDecimalIsNotANumber(&theAreaBaseValue) ) {
                if ( theFill || ( (i == 0) && fillBands ) ) {
                    // clear the plot shadow if any--not needed for fills when the plot has a data line
                    if ( theLineStyle ) {
                        CGContextSaveGState(context);
                        CGContextSetShadowWithColor(context, CGSizeZero, CPTFloat(0.0), NULL);
                    }

                    CGPoint baseLinePoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:[[thetaValueData sampleValue:(NSUInteger)firstDrawnPointIndex] decimalValue] Radius:theAreaBaseValue];
                    if ( pixelAlign ) {
                        baseLinePoint = CPTAlignIntegralPointToUserSpace(context, baseLinePoint);
                    }
                    
                    CGFloat baselineRadiusValue = (CGFloat)sqrt((baseLinePoint.x-centrePoint.x)*(baseLinePoint.x-centrePoint.x)+(baseLinePoint.y-centrePoint.y)*(baseLinePoint.y-centrePoint.y));
                    
                    CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndexmajorRange baselineRadiusValue:baselineRadiusValue centrePoint:centrePoint];
                    
                    if ( theFill ) {

                        CGFloat startAngle = (CGFloat)[[thetaValueData sampleValue:(NSUInteger)firstDrawnPointIndex] floatValue];
                        CGFloat endAngle = (CGFloat)[[thetaValueData sampleValue:(NSUInteger)lastDrawnPointIndex] floatValue];
                        
//                        CGPoint firstPointAtBaselineRadius = CGPointMake(baselineRadiusValue*sin(startAngle)+centrePoint.x, baselineRadiusValue*cos(startAngle)+centrePoint.y);
//                        if ( pixelAlign ) {
//                            firstPointAtBaselineRadius = CPTAlignIntegralPointToUserSpace(context, firstPointAtBaselineRadius);
//                        }
//                        
//                        CGPoint lastPointAtBaselineRadius = CGPointMake(baselineRadiusValue*sin(endAngle)+centrePoint.x, baselineRadiusValue*cos(endAngle)+centrePoint.y);
//                        if ( pixelAlign ) {
//                            lastPointAtBaselineRadius = CPTAlignIntegralPointToUserSpace(context, lastPointAtBaselineRadius);
//                        }
                        
//                        CGPoint firstOuterPoint = CGPointMake(maxLength * sin(startAngle)+centrePoint.x, maxLength * cos(startAngle)+centrePoint.y);
//                        CGPoint lastOuterPoint = CGPointMake(maxLength * sin(endAngle)+centrePoint.x, maxLength * cos(endAngle)+centrePoint.y);
//                        
                        CGPoint firstPoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:[[thetaValueData sampleValue:(NSUInteger)firstDrawnPointIndex] decimalValue] Radius:[[radiusValueData sampleValue:(NSUInteger)firstDrawnPointIndex] decimalValue]];
                        if ( pixelAlign ) {
                            firstPoint = CPTAlignIntegralPointToUserSpace(context, firstPoint);
                        }
                        
                        CGPoint lastPoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:[[thetaValueData sampleValue:(NSUInteger)lastDrawnPointIndex] decimalValue] Radius:[[radiusValueData sampleValue:(NSUInteger)lastDrawnPointIndex] decimalValue]];
                        if ( pixelAlign ) {
                            lastPoint = CPTAlignIntegralPointToUserSpace(context, lastPoint);
                        }
                        
                        CGContextSaveGState(context);
                        
                        CGMutablePathRef baseLinePath = CGPathCreateMutable();
                        
                        
                        if (baselineRadiusValue != 0.0) {
                            CGFloat startAngleToTop, endAngleToTop;
                            CGFloat diff = 0.0;
                            if(startAngle >= (CGFloat)0.0 && startAngle < (CGFloat)M_PI && endAngle >= (CGFloat)0.0 && endAngle < (CGFloat)M_PI)
                                diff = startAngle - endAngle;
                            else if(startAngle >= (CGFloat)M_PI && startAngle < (CGFloat)(2.0*M_PI) && endAngle >= (CGFloat)M_PI && endAngle < (CGFloat)(2.0*M_PI))
                                diff = endAngle - startAngle;
                            else {
                                if(startAngle < (CGFloat)M_PI)
                                    startAngleToTop = startAngle;
                                else
                                    startAngleToTop = (CGFloat)(2.0*M_PI) - startAngle;
                                
                                if(endAngle < (CGFloat)M_PI)
                                    endAngleToTop = endAngle;
                                else
                                    endAngleToTop = (CGFloat)(2.0*M_PI) - endAngle;
                                
                                diff = endAngleToTop - startAngleToTop;
                            }
                            
                            CGPathAddArc(baseLinePath, NULL, centrePoint.x, centrePoint.y, baselineRadiusValue, startAngle+diff-(CGFloat)(M_PI_2*3.0), endAngle+diff-(CGFloat)(M_PI_2*3.0), NO);
                            
                            if( firstPoint.x != lastPoint.x && firstPoint.y != lastPoint.y) {
                                CGPathMoveToPoint(baseLinePath, NULL, firstPoint.x, firstPoint.y);
                                CGPathAddLineToPoint(baseLinePath, NULL, centrePoint.x, centrePoint.y);
                                CGPathAddLineToPoint(baseLinePath, NULL, lastPoint.x, lastPoint.y);
//                                if( firstPointAtBaselineRadius.x != lastPointAtBaselineRadius.x && firstPointAtBaselineRadius.y != lastPointAtBaselineRadius.y) {
//                                    CGPathMoveToPoint(baseLinePath, NULL, firstPointAtBaselineRadius.x, firstPointAtBaselineRadius.y);
//                                    CGPathAddLineToPoint(baseLinePath, NULL, firstPoint.x, firstPoint.y);
//                                    CGPathMoveToPoint(baseLinePath, NULL, lastPointAtBaselineRadius.x, lastPointAtBaselineRadius.y);
//                                    CGPathAddLineToPoint(baseLinePath, NULL, lastPoint.x, lastPoint.y);
//                                    CGPathAddLineToPoint(baseLinePath, NULL, firstPoint.x, firstPoint.y);
//                                }
                            }
                        }
                        else {
                            CGPathMoveToPoint(baseLinePath, NULL, lastPoint.x, lastPoint.y);
                            CGPathAddLineToPoint(baseLinePath, NULL, centrePoint.x, centrePoint.y);
                            CGPathAddLineToPoint(baseLinePath, NULL, firstPoint.x, firstPoint.y);
                        }
                        
                        CGContextAddPath(context, baseLinePath);
                        
                        // Draw stroke path
                        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
                        CGContextSetLineWidth(context, 0.5);
                        CGContextDrawPath(context, kCGPathStroke);
                        
                        CGContextRestoreGState(context);
                        
                        CGContextClip(context);
                        
 //                       CGPathCloseSubpath(dataLinePath);
                        
                        CGContextBeginPath(context);
                        CGContextAddPath(context, dataLinePath);
                        CGContextAddPath(context, baseLinePath);
                        [theFill fillPathInContext:context];
                        
                        
                        CGPathRelease(baseLinePath);
                    }

                    // Draw fill bands
                    if ( (i == 0) && fillBands ) {
                        

                        for ( CPTLimitBand *band in fillBands )
                        {
                            CGContextSaveGState(context);
                            CPTPlotRange *bandRange = band.range;
                            if(((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
                                bandRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithDouble:bandRange.locationDouble*M_PI/180.0] length:[NSNumber numberWithDouble:bandRange.lengthDouble*M_PI/180.0]];
                            
                            
                            CGMutablePathRef clippedBandAreaPath = CGPathCreateMutable();
                            CGPathMoveToPoint(clippedBandAreaPath, NULL, centrePoint.x, centrePoint.y);
                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, centrePoint.x + (CGFloat)(sin(bandRange.maxLimitDouble) * maxLength), centrePoint.y + (CGFloat)(cos(bandRange.maxLimitDouble) * maxLength));
                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, centrePoint.x + (CGFloat)(sin(bandRange.minLimitDouble) * maxLength), centrePoint.y + (CGFloat)(cos(bandRange.minLimitDouble) * maxLength));
                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, centrePoint.x, centrePoint.y);
                            
                            CGContextAddPath(context, clippedBandAreaPath);
                            CGContextClip(context);
                            
//                            CGPathCloseSubpath(dataLinePath);
                            
                            CGContextBeginPath(context);
                            CGContextAddPath(context, dataLinePath);
                            [band.fill fillPathInContext:context];
                            CGContextRestoreGState(context);
                        
                            CGPathRelease(clippedBandAreaPath);
                        }
                    }

                    CGPathRelease(dataLinePath);

                    if ( theLineStyle ) {
                        CGContextRestoreGState(context);
                    }
                }
            }
        }

        // Draw line
        if ( theLineStyle ) {
            CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndexmajorRange baselineRadiusValue:CPTNAN centrePoint:centrePoint];

            // Give the delegate a chance to prepare for the drawing.
            id<CPTPolarPlotDelegate> theDelegate = (id<CPTPolarPlotDelegate>)self.delegate;
            if ( [theDelegate respondsToSelector:@selector(polarPlot:prepareForDrawingPlotLine:inContext:)] ) {
                [theDelegate polarPlot:self prepareForDrawingPlotLine:dataLinePath inContext:context];
            }

            CGContextBeginPath(context);
            CGContextAddPath(context, dataLinePath);
            [theLineStyle setLineStyleInContext:context];
            [theLineStyle strokePathInContext:context];
            CGPathRelease(dataLinePath);
        }

        // Draw plot symbols
        if ( self.plotSymbol || self.plotSymbols.count ) {
            Class symbolClass = [CPTPlotSymbol class];

            // clear the plot shadow if any--symbols draw their own shadows
            CGContextSetShadowWithColor(context, CGSizeZero, CPTFloat(0.0), NULL);

            if ( self.useFastRendering ) {
                CGFloat scale = self.contentsScale;
                for ( NSUInteger i = (NSUInteger)firstDrawnPointIndex; i <= (NSUInteger)lastDrawnPointIndex; i++ ) {
                    if ( drawPointFlags[i] ) {
                        CPTPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
                        if ( [currentSymbol isKindOfClass:symbolClass] ) {
                            [currentSymbol renderInContext:context atPoint:viewPoints[i] scale:scale alignToPixels:pixelAlign];
                        }
                    }
                }
            }
            else {
                for ( NSUInteger i = (NSUInteger)firstDrawnPointIndex; i <= (NSUInteger)lastDrawnPointIndex; i++ ) {
                    if ( drawPointFlags[i] ) {
                        CPTPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
                        if ( [currentSymbol isKindOfClass:symbolClass] ) {
                            [currentSymbol renderAsVectorInContext:context atPoint:viewPoints[i] scale:CPTFloat(1.0)];
                        }
                    }
                }
            }
        }
    }

    free(viewPoints);
    free(drawPointFlags);
}

- (CGPoint)translatedPolarCoordinatesToContextCoordinatesWithFromTheta:(NSDecimal)thetaValue Radius:(NSDecimal)radiusValue
{
    NSDecimal plotPoint[2];
    NSDecimal plotPolar[2];
    plotPolar[CPTPolarPlotFieldRadialAngle] = thetaValue;
    plotPolar[CPTPolarPlotFieldRadius] = radiusValue;
    
    NSDecimalNumber *_theta = [NSDecimalNumber decimalNumberWithDecimal:plotPolar[CPTPolarPlotFieldRadialAngle]];
    NSDecimalNumber *_radius = [NSDecimalNumber decimalNumberWithDecimal:plotPolar[CPTPolarPlotFieldRadius]];
    
    plotPoint[CPTPolarPlotCoordinatesX] = [[NSDecimalNumber numberWithDouble:[_radius doubleValue] * sin([_theta doubleValue])] decimalValue];
    plotPoint[CPTPolarPlotCoordinatesY] = [[NSDecimalNumber numberWithDouble:[_radius doubleValue] * cos([_theta doubleValue])] decimalValue];
    
    CGPoint point = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2] fromLayer:self.plotArea];
    
    return point;
}

-(nonnull CGPathRef)newDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineRadiusValue:(CGFloat)baselineRadiusValue centrePoint:(CGPoint)centrePoint
{
    CPTPolarPlotInterpolation theInterpolation = self.interpolation;

    if ( theInterpolation == CPTPolarPlotInterpolationCurved ) {
        return [self newCurvedDataLinePathForViewPoints:viewPoints indexRange:indexRange baselineRadiusValue:baselineRadiusValue centrePoint:centrePoint];
    }

    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    BOOL lastPointSkipped          = YES;
    CGPoint firstPoint             = CGPointZero;
    CGPoint lastPoint              = CGPointZero;
    NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);
    

    if ( lastDrawnPointIndex > 0 ) {
        lastDrawnPointIndex--;
    }

    for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
        CGPoint viewPoint = viewPoints[i];

        if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
            if ( !lastPointSkipped ) {
                if ( !isnan(baselineRadiusValue) ) {
                    CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
                    CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, firstPoint.y);
                    CGPathCloseSubpath(dataLinePath);
                }
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
                switch ( theInterpolation ) {
                    case CPTPolarPlotInterpolationLinear:
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        break;

                    case CPTPolarPlotInterpolationStepped:
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, lastPoint.y);
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        break;

                    case CPTPolarPlotInterpolationHistogram:
                    {
                        CGFloat x = (lastPoint.x + viewPoint.x) / CPTFloat(2.0);
                        if ( CPTPolarPlotHistogramSkipFirst != self.histogramOption ) {
                            CGPathAddLineToPoint(dataLinePath, NULL, x, lastPoint.y);
                        }
                        if ( CPTPolarPlotHistogramSkipSecond != self.histogramOption ) {
                            CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoint.y);
                        }
                        CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                    }
                    break;

                    case CPTPolarPlotInterpolationCurved:
                        // Curved plot lines handled separately
                        break;
                }
            }
            lastPoint = viewPoint;
        }
    }

    if ( !lastPointSkipped && !isnan(baselineRadiusValue) ) {
        CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
        CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, firstPoint.y);
        CGPathCloseSubpath(dataLinePath);
    }

    return dataLinePath;
}

-(nonnull CGPathRef)newCurvedDataLinePathForViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineRadiusValue:(CGFloat)baselineRadiusValue centrePoint:(CGPoint)centrePoint
{
    CGMutablePathRef dataLinePath  = CGPathCreateMutable();
    BOOL lastPointSkipped          = YES;
    CGPoint firstPoint             = CGPointZero;
    CGPoint lastPoint              = CGPointZero;
    NSUInteger firstIndex          = indexRange.location;
    NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);

    CPTPolarPlotCurvedInterpolationOption interpolationOption = self.curvedInterpolationOption;

    if ( lastDrawnPointIndex > 0 ) {
        CGPoint *controlPoints1 = calloc( lastDrawnPointIndex, sizeof(CGPoint) );
        CGPoint *controlPoints2 = calloc( lastDrawnPointIndex, sizeof(CGPoint) );

        lastDrawnPointIndex--;

        // Compute control points for each sub-range
        for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
            CGPoint viewPoint = viewPoints[i];

            if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
                if ( !lastPointSkipped ) {
                    switch ( interpolationOption ) {
                        case CPTPolarPlotCurvedInterpolationNormal:
                            [self computeBezierControlPoints:controlPoints1
                                                     points2:controlPoints2
                                               forViewPoints:viewPoints
                                                  indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTPolarPlotCurvedInterpolationCatmullRomUniform:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:CPTFloat(0.0)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTPolarPlotCurvedInterpolationCatmullRomCentripetal:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:CPTFloat(0.5)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTPolarPlotCurvedInterpolationCatmullRomChordal:
                            [self computeCatmullRomControlPoints:controlPoints1
                                                         points2:controlPoints2
                                                       withAlpha:CPTFloat(1.0)
                                                   forViewPoints:viewPoints
                                                      indexRange:NSMakeRange(firstIndex, i - firstIndex)];

                            break;

                        case CPTPolarPlotCurvedInterpolationHermiteCubic:
                            [self computeHermiteControlPoints:controlPoints1
                                                      points2:controlPoints2
                                                forViewPoints:viewPoints
                                                   indexRange:NSMakeRange(firstIndex, i - firstIndex)];
                            break;

                        case CPTPolarPlotCurvedInterpolationCatmullCustomAlpha:
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
                case CPTPolarPlotCurvedInterpolationNormal:
                    [self computeBezierControlPoints:controlPoints1
                                             points2:controlPoints2
                                       forViewPoints:viewPoints
                                          indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTPolarPlotCurvedInterpolationCatmullRomUniform:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:CPTFloat(0.0)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];

                    break;

                case CPTPolarPlotCurvedInterpolationCatmullRomCentripetal:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:CPTFloat(0.5)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTPolarPlotCurvedInterpolationCatmullRomChordal:
                    [self computeCatmullRomControlPoints:controlPoints1
                                                 points2:controlPoints2
                                               withAlpha:CPTFloat(1.0)
                                           forViewPoints:viewPoints
                                              indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];

                    break;

                case CPTPolarPlotCurvedInterpolationHermiteCubic:
                    [self computeHermiteControlPoints:controlPoints1
                                              points2:controlPoints2
                                        forViewPoints:viewPoints
                                           indexRange:NSMakeRange(firstIndex, NSMaxRange(indexRange) - firstIndex)];
                    break;

                case CPTPolarPlotCurvedInterpolationCatmullCustomAlpha:
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
                    if ( !isnan(baselineRadiusValue) ) {
                        CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
                        CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, firstPoint.y);
                        CGPathCloseSubpath(dataLinePath);
                    }
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
                    CGPathMoveToPoint( dataLinePath, NULL, cp1.x, cp1.y - CPTFloat(5.0) );
                    CGPathAddLineToPoint( dataLinePath, NULL, cp1.x, cp1.y + CPTFloat(5.0) );

                    CGPathMoveToPoint( dataLinePath, NULL, cp2.x - CPTFloat(3.5), cp2.y - CPTFloat(3.5) );
                    CGPathAddLineToPoint( dataLinePath, NULL, cp2.x + CPTFloat(3.5), cp2.y + CPTFloat(3.5) );
                    CGPathMoveToPoint( dataLinePath, NULL, cp2.x + CPTFloat(3.5), cp2.y - CPTFloat(3.5) );
                    CGPathAddLineToPoint( dataLinePath, NULL, cp2.x - CPTFloat(3.5), cp2.y + CPTFloat(3.5) );

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

        if ( !lastPointSkipped && !isnan(baselineRadiusValue) ) {
            CGPathMoveToPoint(dataLinePath, NULL, lastPoint.x, lastPoint.y);
            CGPathAddLineToPoint(dataLinePath, NULL, firstPoint.x, firstPoint.y);
            CGPathCloseSubpath(dataLinePath);
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
-(void)computeCatmullRomControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 withAlpha:(CGFloat)alpha forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange
{
    if ( indexRange.length >= 2 ) {
        NSUInteger startIndex   = indexRange.location;
        NSUInteger endIndex     = NSMaxRange(indexRange) - 1; // the index starts at zero
        NSUInteger segmentCount = endIndex - 1;               // there are n - 1 segments

        CGFloat epsilon = CPTFloat(1.0e-5); // the minimum point distance. below that no interpolation happens.

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
            CGFloat d1_a  = pow(d1, alpha);             // d1^alpha
            CGFloat d2_a  = pow(d2, alpha);             // d2^alpha
            CGFloat d3_a  = pow(d3, alpha);             // d3^alpha
            CGFloat d1_2a = pow( d1_a, CPTFloat(2.0) ); // d1^alpha^2 = d1^2*alpha
            CGFloat d2_2a = pow( d2_a, CPTFloat(2.0) ); // d2^alpha^2 = d2^2*alpha
            CGFloat d3_2a = pow( d3_a, CPTFloat(2.0) ); // d3^alpha^2 = d3^2*alpha

            // calculate the control points
            // see : http://www.cemyuksel.com/research/catmullrom_param/catmullrom.pdf under point 3.
            CGPoint cp1, cp2; // the calculated view points;
            if ( fabs(d1) <= epsilon ) {
                cp1 = p1;
            }
            else {
                CGFloat divisor = CPTFloat(3.0) * d1_a * (d1_a + d2_a);
                cp1 = CPTPointMake( (p2.x * d1_2a - p0.x * d2_2a + (2 * d1_2a + 3 * d1_a * d2_a + d2_2a) * p1.x) / divisor,
                                    (p2.y * d1_2a - p0.y * d2_2a + (2 * d1_2a + 3 * d1_a * d2_a + d2_2a) * p1.y) / divisor
                                     );
            }

            if ( fabs(d3) <= epsilon ) {
                cp2 = p2;
            }
            else {
                CGFloat divisor = 3 * d3_a * (d3_a + d2_a);
                cp2 = CPTPointMake( (d3_2a * p1.x - d2_2a * p3.x + (2 * d3_2a + 3 * d3_a * d2_a + d2_2a) * p2.x) / divisor,
                                    (d3_2a * p1.y - d2_2a * p3.y + (2 * d3_2a + 3 * d3_a * d2_a + d2_2a) * p2.y) / divisor );
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
-(void)computeHermiteControlPoints:(nonnull CGPoint *)points points2:(nonnull CGPoint *)points2 forViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange
{
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
                    if ( m.dx > CPTFloat(0.0) ) {
                        m.dx = MIN(p2.x - p1.x, p1.x - p0.x);
                    }
                    else if ( m.dx < CPTFloat(0.0) ) {
                        m.dx = MAX(p2.x - p1.x, p1.x - p0.x);
                    }

                    if ( m.dy > CPTFloat(0.0) ) {
                        m.dy = MIN(p2.y - p1.y, p1.y - p0.y);
                    }
                    else if ( m.dy < CPTFloat(0.0) ) {
                        m.dy = MAX(p2.y - p1.y, p1.y - p0.y);
                    }
                }
            }

            // get control points
            m.dx /= CPTFloat(6.0);
            m.dy /= CPTFloat(6.0);

            CGPoint rhsControlPoint = CPTPointMake(p1.x + m.dx, p1.y + m.dy);
            CGPoint lhsControlPoint = CPTPointMake(p1.x - m.dx, p1.y - m.dy);

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
-(BOOL)monotonicViewPoints:(nonnull CGPoint *)viewPoints indexRange:(NSRange)indexRange
{
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
        CGPoint *a = malloc( n * sizeof(CGPoint) );
        CGPoint *b = malloc( n * sizeof(CGPoint) );
        CGPoint *c = malloc( n * sizeof(CGPoint) );
        CGPoint *r = malloc( n * sizeof(CGPoint) );

        // left most segment
        a[0] = CGPointZero;
        b[0] = CPTPointMake(2.0, 2.0);
        c[0] = CPTPointMake(1.0, 1.0);

        CGPoint pt0 = viewPoints[indexRange.location];
        CGPoint pt1 = viewPoints[indexRange.location + 1];
        r[0] = CGPointMake(pt0.x + CPTFloat(2.0) * pt1.x,
                           pt0.y + CPTFloat(2.0) * pt1.y);

        // internal segments
        for ( NSUInteger i = 1; i < n - 1; i++ ) {
            a[i] = CPTPointMake(1.0, 1.0);
            b[i] = CPTPointMake(4.0, 4.0);
            c[i] = CPTPointMake(1.0, 1.0);

            CGPoint pti  = viewPoints[indexRange.location + i];
            CGPoint pti1 = viewPoints[indexRange.location + i + 1];
            r[i] = CGPointMake(CPTFloat(4.0) * pti.x + CPTFloat(2.0) * pti1.x,
                               CPTFloat(4.0) * pti.y + CPTFloat(2.0) * pti1.y);
        }

        // right segment
        a[n - 1] = CPTPointMake(2.0, 2.0);
        b[n - 1] = CPTPointMake(7.0, 7.0);
        c[n - 1] = CGPointZero;

        CGPoint ptn1 = viewPoints[indexRange.location + n - 1];
        CGPoint ptn  = viewPoints[indexRange.location + n];
        r[n - 1] = CGPointMake(CPTFloat(8.0) * ptn1.x + ptn.x,
                               CPTFloat(8.0) * ptn1.y + ptn.y);

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
            cp2[i] = CGPointMake(CPTFloat(2.0) * viewPoints[i].x - cp1[i + 1].x,
                                 CPTFloat(2.0) * viewPoints[i].y - cp1[i + 1].y);
        }

        cp2[rangeEnd] = CGPointMake( CPTFloat(0.5) * (viewPoints[rangeEnd].x + cp1[rangeEnd].x),
                                     CPTFloat(0.5) * (viewPoints[rangeEnd].y + cp1[rangeEnd].y) );

        // clean up
        free(a);
        free(b);
        free(c);
        free(r);
    }
}

-(void)drawSwatchForLegend:(nonnull CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(nonnull CGContextRef)context
{
    [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];

    if ( self.drawLegendSwatchDecoration ) {
        CPTLineStyle *theLineStyle = self.dataLineStyle;

        if ( theLineStyle ) {
            [theLineStyle setLineStyleInContext:context];

            CGPoint alignedStartPoint = CPTAlignPointToUserSpace( context, CPTPointMake( CGRectGetMinX(rect), CGRectGetMidY(rect) ) );
            CGPoint alignedEndPoint   = CPTAlignPointToUserSpace( context, CPTPointMake( CGRectGetMaxX(rect), CGRectGetMidY(rect) ) );
            CGContextMoveToPoint(context, alignedStartPoint.x, alignedStartPoint.y);
            CGContextAddLineToPoint(context, alignedEndPoint.x, alignedEndPoint.y);

            [theLineStyle strokePathInContext:context];
        }

        CPTPlotSymbol *thePlotSymbol = self.plotSymbol;

        if ( thePlotSymbol ) {
            [thePlotSymbol renderInContext:context
                                   atPoint:CPTPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect) )
                                     scale:self.contentsScale
                             alignToPixels:YES];
        }

        // if no line or plot symbol, use the area fills to draw the swatch
        if ( !theLineStyle && !thePlotSymbol ) {
            CPTFill *fill1 = self.areaFill;
            CPTFill *fill2 = self.areaFill2;

            if ( fill1 || fill2 ) {
                CGPathRef swatchPath = CPTCreateRoundedRectPath(CPTAlignIntegralRectToUserSpace(context, rect), legend.swatchCornerRadius);

                if ( fill1 && !fill2 ) {
                    CGContextBeginPath(context);
                    CGContextAddPath(context, swatchPath);
                    [fill1 fillPathInContext:context];
                }
                else if ( !fill1 && fill2 ) {
                    CGContextBeginPath(context);
                    CGContextAddPath(context, swatchPath);
                    [fill2 fillPathInContext:context];
                }
                else {
                    CGContextSaveGState(context);
                    CGContextAddPath(context, swatchPath);
                    CGContextClip(context);

                    if ( CPTDecimalGreaterThanOrEqualTo(self.areaBaseValue2.decimalValue, self.areaBaseValue.decimalValue) ) {
                        [fill1 fillRect:CPTRectMake( CGRectGetMinX(rect), CGRectGetMinY(rect), rect.size.width, rect.size.height / CPTFloat(2.0) ) inContext:context];
                        [fill2 fillRect:CPTRectMake( CGRectGetMinX(rect), CGRectGetMidY(rect), rect.size.width, rect.size.height / CPTFloat(2.0) ) inContext:context];
                    }
                    else {
                        [fill2 fillRect:CPTRectMake( CGRectGetMinX(rect), CGRectGetMinY(rect), rect.size.width, rect.size.height / CPTFloat(2.0) ) inContext:context];
                        [fill1 fillRect:CPTRectMake( CGRectGetMinX(rect), CGRectGetMidY(rect), rect.size.width, rect.size.height / CPTFloat(2.0) ) inContext:context];
                    }

                    CGContextRestoreGState(context);
                }

                CGPathRelease(swatchPath);
            }
        }
    }
}

-(nonnull CGPathRef)newDataLinePath
{
    [self reloadDataIfNeeded];

    NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) {
        return CGPathCreateMutable();
    }

    // Calculate view points
    CGPoint *viewPoints  = malloc( dataCount * sizeof(CGPoint) );
    BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

    for ( NSUInteger i = 0; i < dataCount; i++ ) {
        drawPointFlags[i] = YES;
    }

    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];
    
    // Create the path
    CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:NSMakeRange(0, dataCount) baselineRadiusValue:CPTNAN centrePoint:CGPointZero];

    free(viewPoints);
    free(drawPointFlags);

    return dataLinePath;
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(nonnull NSString *)aKey
{
    static NSSet<NSString *> *keys = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithArray:@[@"areaBaseValue",
                                     @"areaBaseValue2"]];
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
#pragma mark Data Ranges

/// @cond

-(nullable CPTPlotRange *)plotRangeEnclosingField:(NSUInteger)fieldEnum
{
    CPTPlotRange *range = [self plotRangeForField:fieldEnum];

    if ( self.interpolation == CPTPolarPlotInterpolationCurved ) {
        CPTPlotSpace *space = self.plotSpace;

        if ( space ) {
            CGPathRef dataLinePath = self.newDataLinePath;

            CGRect boundingBox = CGPathGetBoundingBox(dataLinePath);

            CGPathRelease(dataLinePath);

            CPTNumberArray *lowerLeft  = [space plotPointForPlotAreaViewPoint:boundingBox.origin];
            CPTNumberArray *upperRight = [space plotPointForPlotAreaViewPoint:CGPointMake( CGRectGetMaxX(boundingBox),
                                                                                           CGRectGetMaxY(boundingBox) )];

            switch ( fieldEnum ) {
                case CPTPolarPlotCoordinatesX:
                {
                    NSNumber *length = [NSDecimalNumber decimalNumberWithDecimal:
                                        CPTDecimalSubtract(upperRight[CPTCoordinateX].decimalValue,
                                                           lowerLeft[CPTCoordinateX].decimalValue)];
                    range = [CPTPlotRange plotRangeWithLocation:lowerLeft[CPTCoordinateX]
                                                         length:length];
                }
                break;

                case CPTPolarPlotCoordinatesY:
                {
                    NSNumber *length = [NSDecimalNumber decimalNumberWithDecimal:
                                        CPTDecimalSubtract(upperRight[CPTCoordinateY].decimalValue,
                                                           lowerLeft[CPTCoordinateY].decimalValue)];
                    range = [CPTPlotRange plotRangeWithLocation:lowerLeft[CPTCoordinateY]
                                                         length:length];
                }
                break;
                    
                case CPTPolarPlotCoordinatesZ:
                {
                    NSNumber *length = [NSDecimalNumber decimalNumberWithDecimal:
                                        CPTDecimalSubtract(upperRight[CPTCoordinateY].decimalValue,
                                                           lowerLeft[CPTCoordinateY].decimalValue)];
                    range = [CPTPlotRange plotRangeWithLocation:lowerLeft[CPTCoordinateY]
                                                         length:length];
                }
                    break;

                default:
                    break;
            }
        }
    }

    return range;
}

/// @endcond

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
    return 2;
}

-(nonnull CPTNumberArray *)fieldIdentifiers
{
    return @[@(CPTPolarPlotFieldRadialAngle), @(CPTPolarPlotFieldRadius)];
}

-(nonnull CPTNumberArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
    CPTNumberArray *result = nil;

    switch ( coord ) {
        case CPTCoordinateX:
            result = @[@(CPTPolarPlotFieldRadius)];
            break;

        case CPTCoordinateY:
            result = @[@(CPTPolarPlotFieldRadius)];
            break;
        
        case CPTCoordinateZ:
            result = @[@(CPTPolarPlotFieldRadialAngle)];
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
        case CPTPolarPlotFieldRadialAngle:
            coordinate = CPTCoordinateX;
            break;

        case CPTPolarPlotFieldRadius:
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
    NSNumber *thetaValue = [self cachedNumberForField:CPTPolarPlotFieldRadialAngle recordIndex:idx];
    NSNumber *radiusValue = [self cachedNumberForField:CPTPolarPlotFieldRadius recordIndex:idx];
    
    NSNumber *xValue = [NSNumber numberWithDouble:[radiusValue doubleValue] * sin([thetaValue doubleValue])];
    NSNumber *yValue = [NSNumber numberWithDouble:[radiusValue doubleValue] * cos([thetaValue doubleValue])];

    BOOL positiveDirection = YES;
    CPTPlotRange *minorRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

    if ( CPTDecimalLessThan( minorRange.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
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
#pragma mark Area Fill Bands

/** @brief Add an area fill limit band.
 *
 *  The band will be drawn on top of the @ref areaFill between the plot line and the @ref areaBaseValue.
 *
 *  @param limitBand The new limit band.
 **/
-(void)addAreaFillBand:(nullable CPTLimitBand *)limitBand
{
    if ( [limitBand isKindOfClass:[CPTLimitBand class]] ) {
        if ( !self.mutableAreaFillBands ) {
            self.mutableAreaFillBands = [NSMutableArray array];
        }

        CPTLimitBand *band = limitBand;
        [self.mutableAreaFillBands addObject:band];

        [self setNeedsDisplay];
    }
}

/** @brief Remove an area fill limit band.
 *  @param limitBand The limit band to be removed.
 **/
-(void)removeAreaFillBand:(nullable CPTLimitBand *)limitBand
{
    if ( limitBand ) {
        CPTMutableLimitBandArray *fillBands = self.mutableAreaFillBands;

        CPTLimitBand *band = limitBand;
        [fillBands removeObject:band];

        if ( fillBands.count == 0 ) {
            self.mutableAreaFillBands = nil;
        }

        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly started touching the screen. @endif
 *
 *
 *  If this plot has a delegate that responds to the
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolTouchDownAtRecordIndex: -polarPlot:plotSymbolTouchDownAtRecordIndex: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent: -polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolWasSelectedAtRecordIndex: -polarPlot:plotSymbolWasSelectedAtRecordIndex: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent: -polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, the data points are searched to find the index of the one closest to the @par{interactionPoint}.
 *  The 'touchDown' delegate method(s) will be called and this method will return @YES if the @par{interactionPoint} is within the
 *  @ref plotSymbolMarginForHitDetection of the closest data point.
 *  Then, if no plot symbol was hit or @ref allowSimultaneousSymbolAndPlotSelection is @YES and if this plot has
 *  a delegate that responds to the
 *  @link CPTPolarPlotDelegate::polarPlotDataLineTouchDown: -polarPlotDataLineTouchDown: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:dataLineTouchDownWithEvent: -polarPlot:dataLineTouchDownWithEvent: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlotDataLineWasSelected: -polarPlotDataLineWasSelected: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:dataLineWasSelectedWithEvent: -polarPlot:dataLineWasSelectedWithEvent: @endlink
 *  methods and the @par{interactionPoint} falls within @ref plotLineMarginForHitDetection points of the plot line,
 *  then the 'dataLineTouchDown' delegate method(s) will be called and this method will return @YES.
 *  This method returns @NO if the @par{interactionPoint} is not within @ref plotSymbolMarginForHitDetection points of any of
 *  the data points or within @ref plotLineMarginForHitDetection points of the plot line.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    self.pointingDeviceDownIndex  = NSNotFound;
    self.pointingDeviceDownOnLine = NO;

    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;

    if ( !theGraph || !thePlotArea || self.hidden ) {
        return NO;
    }

    id<CPTPolarPlotDelegate> theDelegate = (id<CPTPolarPlotDelegate>)self.delegate;
    BOOL symbolTouchUpHandled              = NO;

    if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchDownAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self indexOfVisiblePointClosestToPlotAreaPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            CGPoint center        = [self plotAreaPointOfVisiblePointAtIndex:idx];
            CPTPlotSymbol *symbol = [self plotSymbolForRecordIndex:idx];

            CGRect symbolRect = CGRectZero;
            if ( [symbol isKindOfClass:[CPTPlotSymbol class]] ) {
                symbolRect.size = symbol.size;
            }
            else {
                symbolRect.size = CGSizeZero;
            }
            CGFloat margin = self.plotSymbolMarginForHitDetection * CPTFloat(2.0);
            symbolRect.size.width  += margin;
            symbolRect.size.height += margin;
            symbolRect.origin       = CPTPointMake( center.x - CPTFloat(0.5) * CGRectGetWidth(symbolRect), center.y - CPTFloat(0.5) * CGRectGetHeight(symbolRect) );

            if ( CGRectContainsPoint(symbolRect, plotAreaPoint) ) {
                self.pointingDeviceDownIndex = idx;

                if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchDownAtRecordIndex:)] ) {
                    symbolTouchUpHandled = YES;
                    [theDelegate polarPlot:self plotSymbolTouchDownAtRecordIndex:idx];
                }
                if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent:)] ) {
                    symbolTouchUpHandled = YES;
                    [theDelegate polarPlot:self plotSymbolTouchDownAtRecordIndex:idx withEvent:event];
                }
            }
        }
    }

    BOOL plotTouchUpHandled = NO;
    BOOL plotSelected       = NO;

    if ( self.dataLineStyle &&
         (!symbolTouchUpHandled || self.allowSimultaneousSymbolAndPlotSelection) &&
         ([theDelegate respondsToSelector:@selector(polarPlotDataLineTouchDown:)] ||
          [theDelegate respondsToSelector:@selector(polarPlot:dataLineTouchDownWithEvent:)] ||
          [theDelegate respondsToSelector:@selector(polarPlotDataLineWasSelected:)] ||
          [theDelegate respondsToSelector:@selector(polarPlot:dataLineWasSelectedWithEvent:)]) ) {
        plotSelected = [self plotWasLineHitByInteractionPoint:interactionPoint];
        if ( plotSelected ) {
            // Let the delegate know that the plot was selected.
            self.pointingDeviceDownOnLine = YES;

            if ( [theDelegate respondsToSelector:@selector(polarPlotDataLineTouchDown:)] ) {
                plotTouchUpHandled = YES;
                [theDelegate polarPlotDataLineTouchDown:self];
            }
            if ( [theDelegate respondsToSelector:@selector(polarPlot:dataLineTouchDownWithEvent:)] ) {
                plotTouchUpHandled = YES;
                [theDelegate polarPlot:self dataLineTouchDownWithEvent:event];
            }
        }
    }

    if ( symbolTouchUpHandled || plotTouchUpHandled ) {
        return YES;
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
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolTouchDownAtRecordIndex: -polarPlot:plotSymbolTouchDownAtRecordIndex: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent: -polarPlot:plotSymbolTouchDownAtRecordIndex:withEvent: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolWasSelectedAtRecordIndex: -polarPlot:plotSymbolWasSelectedAtRecordIndex: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent: -polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent: @endlink
 *  methods, the data points are searched to find the index of the one closest to the @par{interactionPoint}.
 *  The 'touchDown' delegate method(s) will be called and this method will return @YES if the @par{interactionPoint} is within the
 *  @ref plotSymbolMarginForHitDetection of the closest data point.
 *  Then, if no plot symbol was hit or @ref allowSimultaneousSymbolAndPlotSelection is @YES and if this plot has
 *  a delegate that responds to the
 *  @link CPTPolarPlotDelegate::polarPlotDataLineTouchUp: -polarPlotDataLineTouchUp: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:dataLineTouchUpWithEvent: -polarPlot:dataLineTouchUpWithEvent: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlotDataLineWasSelected: -polarPlotDataLineWasSelected: @endlink or
 *  @link CPTPolarPlotDelegate::polarPlot:dataLineWasSelectedWithEvent: -polarPlot:dataLineWasSelectedWithEvent: @endlink
 *  methods and the @par{interactionPoint} falls within @ref plotLineMarginForHitDetection points of the plot line,
 *  then the 'dataLineTouchUp' delegate method(s) will be called and this method will return @YES.
 *  This method returns @NO if the @par{interactionPoint} is not within @ref plotSymbolMarginForHitDetection points of any of
 *  the data points or within @ref plotLineMarginForHitDetection points of the plot line.
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

    // Do not perform any selection if the plotSpace is bring dragged.
    if ( !theGraph || !thePlotArea || self.hidden || self.plotSpace.isDragging ) {
        return NO;
    }

    id<CPTPolarPlotDelegate> theDelegate = (id<CPTPolarPlotDelegate>)self.delegate;
    BOOL symbolSelectHandled               = NO;

    if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchUpAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchUpAtRecordIndex:withEvent:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:)] ||
         [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent:)] ) {
        // Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
        NSUInteger idx        = [self indexOfVisiblePointClosestToPlotAreaPoint:plotAreaPoint];

        if ( idx != NSNotFound ) {
            CGPoint center        = [self plotAreaPointOfVisiblePointAtIndex:idx];
            CPTPlotSymbol *symbol = [self plotSymbolForRecordIndex:idx];

            CGRect symbolRect = CGRectZero;
            if ( [symbol isKindOfClass:[CPTPlotSymbol class]] ) {
                symbolRect.size = symbol.size;
            }
            else {
                symbolRect.size = CGSizeZero;
            }
            CGFloat margin = self.plotSymbolMarginForHitDetection * CPTFloat(2.0);
            symbolRect.size.width  += margin;
            symbolRect.size.height += margin;
            symbolRect.origin       = CPTPointMake( center.x - CPTFloat(0.5) * CGRectGetWidth(symbolRect), center.y - CPTFloat(0.5) * CGRectGetHeight(symbolRect) );

            if ( CGRectContainsPoint(symbolRect, plotAreaPoint) ) {
                self.pointingDeviceDownIndex = idx;

                if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchUpAtRecordIndex:)] ) {
                    symbolSelectHandled = YES;
                    [theDelegate polarPlot:self plotSymbolTouchUpAtRecordIndex:idx];
                }
                if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolTouchUpAtRecordIndex:withEvent:)] ) {
                    symbolSelectHandled = YES;
                    [theDelegate polarPlot:self plotSymbolTouchUpAtRecordIndex:idx withEvent:event];
                }

                if ( idx == selectedDownIndex ) {
                    if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:)] ) {
                        symbolSelectHandled = YES;
                        [theDelegate polarPlot:self plotSymbolWasSelectedAtRecordIndex:idx];
                    }

                    if ( [theDelegate respondsToSelector:@selector(polarPlot:plotSymbolWasSelectedAtRecordIndex:withEvent:)] ) {
                        symbolSelectHandled = YES;
                        [theDelegate polarPlot:self plotSymbolWasSelectedAtRecordIndex:idx withEvent:event];
                    }
                }
            }
        }
    }

    BOOL plotSelectHandled = NO;
    BOOL plotSelected      = NO;

    if ( self.dataLineStyle &&
         (!symbolSelectHandled || self.allowSimultaneousSymbolAndPlotSelection) &&
         ([theDelegate respondsToSelector:@selector(polarPlotDataLineTouchUp:)] ||
          [theDelegate respondsToSelector:@selector(polarPlot:dataLineTouchUpWithEvent:)] ||
          [theDelegate respondsToSelector:@selector(polarPlotDataLineWasSelected:)] ||
          [theDelegate respondsToSelector:@selector(polarPlot:dataLineWasSelectedWithEvent:)]) ) {
        plotSelected = [self plotWasLineHitByInteractionPoint:interactionPoint];

        if ( plotSelected ) {
            if ( [theDelegate respondsToSelector:@selector(polarPlotDataLineTouchUp:)] ) {
                symbolSelectHandled = YES;
                [theDelegate polarPlotDataLineTouchUp:self];
            }
            if ( [theDelegate respondsToSelector:@selector(polarPlot:dataLineTouchUpWithEvent:)] ) {
                symbolSelectHandled = YES;
                [theDelegate polarPlot:self dataLineTouchUpWithEvent:event];
            }

            if ( self.pointingDeviceDownOnLine ) {
                // Let the delegate know that the plot was selected.
                if ( [theDelegate respondsToSelector:@selector(polarPlotDataLineWasSelected:)] ) {
                    plotSelectHandled = YES;
                    [theDelegate polarPlotDataLineWasSelected:self];
                }
                if ( [theDelegate respondsToSelector:@selector(polarPlot:dataLineWasSelectedWithEvent:)] ) {
                    plotSelectHandled = YES;
                    [theDelegate polarPlot:self dataLineWasSelectedWithEvent:event];
                }
            }
        }
    }

    if ( symbolSelectHandled || plotSelectHandled ) {
        return YES;
    }

    return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
}

-(BOOL)plotWasLineHitByInteractionPoint:(CGPoint)interactionPoint
{
    BOOL plotLineHit = NO;

    // Create the detection path.
    CPTGraph *theGraph       = self.graph;
    CPTPlotArea *thePlotArea = self.plotArea;
    NSUInteger dataCount     = self.cachedDataCount;

    if ( theGraph && thePlotArea && !self.hidden && dataCount ) {
        CGPoint *viewPoints  = malloc( dataCount * sizeof(CGPoint) );
        BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

        CPTPolarPlotSpace *thePlotSpace = (CPTPolarPlotSpace *)self.plotSpace;
        [self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:dataCount];
        [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags numberOfPoints:dataCount];
        NSInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:YES];
        
        NSDecimal centrePlotPoint[2];
        centrePlotPoint[CPTPolarPlotCoordinatesX] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];
        centrePlotPoint[CPTPolarPlotCoordinatesY] = [[NSDecimalNumber numberWithDouble:0.0] decimalValue];
        
        CGPoint centrePoint = [self convertPoint:[(CPTPolarPlotSpace *)self.plotSpace plotAreaViewPointForPlotPoint:centrePlotPoint numberOfCoordinates:2] fromLayer:self.plotArea];

        if ( firstDrawnPointIndex != NSNotFound ) {
            NSInteger lastDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags numberOfPoints:dataCount extremeNumIsLowerBound:NO];

            NSRange viewIndemajorRange = NSMakeRange( (NSUInteger)firstDrawnPointIndex, (NSUInteger)(lastDrawnPointIndex - firstDrawnPointIndex + 1) );
            CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndemajorRange baselineRadiusValue:CPTNAN centrePoint:centrePoint];
            CGPathRef path         = CGPathCreateCopyByStrokingPath( dataLinePath,
                                                                     NULL,
                                                                     self.plotLineMarginForHitDetection * CPTFloat(2.0),
                                                                     kCGLineCapRound,
                                                                     kCGLineJoinRound,
                                                                     CPTFloat(3.0) );

            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];

            plotLineHit = CGPathContainsPoint(path, NULL, plotAreaPoint, false);
            CGPathRelease(dataLinePath);
            CGPathRelease(path);
        }

        free(viewPoints);
        free(drawPointFlags);
    }

    return plotLineHit;
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setInterpolation:(CPTPolarPlotInterpolation)newInterpolation
{
    if ( newInterpolation != interpolation ) {
        interpolation = newInterpolation;
        [self setNeedsDisplay];
    }
}

-(void)setHistogramOption:(CPTPolarPlotHistogramOption)newHistogramOption
{
    if ( newHistogramOption != histogramOption ) {
        histogramOption = newHistogramOption;
        [self setNeedsDisplay];
    }
}

-(void)setCurvedInterpolationOption:(CPTPolarPlotCurvedInterpolationOption)newCurvedInterpolationOption
{
    if ( newCurvedInterpolationOption != curvedInterpolationOption ) {
        curvedInterpolationOption = newCurvedInterpolationOption;
        [self setNeedsDisplay];
    }
}

-(void)setCurvedInterpolationCustomAlpha:(CGFloat)newCurvedInterpolationCustomAlpha
{
    if ( newCurvedInterpolationCustomAlpha > CPTFloat(1.0) ) {
        newCurvedInterpolationCustomAlpha = CPTFloat(1.0);
    }
    if ( newCurvedInterpolationCustomAlpha < CPTFloat(0.0) ) {
        newCurvedInterpolationCustomAlpha = CPTFloat(0.0);
    }

    if ( newCurvedInterpolationCustomAlpha != curvedInterpolationCustomAlpha ) {
        curvedInterpolationCustomAlpha = newCurvedInterpolationCustomAlpha;
        [self setNeedsDisplay];
    }
}

-(void)setPlotSymbol:(nullable CPTPlotSymbol *)aSymbol
{
    if ( aSymbol != plotSymbol ) {
        plotSymbol = [aSymbol copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setDataLineStyle:(nullable CPTLineStyle *)newLineStyle
{
    if ( dataLineStyle != newLineStyle ) {
        dataLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setAreaFill:(nullable CPTFill *)newFill
{
    if ( newFill != areaFill ) {
        areaFill = [newFill copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setAreaFill2:(nullable CPTFill *)newFill
{
    if ( newFill != areaFill2 ) {
        areaFill2 = [newFill copy];
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(nullable CPTLimitBandArray *)areaFillBands
{
    return [self.mutableAreaFillBands copy];
}

-(void)setAreaBaseValue:(nullable NSNumber *)newAreaBaseValue
{
    BOOL needsUpdate = YES;

    if ( newAreaBaseValue ) {
        NSNumber *baseValue = newAreaBaseValue;
        needsUpdate = ![areaBaseValue isEqualToNumber:baseValue];
    }

    if ( needsUpdate ) {
        areaBaseValue = newAreaBaseValue;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setAreaBaseValue2:(nullable NSNumber *)newAreaBaseValue
{
    BOOL needsUpdate = YES;

    if ( newAreaBaseValue ) {
        NSNumber *baseValue = newAreaBaseValue;
        needsUpdate = ![areaBaseValue2 isEqualToNumber:baseValue];
    }

    if ( needsUpdate ) {
        areaBaseValue2 = newAreaBaseValue;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
    }
}

-(void)setThetaValues:(nullable CPTNumberArray *)newValues
{
    if(((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
    {
        CPTMutableNumberArray *adjustedValues = [CPTMutableNumberArray arrayWithCapacity:[newValues count]];
        for(NSNumber *theta in newValues)
            [adjustedValues addObject:[NSNumber numberWithDouble:[theta doubleValue]/180.0*M_PI]];
        [self cacheNumbers:adjustedValues forField:CPTPolarPlotFieldRadialAngle];
    }
    else
        [self cacheNumbers:newValues forField:CPTPolarPlotFieldRadialAngle];
}

-(nullable CPTNumberArray *)thetaValues
{
    if(((CPTPolarPlotSpace*)self.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees)
    {
        CPTNumberArray *values = [[self cachedNumbersForField:CPTPolarPlotFieldRadialAngle] sampleArray];
        CPTMutableNumberArray *adjustedValues = [CPTMutableNumberArray arrayWithCapacity:[values count]];
        for(NSNumber *theta in values)
            [adjustedValues addObject:[NSNumber numberWithDouble:[theta doubleValue]*180.0/M_PI]];
        return [CPTNumberArray arrayWithArray:adjustedValues];
    }
    else
        return [[self cachedNumbersForField:CPTPolarPlotFieldRadialAngle] sampleArray];
}

-(void)setRadiusValues:(nullable CPTNumberArray *)newValues
{
    [self cacheNumbers:newValues forField:CPTPolarPlotFieldRadius];
}

-(nullable CPTNumberArray *)radiusValues
{
    return [[self cachedNumbersForField:CPTPolarPlotFieldRadius] sampleArray];
}

-(void)setPlotSymbols:(nullable CPTPlotSymbolArray *)newSymbols
{
    [self cacheArray:newSymbols forKey:CPTPolarPlotBindingPlotSymbols];
    [self setNeedsDisplay];
}

-(nullable CPTPlotSymbolArray *)plotSymbols
{
    return [self cachedArrayForKey:CPTPolarPlotBindingPlotSymbols];
}

/// @endcond

- (CGFloat) Calc_ATAN_XY: (CGFloat) x y: (CGFloat) y
{
    CGFloat Angle = fabs(atan(x/y));
    if(x < (CGFloat)0.0)
    {
        if(y < 0)
            Angle += (CGFloat)M_PI;
        else
            Angle = (CGFloat)(2.0 * M_PI) - Angle;
    }
    else
    {
        if(y < (CGFloat)0.0)
            Angle = (CGFloat)M_PI - Angle;
    }
    return Angle;
}


@end


// need create 2 radial lines along the theta angle at the band limits
// and the datePathLine between those points
//                            NSRange partialIndexmajorRange = NSMakeRange(0, 0);
//                            NSUInteger j = 0;
//                            double lowerLimit = bandRange.minLimitDouble, upperLimit = bandRange.maxLimitDouble;
//                            for(NSNumber *num in [thetaValueData sampleArray])
//                            {
//                                if([num doubleValue] > lowerLimit)
//                                    break;
//                                j++;
//                            }
//                            if(j > 0)
//                                partialIndexmajorRange.location = j-1;
//                            j = [[thetaValueData sampleArray] count];
//                            for(NSNumber *num in [[[[thetaValueData sampleArray] reverseObjectEnumerator] allObjects] mutableCopy])
//                            {
//                                if([num doubleValue] < upperLimit)
//                                    break;
//                                j--;
//                            }
//                            partialIndexmajorRange.length = j - partialIndexmajorRange.location;
//                            CGPathRef partialDataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:partialIndexmajorRange baselineRadiusValue:CPTNAN centrePoint:centrePoint];

//                            CGPoint lowerBandOuterPoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:bandRange.minLimitDecimal Radius:[[NSNumber numberWithDouble:maxLength] decimalValue]];
//                            if ( pixelAlign ) {
//                                lowerBandOuterPoint = CPTAlignIntegralPointToUserSpace(context, lowerBandOuterPoint);
//                            }
//
//                            CGMutablePathRef lowerBandLinePath = CGPathCreateMutable();
//                            CGPathMoveToPoint(lowerBandLinePath, NULL, centrePoint.x, centrePoint.y);
//                            CGPathAddLineToPoint(lowerBandLinePath, NULL, lowerBandOuterPoint.x, lowerBandOuterPoint.y);
//
//                            CGPoint lowerIntersectionPoint = [self calculatedIntersectionOfTwoPaths:partialDataLinePath Second:lowerBandLinePath];
//
//                            CGPoint upperBandOuterPoint = [self translatedPolarCoordinatesToContextCoordinatesWithFromTheta:bandRange.maxLimitDecimal Radius:[[NSNumber numberWithDouble:maxLength] decimalValue]];
//                            if ( pixelAlign ) {
//                                upperBandOuterPoint = CPTAlignIntegralPointToUserSpace(context, upperBandOuterPoint);
//                            }
//
//                            CGMutablePathRef upperBandLinePath = CGPathCreateMutable();
//                            CGPathMoveToPoint(upperBandLinePath, NULL, centrePoint.x, centrePoint.y);
//                            CGPathAddLineToPoint(upperBandLinePath, NULL, upperBandOuterPoint.x, upperBandOuterPoint.y);
//
//                            CGPoint upperIntersectionPoint = [self calculatedIntersectionOfTwoPaths:partialDataLinePath Second:upperBandLinePath];
//
//                            CGMutablePathRef clippedBandAreaPath = CGPathCreateMutableCopy(partialDataLinePath);
//                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, upperIntersectionPoint.x, upperIntersectionPoint.y);
//                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, centrePoint.x, centrePoint.y);
//                            CGPathAddLineToPoint(clippedBandAreaPath, NULL, lowerIntersectionPoint.x, lowerIntersectionPoint.y);
//                            CGPathCloseSubpath(clippedBandAreaPath);

//- (CGPoint)calculatedIntersectionOfTwoPaths:(CGMutablePathRef)firstPath Second:(CGMutablePathRef)secondPath
//{
//    CGPoint intersectionPoint = CGPointZero;
//    ANPathBitmap * bm1 = [[ANPathBitmap alloc] initWithPath:firstPath];
//    ANPathBitmap * bm2 = [[ANPathBitmap alloc] initWithPath:secondPath];
//    bm1.lineCap = kCGLineCapRound;
//    bm2.lineCap = kCGLineCapRound;
//    bm1.lineThickness = 4;
//    bm2.lineThickness = 4;
//    [bm1 generateBitmap];
//    [bm2 generateBitmap];
//    ANPathIntersection * intersection = [[ANPathIntersection alloc] initWithPathBitmap:bm1 anotherPath:bm2];
//    if ([intersection pathLinesIntersect:&intersectionPoint]) {
//        NSLog(@"Intersection x:%0.2f y:%0.2f", intersectionPoint.x, intersectionPoint.y);
//    } else {
//        NSLog(@"No Intersection");
//    }
//    return intersectionPoint;
//}
