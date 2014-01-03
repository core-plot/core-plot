#import "CPTDefinitions.h"
#import "CPTPlot.h"

/// @file

@class CPTColor;
@class CPTFill;
@class CPTPieChart;
@class CPTTextLayer;
@class CPTLineStyle;

/// @ingroup plotBindingsPieChart
/// @{
extern NSString *const CPTPieChartBindingPieSliceWidthValues;
extern NSString *const CPTPieChartBindingPieSliceFills;
extern NSString *const CPTPieChartBindingPieSliceRadialOffsets;
/// @}

/**
 *  @brief Enumeration of pie chart data source field types.
 **/
typedef NS_ENUM (NSInteger, CPTPieChartField) {
    CPTPieChartFieldSliceWidth,           ///< Pie slice width.
    CPTPieChartFieldSliceWidthNormalized, ///< Pie slice width normalized [0, 1].
    CPTPieChartFieldSliceWidthSum         ///< Cumulative sum of pie slice widths.
};

/**
 *  @brief Enumeration of pie slice drawing directions.
 **/
typedef NS_ENUM (NSInteger, CPTPieDirection) {
    CPTPieDirectionClockwise,       ///< Pie slices are drawn in a clockwise direction.
    CPTPieDirectionCounterClockwise ///< Pie slices are drawn in a counter-clockwise direction.
};

#pragma mark -

/**
 *  @brief A pie chart data source.
 **/
@protocol CPTPieChartDataSource<CPTPlotDataSource>
@optional

/// @name Slice Style
/// @{

/** @brief @optional Gets a range of slice fills for the given pie chart.
 *  @param pieChart The pie chart.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of pie slice fills.
 **/
-(NSArray *)sliceFillsForPieChart:(CPTPieChart *)pieChart recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a fill for the given pie chart slice.
 *  This method will not be called if
 *  @link CPTPieChartDataSource::sliceFillsForPieChart:recordIndexRange: -sliceFillsForPieChart:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param pieChart The pie chart.
 *  @param idx The data index of interest.
 *  @return The pie slice fill for the slice with the given index. If the datasource returns @nil, the default fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;

/// @}

/// @name Slice Layout
/// @{

/** @brief @optional Gets a range of slice offsets for the given pie chart.
 *  @param pieChart The pie chart.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of radial offsets.
 **/
-(NSArray *)radialOffsetsForPieChart:(CPTPieChart *)pieChart recordIndexRange:(NSRange)indexRange;

/** @brief @optional Offsets the slice radially from the center point. Can be used to @quote{explode} the chart.
 *  This method will not be called if
 *  @link CPTPieChartDataSource::radialOffsetsForPieChart:recordIndexRange: -radialOffsetsForPieChart:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param pieChart The pie chart.
 *  @param idx The data index of interest.
 *  @return The radial offset in view coordinates. Zero is no offset.
 **/
-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;

/// @}

/// @name Legends
/// @{

/** @brief @optional Gets the legend title for the given pie chart slice.
 *  @param pieChart The pie chart.
 *  @param idx The data index of interest.
 *  @return The title text for the legend entry for the point with the given index.
 **/
-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;

/** @brief @optional Gets the styled legend title for the given pie chart slice.
 *  @param pieChart The pie chart.
 *  @param idx The data index of interest.
 *  @return The styled title text for the legend entry for the point with the given index.
 **/
-(NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;

/// @}
@end

#pragma mark -

/**
 *  @brief Pie chart delegate.
 **/
@protocol CPTPieChartDelegate<CPTPlotDelegate>

@optional

/// @name Slice Selection
/// @{

/** @brief @optional Informs the delegate that a pie slice received both the touch down and up events.
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 **/
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a pie slice received both the touch down and up events.
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a pie slice
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly started touching. @endif
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 **/
-(void)pieChart:(CPTPieChart *)plot sliceTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a pie slice
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly started touching. @endif
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)pieChart:(CPTPieChart *)plot sliceTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a pie slice
 *  @if MacOnly was released. @endif
 *  @if iOSOnly ended touching. @endif
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 **/
-(void)pieChart:(CPTPieChart *)plot sliceTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a pie slice was
 *  @if MacOnly was released. @endif
 *  @if iOSOnly ended touching. @endif
 *  @param plot The pie chart.
 *  @param idx The index of the
 *  @if MacOnly clicked pie slice. @endif
 *  @if iOSOnly touched pie slice. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)pieChart:(CPTPieChart *)plot sliceTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTPieChart : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite) CGFloat pieRadius;
@property (nonatomic, readwrite) CGFloat pieInnerRadius;
@property (nonatomic, readwrite) CGFloat startAngle;
@property (nonatomic, readwrite) CGFloat endAngle;
@property (nonatomic, readwrite) CPTPieDirection sliceDirection;
@property (nonatomic, readwrite) CGPoint centerAnchor;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *overlayFill;
/// @}

/// @name Data Labels
/// @{
@property (nonatomic, readwrite, assign) BOOL labelRotationRelativeToRadius;
/// @}

/// @name Information
/// @{
-(NSUInteger)pieSliceIndexAtAngle:(CGFloat)angle;
-(CGFloat)medianAngleForPieSliceIndex:(NSUInteger)idx;
/// @}

/// @name Factory Methods
/// @{
+(CPTColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
/// @}

@end
