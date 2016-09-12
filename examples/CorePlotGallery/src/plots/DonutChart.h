#import "PlotItem.h"

@interface DonutChart : PlotItem<CPTPlotSpaceDelegate,
                                 CPTPlotDataSource,
                                 CPTPieChartDelegate,
                                 CPTAnimationDelegate>

@end
