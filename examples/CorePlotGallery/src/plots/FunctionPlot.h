#import "PlotItem.h"

@interface FunctionPlot : PlotItem<CPTLegendDelegate> {
    @private
    NSMutableSet *dataSources;
}

@end
