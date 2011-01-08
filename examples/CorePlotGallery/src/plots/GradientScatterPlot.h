//
//  GradientScatterPlot.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import "PlotGallery.h"

@interface GradientScatterPlot : PlotItem <	CPPlotSpaceDelegate,
                                            CPPlotDataSource,
                                            CPScatterPlotDelegate>
{
    CPLayerAnnotation   *symbolTextAnnotation;

    CGFloat             xShift;
    CGFloat             yShift;

    CGFloat             labelRotation;

    NSArray*            plotData;
}

@end
