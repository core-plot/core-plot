#import "PlotItem.h"

@interface DonutChart : PlotItem<CPTPlotSpaceDelegate, CPTPlotDataSource, CPTAnimationDelegate>
{
    @private
    NSArray *plotData;
}

@end
