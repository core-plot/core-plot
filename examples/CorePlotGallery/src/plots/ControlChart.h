#import "PlotItem.h"

@interface ControlChart : PlotItem<CPTPlotDataSource>
{
    @private
    NSArray *plotData;
    double meanValue;
    double standardError;
}

@end
