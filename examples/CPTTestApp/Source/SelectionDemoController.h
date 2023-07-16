@import Cocoa;
@import CorePlot;

@interface SelectionDemoController : NSObject<CPTScatterPlotDataSource,
                                              CPTScatterPlotDelegate,
                                              CPTPlotSpaceDelegate>

@end
