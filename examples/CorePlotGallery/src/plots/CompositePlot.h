//
//  CompositePlot.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface CompositePlot : PlotItem<CPTPlotSpaceDelegate,
                                    CPTScatterPlotDataSource,
                                    CPTScatterPlotDelegate,
                                    CPTBarPlotDelegate>

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForPlot;

-(void)renderScatterPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;
-(void)renderBarPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;
-(void)renderPieChartInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;

@end
