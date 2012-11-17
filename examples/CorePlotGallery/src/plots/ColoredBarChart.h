#import "PlotItem.h"

@interface ColoredBarChart : PlotItem<CPTPlotSpaceDelegate,
                                      CPTPlotDataSource,
                                      CPTBarPlotDelegate>
{
    @private
    NSArray *plotData;
}

@end
