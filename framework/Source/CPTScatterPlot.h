#import "CPTDefinitions.h"
#import "CPTPlot.h"

/// @file

@class CPTLineStyle;
@class CPTPlotSymbol;
@class CPTScatterPlot;
@class CPTFill;

/// @ingroup plotBindingsScatterPlot
/// @{
extern NSString *const CPTScatterPlotBindingXValues;
extern NSString *const CPTScatterPlotBindingYValues;
extern NSString *const CPTScatterPlotBindingPlotSymbols;
/// @}

/**
 *  @brief Enumeration of scatter plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTScatterPlotField) {
    CPTScatterPlotFieldX, ///< X values.
    CPTScatterPlotFieldY  ///< Y values.
};

/**
 *  @brief Enumeration of scatter plot interpolation algorithms
 **/
typedef NS_ENUM (NSInteger, CPTScatterPlotInterpolation) {
    CPTScatterPlotInterpolationLinear,    ///< Linear interpolation.
    CPTScatterPlotInterpolationStepped,   ///< Steps beginning at data point.
    CPTScatterPlotInterpolationHistogram, ///< Steps centered at data point.
    CPTScatterPlotInterpolationCurved     ///< Bezier curve interpolation.
};

#pragma mark -

/**
 *  @brief A scatter plot data source.
 **/
@protocol CPTScatterPlotDataSource<CPTPlotDataSource>

@optional

/// @name Plot Symbols
/// @{

/** @brief @optional Gets a range of plot symbols for the given scatter plot.
 *  @param plot The scatter plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of plot symbols.
 **/
-(NSArray *)symbolsForScatterPlot:(CPTScatterPlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a single plot symbol for the given scatter plot.
 *  This method will not be called if
 *  @link CPTScatterPlotDataSource::symbolsForScatterPlot:recordIndexRange: -symbolsForScatterPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The scatter plot.
 *  @param idx The data index of interest.
 *  @return The plot symbol to show for the point with the given index.
 **/
-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Scatter plot delegate.
 **/
@protocol CPTScatterPlotDelegate<CPTPlotDelegate>

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly a touch ended @endif
 *  while over the plot line.
 *  @param plot The scatter plot.
 **/
-(void)plotLineWasSelectedForScatterPlot:(CPTScatterPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly a touch ended @endif
 *  while over a scatter plot line.
 *  @param plot The scatter plot.
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotLineWasSelectedWithEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly a touch ended @endif
 *  while not over the plot line and that the line has been deselected.
 *  @param plot The scatter plot.
 **/
-(void)plotLineWasDeselectedForScatterPlot:(CPTScatterPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly a touch ended @endif
 *  while not over a scatter plot line.
 *  @param plot The scatter plot and that the line has been deselected.
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotLineWasDeselectedWithEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the plot line was pressed. @endif
 *  @if iOSOnly a touch started on the plot line. @endif
 *  @param plot The scatter plot.
 **/
-(void)plotLineTouchDownForScatterPlot:(CPTScatterPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the plot line was pressed. @endif
 *  @if iOSOnly a touch started on the plot line. @endif
 *  @param plot The scatter plot.
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotLineTouchDownWithEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly touch ended @endif
 *  while over the plot line.
 *  @param plot The scatter plot.
 **/
-(void)plotLineTouchUpForScatterPlot:(CPTScatterPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly touch ended @endif
 *  while over the plot line.
 *  @param plot The scatter plot.
 *  @param event The event that triggered the selection.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotLineTouchUpWithEvent:(CPTNativeEvent *)event;

/** @brief @optional Gives the delegate an opportunity to do something just before the
 *  plot line will be drawn. A common operation is to draw a selection indicator for the
 *  plot line. This is called after the plot fill has been drawn.
 *  @param plot The scatter plot and that the line has been deselected.
 *  @param dataLinePath The CGPath describing the plot line that is about to be drawn.
 *  @param context The graphics context in which the plot line will be drawn.
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot prepareForDrawingPlotLine:(CGPathRef)dataLinePath inContext:(CGContextRef)context;

/// @}

@end

#pragma mark -

@interface CPTScatterPlot : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite) NSDecimal areaBaseValue;
@property (nonatomic, readwrite) NSDecimal areaBaseValue2;
@property (nonatomic, readwrite, assign) CPTScatterPlotInterpolation interpolation;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPTPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy) CPTFill *areaFill;
@property (nonatomic, readwrite, copy) CPTFill *areaFill2;
/// @}

/// @name User Interaction
/// @{
@property (nonatomic, readwrite, assign) CGFloat plotSymbolMarginForHitDetection;
@property (nonatomic, readwrite, assign) CGFloat plotLineMarginForHitDetection;
@property (nonatomic, readwrite, assign) BOOL allowSimultaneousSymbolAndPlotSelection;
/// @}

/// @name Visible Points
/// @{
-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint;
-(CGPoint)plotAreaPointOfVisiblePointAtIndex:(NSUInteger)idx;
/// @}

/// @name Plot Symbols
/// @{
-(CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)idx;
/// @}

@end
