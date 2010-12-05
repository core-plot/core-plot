#import "PlotItem.h"
#import "PlotGallery.h"

@interface DonutChart : PlotItem <CPPlotSpaceDelegate, CPPlotDataSource>
{
    NSArray *plotData;
}

@end
