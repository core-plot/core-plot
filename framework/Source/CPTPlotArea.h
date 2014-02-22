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

/** @brief @optional Informs the delegate that a plot area was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plotArea The plot area.
 **/
-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea;

/** @brief @optional Informs the delegate that a plot area was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plotArea The plot area.
 *  @param event The event that triggered the selection.
 **/
-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea withEvent:(CPTNativeEvent *)event;

/// @}

@end

#pragma mark -

@interface CPTPlotArea : CPTAnnotationHostLayer {
    @private
    CPTGridLineGroup *minorGridLineGroup;
    CPTGridLineGroup *majorGridLineGroup;
    CPTAxisSet *axisSet;
    CPTPlotGroup *plotGroup;
    CPTAxisLabelGroup *axisLabelGroup;
    CPTAxisLabelGroup *axisTitleGroup;
    CPTFill *fill;
    NSArray *topDownLayerOrder;
    CPTGraphLayerType *bottomUpLayerOrder;
    BOOL updatingLayers;
}

/// @name Layers
/// @{
@property (nonatomic, readwrite, retain) CPTGridLineGroup *minorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTGridLineGroup *majorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPTPlotGroup *plotGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisLabelGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisTitleGroup;
/// @}

/// @name Layer Ordering
/// @{
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;
/// @}

/// @name Decorations
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
/// @}

/// @name Axis Set Layer Management
/// @{
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType;
/// @}

@end
