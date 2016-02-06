//
// GradientScatterPlot.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface GradientScatterPlot : PlotItem<CPTPlotAreaDelegate,
                                          CPTPlotSpaceDelegate,
                                          CPTPlotDataSource,
                                          CPTScatterPlotDelegate>

@end
