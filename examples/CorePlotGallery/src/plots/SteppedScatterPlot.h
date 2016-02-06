//
// SteppedScatterPlot.h
// Plot Gallery-Mac
//

#import "PlotItem.h"

@interface SteppedScatterPlot : PlotItem<CPTPlotSpaceDelegate,
                                         CPTPlotDataSource,
                                         CPTScatterPlotDelegate>
@end
