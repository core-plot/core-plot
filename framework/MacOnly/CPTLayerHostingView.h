#import <Cocoa/Cocoa.h>

@class CPTLayer;

@interface CPTLayerHostingView : NSView {
	@private
	CPTLayer *hostedLayer;
}

@property (nonatomic, readwrite, retain) CPTLayer *hostedLayer;

@end
