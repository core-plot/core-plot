#import "CPTDefinitions.h"
#import "CPTLimitBand.h"
#import "CPTPlot.h"
#import "CPTPlotSymbol.h"
#import "CPTDefinitions.h"
#import "CPTNumericDataType.h"

/// @file

@class CPTLineStyle;
@class CPTPolarPlot;
@class CPTFill;

/// @ingroup plotBindingsScatterPlot
/// @{
extern NSString *__nonnull const CPTPolarPlotBindingThetaValues;
extern NSString *__nonnull const CPTPolarPlotBindingRadiusValues;
extern NSString *__nonnull const CPTPolarPlotBindingPlotSymbols;
/// @}



/**
 *  @brief Enumeration of polar plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTPolarPlotField) {
    CPTPolarPlotFieldRadialAngle, ///< RadialAngle values.
    CPTPolarPlotFieldRadius  ///< Radius values.
};

/**
 *  @brief Enumeration of polar plot data source field types
 **/
typedef NS_ENUM (NSInteger, CPTPolarPlotCoordinates) {
    CPTPolarPlotCoordinatesX, ///< X values.
    CPTPolarPlotCoordinatesY,  ///< Y values.
    CPTPolarPlotCoordinatesZ  ///< Z values (theta values).
};


/**
 *  @brief Enumeration of polar plot interpolation algorithms
 **/
typedef NS_ENUM (NSInteger, CPTPolarPlotInterpolation) {
    CPTPolarPlotInterpolationLinear,    ///< Linear interpolation.
    CPTPolarPlotInterpolationStepped,   ///< Steps beginning at data point.
    CPTPolarPlotInterpolationHistogram, ///< Steps centered at data point.
    CPTPolarPlotInterpolationCurved     ///< Curved interpolation.
};

/**
 *  @brief Enumration of polar plot curved interpolation style options
 **/
typedef NS_ENUM (NSInteger, CPTPolarPlotCurvedInterpolationOption) {
    CPTPolarPlotCurvedInterpolationNormal,                ///< Standard Curved Interpolation (Bezier Curve)
    CPTPolarPlotCurvedInterpolationCatmullRomUniform,     ///< Catmull-Rom Spline Interpolation with alpha = @num{0.0}.
    CPTPolarPlotCurvedInterpolationCatmullRomCentripetal, ///< Catmull-Rom Spline Interpolation with alpha = @num{0.5}.
    CPTPolarPlotCurvedInterpolationCatmullRomChordal,     ///< Catmull-Rom Spline Interpolation with alpha = @num{1.0}.
    CPTPolarPlotCurvedInterpolationCatmullCustomAlpha,    ///< Catmull-Rom Spline Interpolation with a custom alpha value.
    CPTPolarPlotCurvedInterpolationHermiteCubic           ///< Hermite Cubic Spline Interpolation
};

/**
 *  @brief Enumeration of polar plot histogram style options
 **/
typedef NS_ENUM (NSInteger, CPTPolarPlotHistogramOption) {
    CPTPolarPlotHistogramNormal,     ///< Standard histogram.
    CPTPolarPlotHistogramSkipFirst,  ///< Skip the first step of the histogram.
    CPTPolarPlotHistogramSkipSecond, ///< Skip the second step of the histogram.
    CPTPolarPlotHistogramOptionCount ///< The number of histogram options available.
};

#pragma mark -

/**
 *  @brief A polar plot data source.
 **/
@protocol CPTPolarPlotDataSource<CPTPlotDataSource>

@optional

/// @name Plot Symbols
/// @{

/** @brief @optional Gets a range of plot symbols for the given polar plot.
 *  @param plot The polar plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of plot symbols.
 **/
-(nullable CPTPlotSymbolArray *)symbolsForPolarPlot:(nonnull CPTPolarPlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a single plot symbol for the given polar plot.
 *  This method will not be called if
 *  @link CPTPolarPlotDataSource::symbolsForPolarPlot:recordIndexRange: -symbolsForPolarPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The polar plot.
 *  @param idx The data index of interest.
 *  @return The plot symbol to show for the point with the given index.
 **/
-(nullable CPTPlotSymbol *)symbolForPolarPlot:(nonnull CPTPolarPlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end

#pragma mark -

/**
 *  @brief Scatter plot delegate.
 **/
@protocol CPTPolarPlotDelegate<CPTPlotDelegate>

@optional

/// @name Data Point Selection
/// @{

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data point
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The polar plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/// @}

/// @name Data Line Selection
/// @{

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was both pressed and released on the plot line.@endif
 *  @if iOSOnly the plot line received both the touch down and up events. @endif
 *  @param plot The polar plot.
 **/
-(void)polarPlotDataLineWasSelected:(nonnull CPTPolarPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was both pressed and released on the plot line.@endif
 *  @if iOSOnly the plot line received both the touch down and up events. @endif
 *  @param plot The polar plot.
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot dataLineWasSelectedWithEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was pressed @endif
 *  @if iOSOnly touch started @endif
 *  while over the plot line.
 *  @param plot The polar plot.
 **/
-(void)polarPlotDataLineTouchDown:(nonnull CPTPolarPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was pressed @endif
 *  @if iOSOnly touch started @endif
 *  while over the plot line.
 *  @param plot The polar plot.
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot dataLineTouchDownWithEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly touch ended @endif
 *  while over the plot line.
 *  @param plot The polar plot.
 **/
-(void)polarPlotDataLineTouchUp:(nonnull CPTPolarPlot *)plot;

/** @brief @optional Informs the delegate that
 *  @if MacOnly the mouse was released @endif
 *  @if iOSOnly touch ended @endif
 *  while over the plot line.
 *  @param plot The polar plot.
 *  @param event The event that triggered the selection.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot dataLineTouchUpWithEvent:(nonnull CPTNativeEvent *)event;

/// @}

/// @name Drawing
/// @{

/** @brief @optional Gives the delegate an opportunity to do something just before the
 *  plot line will be drawn. A common operation is to draw a selection indicator for the
 *  plot line. This is called after the plot fill has been drawn.
 *  @param plot The polar plot.
 *  @param dataLinePath The CGPath describing the plot line that is about to be drawn.
 *  @param context The graphics context in which the plot line will be drawn.
 **/
-(void)polarPlot:(nonnull CPTPolarPlot *)plot prepareForDrawingPlotLine:(nonnull CGPathRef)dataLinePath inContext:(nonnull CGContextRef)context;

/// @}

@end

#pragma mark -

@interface CPTPolarPlot : CPTPlot

/// @name Appearance
/// @{
@property (nonatomic, readwrite, strong, nullable) NSNumber *areaBaseValue;
@property (nonatomic, readwrite, strong, nullable) NSNumber *areaBaseValue2;
@property (nonatomic, readwrite, assign) CPTPolarPlotInterpolation interpolation;
@property (nonatomic, readwrite, assign) CPTPolarPlotHistogramOption histogramOption;
@property (nonatomic, readwrite, assign) CPTPolarPlotCurvedInterpolationOption curvedInterpolationOption;
@property (nonatomic, readwrite, assign) CGFloat curvedInterpolationCustomAlpha;
/// @}

/// @name Area Fill Bands
/// @{
@property (nonatomic, readonly, nullable) CPTLimitBandArray *areaFillBands;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy, nullable) CPTPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy, nullable) CPTFill *areaFill;
@property (nonatomic, readwrite, copy, nullable) CPTFill *areaFill2;
/// @}

/// @name Data Line
/// @{
@property (nonatomic, readonly, nonnull) CGPathRef newDataLinePath;
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
-(nullable CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)idx;
-(void)reloadPlotSymbols;
-(void)reloadPlotSymbolsInIndexRange:(NSRange)indexRange;
/// @}

/// @name Area Fill Bands
/// @{
-(void)addAreaFillBand:(nullable CPTLimitBand *)limitBand;
-(void)removeAreaFillBand:(nullable CPTLimitBand *)limitBand;
/// @}

@end
