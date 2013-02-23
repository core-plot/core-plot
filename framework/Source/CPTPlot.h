#import "CPTAnnotationHostLayer.h"
#import "CPTDefinitions.h"
#import "CPTNumericDataType.h"

/// @file

@class CPTLegend;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTPlot;
@class CPTPlotArea;
@class CPTPlotSpace;
@class CPTPlotSpaceAnnotation;
@class CPTPlotRange;
@class CPTTextStyle;

/// @ingroup plotBindingsAllPlots
/// @{
extern NSString *const CPTPlotBindingDataLabels;
/// @}

/**
 *  @brief Enumeration of cache precisions.
 **/
typedef enum _CPTPlotCachePrecision {
    CPTPlotCachePrecisionAuto,   ///< Cache precision is determined automatically from the data. All cached data will be converted to match the last data loaded.
    CPTPlotCachePrecisionDouble, ///< All cached data will be converted to double precision.
    CPTPlotCachePrecisionDecimal ///< All cached data will be converted to @ref NSDecimal.
}
CPTPlotCachePrecision;

#pragma mark -

/**
 *  @brief A plot data source.
 **/
@protocol CPTPlotDataSource<NSObject>

/// @name Data Values
/// @{

/** @brief @required The number of data points for the plot.
 *  @param plot The plot.
 *  @return The number of data points for the plot.
 **/
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;

@optional

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data points.
 **/
-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A retained C array of data points.
 **/
-(double *)doublesForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A one-dimensional array of data points.
 **/
-(CPTNumericData *)dataForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a range of plot data for all fields of the given plot simultaneously.
 *  Implement one and only one of the optional methods in this section.
 *
 *  The data returned from this method should be a two-dimensional array. It can be arranged
 *  in row- or column-major order although column-major will load faster, especially for large arrays.
 *  The array should have the same number of rows as the length of @par{indexRange}.
 *  The number of columns should be equal to the number of plot fields required by the plot.
 *  The column index (zero-based) corresponds with the field index.
 *  The data type will be converted to match the @link CPTPlot::cachePrecision cachePrecision @endlink if needed.
 *
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A two-dimensional array of data points.
 **/
-(CPTNumericData *)dataForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange;

/// @}

/// @name Data Labels
/// @{

/** @brief @optional Gets a range of data labels for the given plot.
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data labels.
 **/
-(NSArray *)dataLabelsForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a data label for the given plot.
 *  This method will not be called if
 *  @link CPTPlotDataSource::dataLabelsForPlot:recordIndexRange: -dataLabelsForPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The plot.
 *  @param idx The data index of interest.
 *  @return The data label for the point with the given index.
 *  If you return @nil, the default data label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 **/
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Plot delegate.
 **/
@protocol CPTPlotDelegate<NSObject>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a data label was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 **/
-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data label was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/// @}

/// @name Drawing
/// @{

/**
 *  @brief @optional Informs the delegate that plot drawing is finished.
 *  @param plot The plot.
 **/
-(void)didFinishDrawing:(CPTPlot *)plot;

/// @}

@end

#pragma mark -

@interface CPTPlot : CPTAnnotationHostLayer {
    @private
    __cpt_weak id<CPTPlotDataSource> dataSource;
    NSString *title;
    CPTPlotSpace *plotSpace;
    BOOL dataNeedsReloading;
    NSMutableDictionary *cachedData;
    NSUInteger cachedDataCount;
    CPTPlotCachePrecision cachePrecision;
    BOOL needsRelabel;
    CGFloat labelOffset;
    CGFloat labelRotation;
    NSUInteger labelField;
    CPTTextStyle *labelTextStyle;
    NSFormatter *labelFormatter;
    NSRange labelIndexRange;
    NSMutableArray *labelAnnotations;
    CPTShadow *labelShadow;
    BOOL alignsPointsToPixels;
}

/// @name Data Source
/// @{
@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak id<CPTPlotDataSource> dataSource;
/// @}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy) NSString *title;
/// @}

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPTPlotSpace *plotSpace;
/// @}

/// @name Plot Area
/// @{
@property (nonatomic, readonly, retain) CPTPlotArea *plotArea;
/// @}

/// @name Data Loading
/// @{
@property (nonatomic, readonly, assign) BOOL dataNeedsReloading;
/// @}

/// @name Data Cache
/// @{
@property (nonatomic, readonly, assign) NSUInteger cachedDataCount;
@property (nonatomic, readonly, assign) BOOL doublePrecisionCache;
@property (nonatomic, readwrite, assign) CPTPlotCachePrecision cachePrecision;
@property (nonatomic, readonly, assign) CPTNumericDataType doubleDataType;
@property (nonatomic, readonly, assign) CPTNumericDataType decimalDataType;
/// @}

/// @name Data Labels
/// @{
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) CGFloat labelOffset;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;
@property (nonatomic, readwrite, assign) NSUInteger labelField;
@property (nonatomic, readwrite, copy) CPTTextStyle *labelTextStyle;
@property (nonatomic, readwrite, retain) NSFormatter *labelFormatter;
@property (nonatomic, readwrite, retain) CPTShadow *labelShadow;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, assign) BOOL alignsPointsToPixels;
/// @}

/// @name Data Labels
/// @{
-(void)setNeedsRelabel;
-(void)relabel;
-(void)relabelIndexRange:(NSRange)indexRange;
-(void)repositionAllLabelAnnotations;
/// @}

/// @name Data Loading
/// @{
-(void)setDataNeedsReloading;
-(void)reloadData;
-(void)reloadDataIfNeeded;
-(void)reloadDataInIndexRange:(NSRange)indexRange;
-(void)insertDataAtIndex:(NSUInteger)idx numberOfRecords:(NSUInteger)numberOfRecords;
-(void)deleteDataInIndexRange:(NSRange)indexRange;
/// @}

/// @name Plot Data
/// @{
+(id)nilData;
-(id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;
-(BOOL)loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:(NSRange)indexRange;
/// @}

/// @name Data Cache
/// @{
-(CPTMutableNumericData *)cachedNumbersForField:(NSUInteger)fieldEnum;
-(NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;
-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;
-(NSDecimal)cachedDecimalForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;
-(NSArray *)cachedArrayForKey:(NSString *)key;
-(id)cachedValueForKey:(NSString *)key recordIndex:(NSUInteger)idx;

-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum atRecordIndex:(NSUInteger)idx;
-(void)cacheArray:(NSArray *)array forKey:(NSString *)key;
-(void)cacheArray:(NSArray *)array forKey:(NSString *)key atRecordIndex:(NSUInteger)idx;
/// @}

/// @name Plot Data Ranges
/// @{
-(CPTPlotRange *)plotRangeForField:(NSUInteger)fieldEnum;
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord;
/// @}

/// @name Legends
/// @{
-(NSUInteger)numberOfLegendEntries;
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)idx;
-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(CGContextRef)context;
/// @}

@end

#pragma mark -

/** @category CPTPlot(AbstractMethods)
 *  @brief CPTPlot abstract methods—must be overridden by subclasses
 **/
@interface CPTPlot(AbstractMethods)

/// @name Fields
/// @{
-(NSUInteger)numberOfFields;
-(NSArray *)fieldIdentifiers;
-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord;
/// @}

/// @name Data Labels
/// @{
-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx;
/// @}

/// @name User Interaction
/// @{
-(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point;
/// @}

@end
