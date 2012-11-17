#import "PlotItem.h"

@interface DonutChart : PlotItem<CPTPlotSpaceDelegate, CPTPlotDataSource>
{
    @private
    NSArray *plotData;
}

@end
