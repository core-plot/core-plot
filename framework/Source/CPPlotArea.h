#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPGraph.h"
#import "CPAnnotationHostLayer.h"

@class CPAxis;
@class CPAxisLabelGroup;
@class CPAxisSet;
@class CPGridLineGroup;
@class CPPlotGroup;
@class CPLineStyle;
@class CPFill;

@interface CPPlotArea : CPAnnotationHostLayer {
@private
	CPGridLineGroup *minorGridLineGroup;
	CPGridLineGroup *majorGridLineGroup;
	CPAxisSet *axisSet;
	CPPlotGroup *plotGroup;
	CPAxisLabelGroup *axisLabelGroup;
	CPAxisLabelGroup *axisTitleGroup;
	CPFill *fill;
	NSArray *topDownLayerOrder;
	CPGraphLayerType *bottomUpLayerOrder;
	BOOL updatingLayers;
}

/// @name Layers
/// @{
@property (nonatomic, readwrite, retain) CPGridLineGroup *minorGridLineGroup;
@property (nonatomic, readwrite, retain) CPGridLineGroup *majorGridLineGroup;
@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotGroup *plotGroup;
@property (nonatomic, readwrite, retain) CPAxisLabelGroup *axisLabelGroup;
@property (nonatomic, readwrite, retain) CPAxisLabelGroup *axisTitleGroup;
///	@}

/// @name Layer ordering
/// @{
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;
///	@}

/// @name Decorations
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPFill *fill;
///	@}

/// @name Axis set layer management
/// @{
-(void)updateAxisSetLayersForType:(CPGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPAxis *)axis layerType:(CPGraphLayerType)layerType;
///	@}

@end
