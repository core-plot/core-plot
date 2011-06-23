//
//  OHLCPlot.h
//  CorePlotGallery
//

#import "PlotItem.h"
#import "PlotGallery.h"

@interface OHLCPlot : PlotItem <CPTPlotDataSource>
{
@private
	CPTGraph		*graph;
    NSArray			*plotData;
}

@end
