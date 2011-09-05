#import "CPTDefinitions.h"
#import "CPTPlotRange.h"
#import "CPTNumericDataType.h"
#import "CPTAnnotationHostLayer.h"
#import "CPTMutableTextStyle.h"

@class CPTLegend;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTPlot;
@class CPTPlotArea;
@class CPTPlotSpace;
@class CPTPlotSpaceAnnotation;
@class CPTPlotRange;

///	@file

/**	@brief Enumeration of cache precisions.
 **/
typedef enum _CPTPlotCachePrecision {
    CPTPlotCachePrecisionAuto,		///< Cache precision is determined automatically from the data. All cached data will be converted to match the last data loaded.
    CPTPlotCachePrecisionDouble,		///< All cached data will be converted to double precision.
    CPTPlotCachePrecisionDecimal		///< All cached data will be converted to NSDecimal.
} CPTPlotCachePrecision;

#pragma mark -

/**	@brief A plot data source.
 **/
@protocol CPTPlotDataSource <NSObject>
/**	@brief The number of data points for the plot.
 *	@param plot The plot.
 *	@return The number of data points for the plot.
 **/
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot; 

@optional

/// @name Implement one of the following
/// @{

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of data points.
 **/
-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot data value for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param index The data index of interest.
 *	@return A data point.
 **/
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return A retained C array of data points.
 **/
-(double *)doublesForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot data value for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param index The data index of interest.
 *	@return A data point.
 **/
-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return A one-dimensional array of data points.
 **/
-(CPTNumericData *)dataForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

///	@}

/// @name Data Labels
/// @{

/** @brief Gets a data label for the given plot. This method is optional.
 *	@param plot The plot.
 *	@param index The data index of interest.
 *	@return The data label for the point with the given index.
 *  If you return nil, the default data label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 **/
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index;

///	@}

@end 

#pragma mark -

@interface CPTPlot : CPTAnnotationHostLayer {
	@private
    id <CPTPlotDataSource> dataSource;
    id <NSCopying, NSCoding, NSObject> identifier;
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
	NSNumberFormatter *labelFormatter;
	BOOL labelFormatterChanged;
	NSRange labelIndexRange;
	NSMutableArray *labelAnnotations;
	CPTShadow *labelShadow;
	BOOL alignsPointsToPixels;
}

/// @name Data Source
/// @{
@property (nonatomic, readwrite, assign) id <CPTPlotDataSource> dataSource;
///	@}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy) id <NSCopying, NSCoding, NSObject> identifier;
@property (nonatomic, readwrite, copy) NSString *title;
///	@}

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPTPlotSpace *plotSpace;
///	@}

/// @name Plot Area
/// @{
@property (nonatomic, readonly, retain) CPTPlotArea *plotArea;
///	@}

/// @name Data Loading
/// @{
@property (nonatomic, readonly, assign) BOOL dataNeedsReloading;
///	@}

/// @name Data Cache
/// @{
@property (nonatomic, readonly, assign) NSUInteger cachedDataCount;
@property (nonatomic, readonly, assign) BOOL doublePrecisionCache;
@property (nonatomic, readwrite, assign) CPTPlotCachePrecision cachePrecision;
@property (nonatomic, readonly, assign) CPTNumericDataType doubleDataType;
@property (nonatomic, readonly, assign) CPTNumericDataType decimalDataType;
///	@}

/// @name Data Labels
/// @{
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) CGFloat labelOffset;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;
@property (nonatomic, readwrite, assign) NSUInteger labelField;
@property (nonatomic, readwrite, copy) CPTTextStyle *labelTextStyle;
@property (nonatomic, readwrite, retain) NSNumberFormatter *labelFormatter;
@property (nonatomic, readwrite, retain) CPTShadow *labelShadow;
///	@}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, assign) BOOL alignsPointsToPixels;
///	@}

/// @name Data Labels
/// @{
-(void)setNeedsRelabel;
-(void)relabel;
-(void)relabelIndexRange:(NSRange)indexRange;
-(void)repositionAllLabelAnnotations;
///	@}

/// @name Data Loading
/// @{
-(void)setDataNeedsReloading;
-(void)reloadData;
-(void)reloadDataIfNeeded;
-(void)reloadDataInIndexRange:(NSRange)indexRange;
-(void)insertDataAtIndex:(NSUInteger)index numberOfRecords:(NSUInteger)numberOfRecords;
-(void)deleteDataInIndexRange:(NSRange)indexRange;
///	@}

/// @name Plot Data
/// @{
-(id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;
///	@}

/// @name Data Cache
/// @{
-(CPTMutableNumericData *)cachedNumbersForField:(NSUInteger)fieldEnum;
-(NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(NSDecimal)cachedDecimalForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum atRecordIndex:(NSUInteger)index;
///	@}

/// @name Plot Data Ranges
/// @{
-(CPTPlotRange *)plotRangeForField:(NSUInteger)fieldEnum;
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord;
///	@}

/// @name Legends
/// @{
-(NSUInteger)numberOfLegendEntries;
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)index;
-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)index inRect:(CGRect)rect inContext:(CGContextRef)context;
///	@}

@end

#pragma mark -

/**	@category CPTPlot(AbstractMethods)
 *	@brief CPTPlot abstract methods—must be overridden by subclasses
 **/
@interface CPTPlot(AbstractMethods)

/// @name Fields
/// @{
-(NSUInteger)numberOfFields;
-(NSArray *)fieldIdentifiers;
-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord;
///	@}

/// @name Data Labels
/// @{
-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)index;
///	@}

@end

