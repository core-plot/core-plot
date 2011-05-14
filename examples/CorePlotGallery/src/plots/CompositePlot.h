//
//  CompositePlot.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	#import "CorePlot-CocoaTouch.h"
#else
	#import <CorePlot/CorePlot.h>
#endif
#import "PlotItem.h"
#import "PlotGallery.h"

@interface CompositePlot : PlotItem <CPTPlotSpaceDelegate,
									 CPTPlotDataSource,
									 CPTScatterPlotDelegate,
									 CPTBarPlotDelegate>
{
    CPTGraphHostingView  *scatterPlotView;
    CPTGraphHostingView  *barChartView;
    CPTGraphHostingView  *pieChartView;

    CPTXYGraph           *scatterPlot;
    CPTXYGraph           *barChart;
    CPTXYGraph           *pieChart;

    NSMutableArray      *dataForChart;
    NSMutableArray      *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray  *dataForChart;
@property(readwrite, retain, nonatomic) NSMutableArray  *dataForPlot;

- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;
- (void)renderBarPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;
- (void)renderPieChartInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;

@end
