#import "CPTestCase.h"
#import <CorePlot/CorePlot.h>


@interface CPScatterPlotTests : CPTestCase {
	CPScatterPlot *plot;
    CPPlotRange *plotRange;
}

@property (retain) CPScatterPlot *plot;
@property (retain) CPPlotRange *plotRange;

@end
