

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSObject <CPPlotDataSource> {
    IBOutlet CPLayerHostingView *hostView;
    CPXYGraph *graph;
    NSArray *plotData;
}

@end

