//
// SimplePieChart.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface SimplePieChart : PlotItem<CPTPlotSpaceDelegate,
                                     CPTPieChartDelegate,
                                     CPTLegendDelegate,
                                     CPTPlotDataSource>

@end
