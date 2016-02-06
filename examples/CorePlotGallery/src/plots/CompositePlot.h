//
// CompositePlot.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface CompositePlot : PlotItem<CPTPlotSpaceDelegate,
                                    CPTScatterPlotDataSource,
                                    CPTScatterPlotDelegate,
                                    CPTBarPlotDelegate>

@property (readwrite, strong, nonatomic) CPTMutableNumberArray dataForChart;
@property (readwrite, strong, nonatomic) NSMutableArray<NSDictionary *> *dataForPlot;

-(void)renderScatterPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;
-(void)renderBarPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;
-(void)renderPieChartInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme;

@end
