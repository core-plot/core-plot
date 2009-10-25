
#import "CPDataSourceTestCase.h"
#import "CPScatterPlot.h"

@interface CPScatterPlotTests : CPDataSourceTestCase {
    CPScatterPlot *plot;
}

@property (retain,readwrite) CPScatterPlot *plot;

- (void)setPlotRanges;

@end
