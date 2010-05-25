#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface CPPlotSymbolTestController : NSObject <CPScatterPlotDataSource> {
    IBOutlet CPLayerHostingView *hostView;
	CPXYGraph *graph;
}

@end
