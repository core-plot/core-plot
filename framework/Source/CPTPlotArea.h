#import "CPTAnnotationHostLayer.h"
#import "CPTGraph.h"
#import "CPTLayer.h"

@class CPTAxis;
@class CPTAxisLabelGroup;
@class CPTAxisSet;
@class CPTGridLineGroup;
@class CPTPlotArea;
@class CPTPlotGroup;
@class CPTLineStyle;
@class CPTFill;

/**
 *  @brief Plot area delegate.
 **/
@protocol CPTPlotAreaDelegate<NSObject>

@optional

/// @name Plot Area Selection
/// @{

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plotArea The plot area.
 **/
-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea;

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plotArea The plot area.
 *  @param event The event that triggered the selection.
 **/
-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plotArea The plot area.
 **/
-(void)plotAreaTouchDown:(CPTPlotArea *)plotArea;

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plotArea The plot area.
 *  @param event The event that triggered the selection.
 **/
-(void)plotAreaTouchDown:(CPTPlotArea *)plotArea withEvent:(CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plotArea The plot area.
 **/
-(void)plotAreaTouchUp:(CPTPlotArea *)plotArea;

/** @brief @optional Informs the delegate that a plot area
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plotArea The plot area.
 *  @param event The event that triggered the selection.
 **/
-(void)plotAreaTouchUp:(CPTPlotArea *)plotArea withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTPlotArea : CPTAnnotationHostLayer
/// @name Layers
/// @{
@property (nonatomic, readwrite, strong) CPTGridLineGroup *minorGridLineGroup;
@property (nonatomic, readwrite, strong) CPTGridLineGroup *majorGridLineGroup;
@property (nonatomic, readwrite, strong) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, strong) CPTPlotGroup *plotGroup;
@property (nonatomic, readwrite, strong) CPTAxisLabelGroup *axisLabelGroup;
@property (nonatomic, readwrite, strong) CPTAxisLabelGroup *axisTitleGroup;
/// @}

/// @name Layer Ordering
/// @{
@property (nonatomic, readwrite, strong) NSArray *topDownLayerOrder;
/// @}

/// @name Decorations
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
/// @}

/// @name Dimensions
/// @{
@property (nonatomic, readonly) NSDecimal widthDecimal;
@property (nonatomic, readonly) NSDecimal heightDecimal;
/// @}

/// @name Axis Set Layer Management
/// @{
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType;
/// @}

@end
