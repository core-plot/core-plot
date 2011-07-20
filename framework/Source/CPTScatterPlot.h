
#import <Foundation/Foundation.h>
#import "CPTPlot.h"
#import "CPTDefinitions.h"

///	@file

@class CPTLineStyle;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTPlotSymbol;
@class CPTScatterPlot;
@class CPTFill;

///	@ingroup plotBindingsScatterPlot
/// @{
extern NSString * const CPTScatterPlotBindingXValues;
extern NSString * const CPTScatterPlotBindingYValues;
extern NSString * const CPTScatterPlotBindingPlotSymbols;
///	@}

/**	@brief Enumeration of scatter plot data source field types
 **/
typedef enum _CPTScatterPlotField {
    CPTScatterPlotFieldX,								///< X values.
    CPTScatterPlotFieldY 								///< Y values.
} CPTScatterPlotField;

/**	@brief Enumeration of scatter plot interpolation algorithms
 **/
typedef enum _CPTScatterPlotInterpolation {
    CPTScatterPlotInterpolationLinear,					///< Linear interpolation.
    CPTScatterPlotInterpolationStepped,					///< Steps beginnning at data point.
    CPTScatterPlotInterpolationHistogram					///< Steps centered at data point.
} CPTScatterPlotInterpolation;

#pragma mark -

/**	@brief A scatter plot data source.
 **/
@protocol CPTScatterPlotDataSource <CPTPlotDataSource>

@optional

/// @name Implement one of the following to add plot symbols
/// @{

/**	@brief Gets a range of plot symbols for the given scatter plot.
 *	@param plot The scatter plot.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of plot symbols.
 **/
-(NSArray *)symbolsForScatterPlot:(CPTScatterPlot *)plot recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot symbol for the given scatter plot.
 *	@param plot The scatter plot.
 *	@param index The data index of interest.
 *	@return The plot symbol to show for the point with the given index.
 **/
-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index;

///	@}

@end 

#pragma mark -

/**	@brief Scatter plot delegate.
 **/
@protocol CPTScatterPlotDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs delegate that a point was touched.
 *	@param plot The scatter plot.
 *	@param index Index of touched point
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

@interface CPTScatterPlot : CPTPlot {
	@private
    CPTScatterPlotInterpolation interpolation;
	CPTLineStyle *dataLineStyle;
	CPTPlotSymbol *plotSymbol;
    CPTFill *areaFill;
    CPTFill *areaFill2;
    NSDecimal areaBaseValue;
    NSDecimal areaBaseValue2;
    CGFloat plotSymbolMarginForHitDetection;
    NSArray *plotSymbols;
} 

@property (nonatomic, readwrite, copy) CPTLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPTPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy) CPTFill *areaFill;
@property (nonatomic, readwrite, copy) CPTFill *areaFill2;
@property (nonatomic, readwrite) NSDecimal areaBaseValue;
@property (nonatomic, readwrite) NSDecimal areaBaseValue2;
@property (nonatomic, readwrite, assign) CPTScatterPlotInterpolation interpolation;
@property (nonatomic, readwrite, assign) CGFloat plotSymbolMarginForHitDetection;

-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint;
-(CGPoint)plotAreaPointOfVisiblePointAtIndex:(NSUInteger)index;

-(CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index;

@end
