#import <Cocoa/Cocoa.h>

@class CPTGraph;

@interface CPTGraphHostingView : NSView {
	@private
	CPTGraph *hostedGraph;
}

@property (nonatomic, readwrite, retain) CPTGraph *hostedGraph;

@end
