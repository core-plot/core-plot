#import "CPDefinitions.h"
#import "CPPlotRange.h"
#import "CPNumericDataType.h"
#import "CPAnnotationHostLayer.h"
#import "CPTextStyle.h"

@class CPMutableNumericData;
@class CPNumericData;
@class CPPlot;
@class CPPlotArea;
@class CPPlotSpace;
@class CPPlotSpaceAnnotation;
@class CPPlotRange;

///	@file

/**	@brief Enumeration of cache precisions.
 **/
typedef enum _CPPlotCachePrecision {
    CPPlotCachePrecisionAuto,		///< Cache precision is determined automatically from the data. All cached data will be converted to match the last data loaded.
    CPPlotCachePrecisionDouble,		///< All cached data will be converted to double precision.
    CPPlotCachePrecisionDecimal		///< All cached data will be converted to NSDecimal.
} CPPlotCachePrecision;

#pragma mark -

/**	@brief A plot data source.
 **/
@protocol CPPlotDataSource <NSObject>
/**	@brief The number of data points for the plot.
 *	@param plot The plot.
 *	@return The number of data points for the plot.
 **/
-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot; 

@optional

/// @name Implement one of the following
/// @{

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of data points.
 **/
-(NSArray *)numbersForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot data value for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param index The data index of interest.
 *	@return A data point.
 **/
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return A retained C array of data points.
 **/
-(double *)doublesForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot data value for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param index The data index of interest.
 *	@return A data point.
 **/
-(double)doubleForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

/**	@brief Gets a range of plot data for the given plot and field.
 *	@param plot The plot.
 *	@param fieldEnum The field index.
 *	@param indexRange The range of the data indexes of interest.
 *	@return A one-dimensional array of data points.
 **/
-(CPNumericData *)dataForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

///	@}

/// @name Data Range
/// @{

/**	@brief Determines the record index range corresponding to a given range of data.
 *	This method is optional. If the method is implemented, it could improve performance
 *  in data sets that are only partially displayed.
 *	@param plot The plot.
 *	@param plotRange The range expressed in data values.
 *	@return The range of record indexes.
 *	@deprecated This method is no longer used and will be removed from a later release.
 **/
-(NSRange)recordIndexRangeForPlot:(CPPlot *)plot plotRange:(CPPlotRange *)plotRange;

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
-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index;

///	@}

@end 

#pragma mark -

@interface CPPlot : CPAnnotationHostLayer <CPTextStyleDelegate> {
	@private
    id <CPPlotDataSource> dataSource;
    id <NSCopying, NSObject> identifier;
    CPPlotSpace *plotSpace;
    BOOL dataNeedsReloading;
    NSMutableDictionary *cachedData;
    NSUInteger cachedDataCount;
    CPPlotCachePrecision cachePrecision;
	BOOL needsRelabel;
	CGFloat labelOffset;
    CGFloat labelRotation;
	NSUInteger labelField;
	CPTextStyle *labelTextStyle;
	NSNumberFormatter *labelFormatter;
	BOOL labelFormatterChanged;
	NSRange labelIndexRange;
	NSMutableArray *labelAnnotations;
}

/// @name Data Source
/// @{
@property (nonatomic, readwrite, assign) id <CPPlotDataSource> dataSource;
///	@}

/// @name Identification
/// @{
@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
///	@}

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
///	@}

/// @name Plot Area
/// @{
@property (nonatomic, readonly, retain) CPPlotArea *plotArea;
///	@}

/// @name Data Loading
/// @{
@property (nonatomic, readonly, assign) BOOL dataNeedsReloading;
///	@}

/// @name Data Cache
/// @{
@property (nonatomic, readonly, assign) NSUInteger cachedDataCount;
@property (nonatomic, readonly, assign) BOOL doublePrecisionCache;
@property (nonatomic, readwrite, assign) CPPlotCachePrecision cachePrecision;
@property (nonatomic, readonly, assign) CPNumericDataType doubleDataType;
@property (nonatomic, readonly, assign) CPNumericDataType decimalDataType;
///	@}

/// @name Data Labels
/// @{
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) CGFloat labelOffset;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;
@property (nonatomic, readwrite, assign) NSUInteger labelField;
@property (nonatomic, readwrite, copy) CPTextStyle *labelTextStyle;
@property (nonatomic, readwrite, retain) NSNumberFormatter *labelFormatter;
///	@}

/// @name Data Labels
/// @{
-(void)setNeedsRelabel;
-(void)relabel;
-(void)relabelIndexRange:(NSRange)indexRange;
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
-(CPMutableNumericData *)cachedNumbersForField:(NSUInteger)fieldEnum;
-(NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(NSDecimal)cachedDecimalForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum atRecordIndex:(NSUInteger)index;
///	@}

/// @name Plot Data Ranges
/// @{
-(CPPlotRange *)plotRangeForField:(NSUInteger)fieldEnum;
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coord;
///	@}

@end

#pragma mark -

/**	@category CPPlot(AbstractMethods)
 *	@brief CPPlot abstract methods—must be overridden by subclasses
 **/
@interface CPPlot(AbstractMethods)

/// @name Fields
/// @{
-(NSUInteger)numberOfFields;
-(NSArray *)fieldIdentifiers;
-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord;
///	@}

/// @name Data Labels
/// @{
-(void)positionLabelAnnotation:(CPPlotSpaceAnnotation *)label forIndex:(NSUInteger)index;
///	@}

@end

