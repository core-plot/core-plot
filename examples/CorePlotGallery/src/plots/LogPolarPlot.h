//
//  LogPolarPlot.h
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//


#import "PlotItem.h"

@interface LogPolarPlot : PlotItem<CPTPlotAreaDelegate,
                                        CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTPolarPlotDelegate>


@end

