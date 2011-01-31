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

@interface CompositePlot : PlotItem <CPPlotSpaceDelegate,
									 CPPlotDataSource,
									 CPScatterPlotDelegate,
									 CPBarPlotDelegate>
{
    CPGraphHostingView  *scatterPlotView;
    CPGraphHostingView  *barChartView;
    CPGraphHostingView  *pieChartView;

    CPXYGraph           *scatterPlot;
    CPXYGraph           *barChart;
    CPXYGraph           *pieChart;

    NSMutableArray      *dataForChart;
    NSMutableArray      *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray  *dataForChart;
@property(readwrite, retain, nonatomic) NSMutableArray  *dataForPlot;

- (void)renderScatterPlotInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme;
- (void)renderBarPlotInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme;
- (void)renderPieChartInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme;

@end
