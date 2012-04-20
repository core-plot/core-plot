#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface SelectionDemoController : NSObject<CPTScatterPlotDataSource, CPTPlotSpaceDelegate> {
    IBOutlet CPTGraphHostingView *hostView;
    CPTXYGraph *graph;
    NSMutableArray *dataForPlot;
    NSUInteger selectedIndex;
}

@end
