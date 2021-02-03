//
//  VectorFieldContinuousPlot.h
//   CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "PlotItem.h"

@interface VectorFieldContinuousPlot : PlotItem<CPTPlotSpaceDelegate,
                                CPTVectorFieldPlotDelegate, CPTVectorFieldPlotDataSource>

@end
