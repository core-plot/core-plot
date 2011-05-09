//
//  SimpleBarGraph.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import "PlotGallery.h"

@interface VerticalBarChart : PlotItem <CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTBarPlotDelegate>
{
    CPTLayerAnnotation   *symbolTextAnnotation;

    CGFloat             xShift;
    CGFloat             yShift;

    CGFloat             labelRotation;

    NSArray             *plotData;
}

@end
