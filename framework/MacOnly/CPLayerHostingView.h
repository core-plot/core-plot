#import <Cocoa/Cocoa.h>

@class CPLayer;

@interface CPLayerHostingView : NSView {
	@protected
	CPLayer *hostedLayer, *layerBeingClickedOn;
}

@property (nonatomic, readwrite, retain) CPLayer *hostedLayer;

@end
