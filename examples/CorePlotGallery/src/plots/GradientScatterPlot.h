//
//  GradientScatterPlot.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface GradientScatterPlot : PlotItem <	CPTPlotSpaceDelegate,
                                            CPTPlotDataSource,
                                            CPTScatterPlotDelegate>
{
    CPTLayerAnnotation   *symbolTextAnnotation;

    NSArray*            plotData;
}

@end
