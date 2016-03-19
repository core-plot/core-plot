//
// CompositePlot.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface CompositePlot : PlotItem<CPTPlotSpaceDelegate,
                                    CPTScatterPlotDataSource,
                                    CPTScatterPlotDelegate,
                                    CPTBarPlotDelegate>

@property (readwrite, strong, nonatomic, nonnull) CPTMutableNumberArray dataForChart;
@property (readwrite, strong, nonatomic, nonnull) NSMutableArray<NSDictionary *> *dataForPlot;

-(void)renderScatterPlotInHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme;
-(void)renderBarPlotInHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme;
-(void)renderPieChartInHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme;

@end
