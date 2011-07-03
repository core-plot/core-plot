#import "PlotItem.h"

@interface DonutChart : PlotItem <CPTPlotSpaceDelegate, CPTPlotDataSource>
{
    NSArray *plotData;
}

@end
