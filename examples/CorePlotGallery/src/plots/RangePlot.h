//
//  RangePlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface RangePlot : PlotItem<CPTPlotSpaceDelegate, CPTPlotDataSource>
{
	@private
	CPTGraph *graph;
	NSArray *plotData;
	CPTFill *areaFill;
	CPTLineStyle *barLineStyle;
}

@end
