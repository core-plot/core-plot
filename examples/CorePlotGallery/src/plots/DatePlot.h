//
//  DatePlot.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import "PlotGallery.h"

@interface DatePlot : PlotItem < CPPlotSpaceDelegate,
                                 CPPlotDataSource,
                                 CPScatterPlotDelegate>
{    
    CGFloat     labelRotation;
    NSArray     *plotData;
}

@end
