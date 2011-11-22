#import "CPTTestCase.h"
#import <CorePlot/CorePlot.h>

@interface CPTScatterPlotTests : CPTTestCase {
	CPTScatterPlot *plot;
	CPTXYPlotSpace *plotSpace;
}

@property (retain) CPTScatterPlot *plot;
@property (retain) CPTXYPlotSpace *plotSpace;

@end
