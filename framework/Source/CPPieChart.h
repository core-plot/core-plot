#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

///	@file

@class CPColor;
@class CPFill;
@class CPPieChart;
@class CPTextLayer;

/**	@brief Enumeration of pie chart data source field types.
 **/
typedef enum _CPPieChartField {
    CPPieChartFieldSliceWidth		///< Pie slice width.
} CPPieChartField;

/**	@brief Enumeration of pie slice drawing directions.
 **/
typedef enum _CPPieDirection {
    CPPieDirectionClockwise,		///< Pie slices are drawn in a clockwise direction.
	CPPieDirectionCounterClockwise	///< Pie slices are drawn in a counter-clockwise direction.
} CPPieDirection;

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

/** @brief Gets a label for the given pie chart slice. This method is optional.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The pie slice label for the slice with the given index.
 *  If you return nil, the default pie slice label will be used. If you return an NSNull,
 *  no label will be shown for the index in question.
 **/
-(CPTextLayer *)sliceLabelForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index;

@end 


@interface CPPieChart : CPPlot {
	@private
	id observedObjectForPieSliceWidthValues;
	NSString *keyPathForPieSliceWidthValues;
	CGFloat pieRadius;
	CGFloat sliceLabelOffset;
	CGFloat startAngle;
	CPPieDirection sliceDirection;
}

@property (nonatomic, readwrite) CGFloat pieRadius;
@property (nonatomic, readwrite) CGFloat sliceLabelOffset;
@property (nonatomic, readwrite) CGFloat startAngle;
@property (nonatomic, readwrite) CPPieDirection sliceDirection;

/// @name Factory Methods
/// @{
+(CPColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
///	@}

@end
