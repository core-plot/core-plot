

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSObject <CPTPlotDataSource> {
    IBOutlet CPTLayerHostingView *hostView;
    CPTXYGraph *graph;
    NSArray *plotData;
}

@end

