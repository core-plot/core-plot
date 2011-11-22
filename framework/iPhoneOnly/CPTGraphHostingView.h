#import "CPTDefinitions.h"
#import <UIKit/UIKit.h>

@class CPTGraph;

@interface CPTGraphHostingView : UIView {
	@protected
	CPTGraph *hostedGraph;
	BOOL collapsesLayers;
	BOOL allowPinchScaling;
	__cpt_weak id pinchGestureRecognizer;
}

@property (nonatomic, readwrite, retain) CPTGraph *hostedGraph;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;

@end
