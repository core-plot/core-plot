//
//  SimpleScatterPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface SimpleScatterPlot : PlotItem<CPTPlotAreaDelegate,
                                        CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTScatterPlotDelegate>

@end
