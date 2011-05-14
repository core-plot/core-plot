#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface SelectionDemoController : NSObject <CPTScatterPlotDataSource, CPTPlotSpaceDelegate> {
    IBOutlet CPTLayerHostingView *hostView;
	CPTXYGraph *graph;
	NSMutableArray *dataForPlot;
	NSUInteger selectedIndex;
}

@end
