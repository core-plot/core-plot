//
//  OHLCPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface OHLCPlot : PlotItem<CPTPlotDataSource, CPTTradingRangePlotDelegate>
{
	@private
	CPTGraph *graph;
	NSArray *plotData;
}

@end
