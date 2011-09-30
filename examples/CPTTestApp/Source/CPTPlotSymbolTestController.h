#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface CPTPlotSymbolTestController : NSObject<CPTScatterPlotDataSource> {
	IBOutlet CPTGraphHostingView *hostView;
	CPTXYGraph *graph;
}

@end
