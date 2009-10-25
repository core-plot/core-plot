#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface AxisDemoController : NSObject {
    IBOutlet CPLayerHostingView *hostView;
	CPXYGraph *graph;
}

@end
