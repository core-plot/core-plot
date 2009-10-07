
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
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
    CPScatterPlotFieldX,	///< X values.
    CPScatterPlotFieldY		///< Y values.
} CPScatterPlotField;

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

@interface CPScatterPlot : CPPlot {
@private
    id observedObjectForXValues;
    id observedObjectForYValues;
    id observedObjectForPlotSymbols;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
    NSString *keyPathForPlotSymbols;
	CPLineStyle *dataLineStyle;
	CPPlotSymbol *plotSymbol;
    CPFill *areaFill;
    NSDecimal areaBaseValue;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
	double doublePrecisionAreaBaseValue;
    NSArray *plotSymbols;
} 

@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy) CPFill *areaFill;
@property (nonatomic, readwrite) NSDecimal areaBaseValue;
@property (nonatomic, readwrite) double doublePrecisionAreaBaseValue;

@end
