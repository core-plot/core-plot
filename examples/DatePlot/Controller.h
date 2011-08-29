

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSObject <CPTPlotDataSource> {
    IBOutlet CPTGraphHostingView *hostView;
    CPTXYGraph *graph;
    NSArray *plotData;
}

@end

