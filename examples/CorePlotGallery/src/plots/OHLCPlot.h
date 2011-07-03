//
//  OHLCPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface OHLCPlot : PlotItem <CPTPlotDataSource>
{
@private
	CPTGraph		*graph;
    NSArray			*plotData;
}

@end
