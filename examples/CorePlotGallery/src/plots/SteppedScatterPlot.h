//
//  SteppedScatterPlot.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface SteppedScatterPlot : PlotItem <CPTPlotSpaceDelegate,
                                          CPTPlotDataSource,
                                          CPTScatterPlotDelegate>
{
    CGFloat     xShift;
    CGFloat     yShift;
    
    CGFloat     labelRotation;
    
    NSArray     *plotData;
}

@end
