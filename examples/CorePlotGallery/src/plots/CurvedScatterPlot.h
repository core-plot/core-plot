//
//  CurvedScatterPlot.h
//  Plot_Gallery_iOS
//
//  Created by Nino Ag on 23/10/11.

#import "PlotItem.h"

@interface CurvedScatterPlot : PlotItem<CPTPlotSpaceDelegate,
										CPTPlotDataSource,
										CPTScatterPlotDelegate>
{
	CPTPlotSpaceAnnotation *symbolTextAnnotation;

	NSArray *plotData;
}

@end
