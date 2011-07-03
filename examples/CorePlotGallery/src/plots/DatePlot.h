//
//  DatePlot.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface DatePlot : PlotItem < CPTPlotSpaceDelegate,
                                 CPTPlotDataSource,
                                 CPTScatterPlotDelegate>
{    
    CGFloat     labelRotation;
    NSArray     *plotData;
}

@end
