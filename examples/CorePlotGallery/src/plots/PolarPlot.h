//
//  PolarPlot.h
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//


#import "PlotItem.h"

@interface PolarPlot : PlotItem<CPTPlotAreaDelegate,
                                        CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTPolarPlotDelegate, CPTAxisDelegate>


@end
