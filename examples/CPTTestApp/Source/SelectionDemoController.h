#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface SelectionDemoController : NSObject<CPTScatterPlotDataSource,
                                              CPTScatterPlotDelegate,
                                              CPTPlotSpaceDelegate>

@end
