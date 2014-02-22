//
//  CurvedScatterPlot.h
//  Plot_Gallery_iOS
//
//  Created by Nino Ag on 23/10/11.

#import "PlotItem.h"

@interface CurvedScatterPlot : PlotItem<CPTPlotAreaDelegate,
                                        CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTScatterPlotDelegate>
{
    @private
    CPTPlotSpaceAnnotation *symbolTextAnnotation;

    NSArray *plotData;
    NSArray *plotData1;
    NSArray *plotData2;
}

@end
