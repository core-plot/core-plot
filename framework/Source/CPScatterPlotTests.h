#import "CPTestCase.h"
#import <CorePlot/CorePlot.h>


@interface CPScatterPlotTests : CPTestCase {
	CPScatterPlot *plot;
    CPXYPlotSpace *plotSpace;
}

@property (retain) CPScatterPlot *plot;
@property (retain) CPXYPlotSpace *plotSpace;

@end
