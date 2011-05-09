#import <Foundation/Foundation.h>
#import "CPTLayer.h"
#import "CPTGraph.h"
#import "CPTAnnotationHostLayer.h"

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
@property (nonatomic, readwrite, retain) CPTGridLineGroup *minorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTGridLineGroup *majorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPTPlotGroup *plotGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisLabelGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisTitleGroup;
///	@}

/// @name Layer ordering
/// @{
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;
///	@}

/// @name Decorations
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
///	@}

/// @name Axis set layer management
/// @{
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType;
///	@}

@end
