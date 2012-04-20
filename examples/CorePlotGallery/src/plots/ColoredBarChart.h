#import "PlotItem.h"

@interface ColoredBarChart : PlotItem<CPTPlotSpaceDelegate,
                                      CPTPlotDataSource,
                                      CPTBarPlotDelegate>
{
    NSArray *plotData;
}

@end
