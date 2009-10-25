
#import "CPScatterPlotTests.h"
#import "CPDataSourceTestCase.h"

@class CPScatterPlot;


@interface CPScatterPlotPerformanceTests  : CPDataSourceTestCase {
    CPScatterPlot *plot;
}

@property (retain,readwrite) CPScatterPlot *plot;

- (void)setPlotRanges;
@end
