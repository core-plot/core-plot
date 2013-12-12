#import "CPTDefinitions.h"

@class CPTGraph;

@interface CPTGraphHostingView : UIView

@property (nonatomic, readwrite, strong) CPTGraph *hostedGraph;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;

@end
