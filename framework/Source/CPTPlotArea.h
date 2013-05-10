#import "CPTAnnotationHostLayer.h"
#import "CPTGraph.h"
#import "CPTLayer.h"

@class CPTAxis;
@class CPTAxisLabelGroup;
@class CPTAxisSet;
@class CPTGridLineGroup;
@class CPTPlotGroup;
@class CPTLineStyle;
@class CPTFill;

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

/// @name Axis Set Layer Management
/// @{
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType;
/// @}

@end
