//
//  CompositePlot.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface CompositePlot : PlotItem<CPTPlotSpaceDelegate,
                                    CPTScatterPlotDataSource,
                                    CPTScatterPlotDelegate,
                                    CPTBarPlotDelegate>

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForPlot;

-(void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;
-(void)renderBarPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;
-(void)renderPieChartInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;

@end
