#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface SelectionDemoController : NSObject <CPScatterPlotDataSource, CPPlotSpaceDelegate> {
    IBOutlet CPLayerHostingView *hostView;
	CPXYGraph *graph;
	NSMutableArray *dataForPlot;
	NSUInteger selectedIndex;
}

@end
