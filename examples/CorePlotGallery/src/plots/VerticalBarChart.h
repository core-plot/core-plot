//
//  SimpleBarGraph.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface VerticalBarChart : PlotItem<CPTPlotSpaceDelegate,
                                       CPTPlotDataSource,
                                       CPTBarPlotDelegate>

@end
