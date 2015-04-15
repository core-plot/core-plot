//
//  SimpleBarGraph.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface VerticalBarChart : PlotItem<CPTPlotSpaceDelegate,
                                       CPTPlotDataSource,
                                       CPTBarPlotDelegate>

@end
