#import <UIKit/UIKit.h>

@class CPLayer;

@interface CPLayerHostingView : UIView {
	@protected
	CPLayer *hostedLayer;
	BOOL collapsesLayers;
}

@property (nonatomic, readwrite, retain) CPLayer *hostedLayer;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;

@end
