//
//  CandlestickPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface CandlestickPlot : PlotItem <CPTPlotSpaceDelegate, CPTPlotDataSource>
{
@private
	CPTGraph		*graph;
    NSArray			*plotData;
}

@end
