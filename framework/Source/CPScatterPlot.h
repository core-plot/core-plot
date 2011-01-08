
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
@class CPMutableNumericData;
@class CPNumericData;
@class CPPlotSymbol;
@class CPScatterPlot;
@class CPFill;

/// @name Binding Identifiers
/// @{
extern NSString * const CPScatterPlotBindingXValues;
extern NSString * const CPScatterPlotBindingYValues;
extern NSString * const CPScatterPlotBindingPlotSymbols;
///	@}

/**	@brief Enumeration of scatter plot data source field types
 **/
typedef enum _CPScatterPlotField {
    CPScatterPlotFieldX,								///< X values.
    CPScatterPlotFieldY 								///< Y values.
} CPScatterPlotField;

/**	@brief Enumeration of scatter plot interpolation algorithms
 **/
typedef enum _CPScatterPlotInterpolation {
    CPScatterPlotInterpolationLinear,					///< Linear interpolation.
    CPScatterPlotInterpolationStepped,					///< Steps beginnning at data point.
    CPScatterPlotInterpolationHistogram					///< Steps centered at data point.
} CPScatterPlotInterpolation;

#pragma mark -

/**	@brief A scatter plot data source.
 **/
@protocol CPScatterPlotDataSource <CPPlotDataSource>

@optional

/// @name Implement one of the following to add plot symbols
/// @{

/**	@brief Gets a range of plot symbols for the given scatter plot.
 *	@param plot The scatter plot.
 *	@param indexRange The range of the data indexes of interest.
 *	@return An array of plot symbols.
 **/
-(NSArray *)symbolsForScatterPlot:(CPScatterPlot *)plot recordIndexRange:(NSRange)indexRange;

/**	@brief Gets a plot symbol for the given scatter plot.
 *	@param plot The scatter plot.
 *	@param index The data index of interest.
 *	@return The plot symbol to show for the point with the given index.
 **/
-(CPPlotSymbol *)symbolForScatterPlot:(CPScatterPlot *)plot recordIndex:(NSUInteger)index;

///	@}

@end 

#pragma mark -

/**	@brief Scatter plot delegate.
 **/
@protocol CPScatterPlotDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs delegate that a point was touched.
 *	@param plot The scatter plot.
 *	@param index Index of touched point
 **/
-(void)scatterPlot:(CPScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

@interface CPScatterPlot : CPPlot {
	@private
    CPScatterPlotInterpolation interpolation;
	CPLineStyle *dataLineStyle;
	CPPlotSymbol *plotSymbol;
    CPFill *areaFill;
    CPFill *areaFill2;
    NSDecimal areaBaseValue;
    NSDecimal areaBaseValue2;
    CGFloat plotSymbolMarginForHitDetection;
    NSArray *plotSymbols;
} 

@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy) CPFill *areaFill;
@property (nonatomic, readwrite, copy) CPFill *areaFill2;
@property (nonatomic, readwrite) NSDecimal areaBaseValue;
@property (nonatomic, readwrite) NSDecimal areaBaseValue2;
@property (nonatomic, readwrite, assign) CPScatterPlotInterpolation interpolation;
@property (nonatomic, readwrite, assign) CGFloat plotSymbolMarginForHitDetection;

-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint;
-(CGPoint)plotAreaPointOfVisiblePointAtIndex:(NSUInteger)index;

-(CPPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index;

@end
