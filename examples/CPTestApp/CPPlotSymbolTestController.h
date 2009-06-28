#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface CPPlotSymbolTestController : NSObject <CPPlotDataSource> {
    IBOutlet CPLayerHostingView *hostView;
	CPXYGraph *graph;
}

@end
