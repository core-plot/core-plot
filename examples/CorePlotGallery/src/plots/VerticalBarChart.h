//
//  SimpleBarGraph.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import "PlotGallery.h"

@interface VerticalBarChart : PlotItem <CPPlotSpaceDelegate,
                                        CPPlotDataSource,
                                        CPBarPlotDelegate>
{
    CPLayerAnnotation   *symbolTextAnnotation;

    CGFloat             xShift;
    CGFloat             yShift;

    CGFloat             labelRotation;

    NSArray             *plotData;
}

@end
