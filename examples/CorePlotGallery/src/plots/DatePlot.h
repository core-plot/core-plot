//
// DatePlot.h
// Plot Gallery-Mac
//

#import "PlotItem.h"

@interface DatePlot : PlotItem<CPTPlotSpaceDelegate,
                               CPTPlotDataSource,
                               CPTScatterPlotDelegate>

@end
