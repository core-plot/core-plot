//
//  VectorFieldPlot.h
//   CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "PlotItem.h"

@interface VectorFieldPlot : PlotItem<CPTPlotSpaceDelegate,
                                CPTVectorFieldPlotDelegate,
                                CPTVectorFieldPlotDataSource>

@end
