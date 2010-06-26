
#import "CPDefinitions.h"
#import "CPPlotRange.h"
#import "CPLayer.h"

@class CPPlot;
@class CPPlotArea;
@class CPPlotSpace;
@class CPPlotRange;

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

///	@}

/**	@brief Determines the record index range corresponding to a given range of data.
 *	This method is optional. If the method is implemented, it could improve performance
 *  in data sets that are only partially displayed.
 *	@param plot The plot.
 *	@param plotRange The range expressed in data values.
 *	@return The range of record indexes.
 **/
-(NSRange)recordIndexRangeForPlot:(CPPlot *)plot plotRange:(CPPlotRange *)plotRange;

@end 

#pragma mark -

@interface CPPlot : CPLayer {
	@private
    id <CPPlotDataSource> dataSource;
    id <NSCopying, NSObject> identifier;
    CPPlotSpace *plotSpace;
    BOOL dataNeedsReloading;
    NSMutableDictionary *cachedData;
    NSUInteger cachedDataCount;
    BOOL doublePrecisionCache;
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
///	@}

/// @name Data Loading
/// @{
-(void)setDataNeedsReloading;
-(void)reloadData;
///	@}

/// @name Plot Data
/// @{
-(id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;
-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange;
///	@}

/// @name Data Cache
/// @{
-(id)cachedNumbersForField:(NSUInteger)fieldEnum;
-(void)cacheNumbers:(id)numbers forField:(NSUInteger)fieldEnum;
///	@}

/// @name Plot Data Ranges
/// @{
-(CPPlotRange *)plotRangeForField:(NSUInteger)fieldEnum;
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coord;
///	@}

/// @name Fields
/// @{
-(NSUInteger)numberOfFields;
-(NSArray *)fieldIdentifiers;
-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord;
///	@}

@end



