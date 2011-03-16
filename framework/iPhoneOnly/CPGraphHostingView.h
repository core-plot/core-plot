#import <UIKit/UIKit.h>

@class CPGraph;

@interface CPGraphHostingView : UIView {
	@protected
	CPGraph *hostedGraph;
	BOOL collapsesLayers;
    BOOL allowPinchScaling;
    id pinchGestureRecognizer;
}

@property (nonatomic, readwrite, retain) CPGraph *hostedGraph;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;

@end
