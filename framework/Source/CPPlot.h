
#import "CPDefinitions.h"
#import "CPPlotRange.h"
#import "CPLayer.h"

@class CPPlot;
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

///	@}

/**	@brief Determines the record index range corresponding to a given range of data.
 *	This method is optional.
 *	@param plot The plot.
 *	@param plotRange The range expressed in data values.
 *	@return The range of record indexes.
 **/
-(NSRange)recordIndexRangeForPlot:(CPPlot *)plot plotRange:(CPPlotRange *)plotRange;

@end 

@interface CPPlot : CPLayer {
	@private
    id <CPPlotDataSource> dataSource;
    id <NSCopying, NSObject> identifier;
    CPPlotSpace *plotSpace;
    BOOL dataNeedsReloading;
    NSMutableDictionary *cachedData;
}

@property (nonatomic, readwrite, assign) id <CPPlotDataSource> dataSource;
@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
@property (nonatomic, readonly, assign) BOOL dataNeedsReloading;

/// @name Data Loading
/// @{
-(void)setDataNeedsReloading;
-(void)reloadData;
///	@}

/// @name Plot Data
/// @{
-(NSArray *)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;
-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange;
///	@}

/// @name Data Cache
/// @{
-(NSArray *)cachedNumbersForField:(NSUInteger)fieldEnum;
-(void)cacheNumbers:(NSArray *)numbers forField:(NSUInteger)fieldEnum;
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



