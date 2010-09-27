#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPColor;
@class CPFill;
@class CPMutableNumericData;
@class CPNumericData;
@class CPPieChart;
@class CPTextLayer;
@class CPLineStyle;

/// @name Binding Identifiers
/// @{
extern NSString * const CPPieChartBindingPieSliceWidthValues;
///	@}

/**	@brief Enumeration of pie chart data source field types.
 **/
typedef enum _CPPieChartField {
    CPPieChartFieldSliceWidth,				///< Pie slice width.
    CPPieChartFieldSliceWidthNormalized,	///< Pie slice width normalized [0, 1].
    CPPieChartFieldSliceWidthSum			///< Cumulative sum of pie slice widths.
} CPPieChartField;

/**	@brief Enumeration of pie slice drawing directions.
 **/
typedef enum _CPPieDirection {
    CPPieDirectionClockwise,		///< Pie slices are drawn in a clockwise direction.
	CPPieDirectionCounterClockwise	///< Pie slices are drawn in a counter-clockwise direction.
} CPPieDirection;

#pragma mark -

/**	@brief A pie chart data source.
 **/
@protocol CPPieChartDataSource <CPPlotDataSource> 
@optional 

/**	@brief Gets a fill for the given pie chart slice. This method is optional.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The pie slice fill for the slice with the given index.
 **/
-(CPFill *)sliceFillForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index; 

/** @brief Gets a label for the given pie chart slice. This method is no longer used.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The pie slice label for the slice with the given index.
 *  If you return nil, the default pie slice label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 *	@deprecated This method has been replaced by the CPPlotDataSource <code>-dataLabelForPlot:recordIndex:</code>  method and is no longer used.
 **/
-(CPTextLayer *)sliceLabelForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index;

@end 

#pragma mark -

/**	@brief Pie chart delegate.
 **/
@protocol CPPieChartDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs the delegate that a pie slice was touched or clicked.
 *	@param plot The pie chart.
 *	@param index The index of the slice that was touched or clicked.
 **/
-(void)pieChart:(CPPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

@interface CPPieChart : CPPlot {
	@private
	CGFloat pieRadius;
	CGFloat startAngle;
	CPPieDirection sliceDirection;
	CGPoint centerAnchor;
	CPLineStyle *borderLineStyle;
}

@property (nonatomic, readwrite) CGFloat pieRadius;
@property (nonatomic, readwrite) CGFloat sliceLabelOffset;
@property (nonatomic, readwrite) CGFloat startAngle;
@property (nonatomic, readwrite) CPPieDirection sliceDirection;
@property (nonatomic, readwrite) CGPoint centerAnchor;
@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;

/// @name Factory Methods
/// @{
+(CPColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
///	@}

@end
