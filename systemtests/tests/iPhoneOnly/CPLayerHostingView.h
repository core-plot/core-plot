#import <UIKit/UIKit.h>

@class CPLayer;

@interface CPLayerHostingView : UIView {
@protected
	CPLayer *hostedLayer, *layerBeingTouched;

}

@property (nonatomic, readwrite, retain) CPLayer *hostedLayer;

@end
