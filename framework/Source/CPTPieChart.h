#import <Foundation/Foundation.h>
#import "CPTPlot.h"
#import "CPTDefinitions.h"

///	@file

@class CPTColor;
@class CPTFill;
@class CPTMutableNumericData;
@class CPTNumericData;
@class CPTPieChart;
@class CPTTextLayer;
@class CPTLineStyle;

///	@ingroup plotBindingsPieChart
/// @{
extern NSString * const CPTPieChartBindingPieSliceWidthValues;
///	@}

/**	@brief Enumeration of pie chart data source field types.
 **/
typedef enum _CPTPieChartField {
    CPTPieChartFieldSliceWidth,				///< Pie slice width.
    CPTPieChartFieldSliceWidthNormalized,	///< Pie slice width normalized [0, 1].
    CPTPieChartFieldSliceWidthSum			///< Cumulative sum of pie slice widths.
} CPTPieChartField;

/**	@brief Enumeration of pie slice drawing directions.
 **/
typedef enum _CPTPieDirection {
    CPTPieDirectionClockwise,		///< Pie slices are drawn in a clockwise direction.
	CPTPieDirectionCounterClockwise	///< Pie slices are drawn in a counter-clockwise direction.
} CPTPieDirection;

#pragma mark -

/**	@brief A pie chart data source.
 **/
@protocol CPTPieChartDataSource <CPTPlotDataSource> 
@optional 

/**	@brief Gets a fill for the given pie chart slice. This method is optional.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The pie slice fill for the slice with the given index.
 **/
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index; 

/** @brief Offsets the slice radially from the center point. Can be used to "explode" the chart.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The radial offset in view coordinates. Zero is no offset.
 **/
-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index;

/// @name Legends
/// @{

/** @brief Gets the legend title for the given pie chart slice.
 *	@param pieChart The pie chart.
 *	@param index The data index of interest.
 *	@return The title text for the legend entry for the point with the given index.
 *  If this method is not implemented or returns nil, the legend will get
 *	the title from the corresponding data label if it is a CPTTextLayer.
 **/
-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index;

///	@}
@end 

#pragma mark -

/**	@brief Pie chart delegate.
 **/
@protocol CPTPieChartDelegate <NSObject>

@optional

// @name Point selection
/// @{

/**	@brief Informs the delegate that a pie slice was touched or clicked.
 *	@param plot The pie chart.
 *	@param index The index of the slice that was touched or clicked.
 **/
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index;

///	@}

@end

#pragma mark -

@interface CPTPieChart : CPTPlot {
	@private
	CGFloat pieRadius;
	CGFloat pieInnerRadius;
	CGFloat startAngle;
	CPTPieDirection sliceDirection;
	CGPoint centerAnchor;
	CPTLineStyle *borderLineStyle;
    CPTFill *overlayFill;
}

@property (nonatomic, readwrite) CGFloat pieRadius;
@property (nonatomic, readwrite) CGFloat pieInnerRadius;
@property (nonatomic, readwrite) CGFloat startAngle;
@property (nonatomic, readwrite) CPTPieDirection sliceDirection;
@property (nonatomic, readwrite) CGPoint centerAnchor;
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *overlayFill;

/// @name Factory Methods
/// @{
+(CPTColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
///	@}

@end
