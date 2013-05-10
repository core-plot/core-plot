#import <Cocoa/Cocoa.h>

@class CPTGraph;

@interface CPTGraphHostingView : NSView {
    @private
    CPTGraph *hostedGraph;
    NSRect printRect;
}

@property (nonatomic, readwrite, strong) CPTGraph *hostedGraph;
@property (nonatomic, readwrite, assign) NSRect printRect;

@end
