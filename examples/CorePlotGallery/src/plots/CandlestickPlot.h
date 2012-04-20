//
//  CandlestickPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface CandlestickPlot : PlotItem<CPTPlotSpaceDelegate, CPTTradingRangePlotDelegate, CPTPlotDataSource>
{
    @private
    CPTGraph *graph;
    NSArray *plotData;
}

@end
