#import "CPTTestCase.h"
#import <CorePlot/CorePlot.h>

@interface CPTScatterPlotTests : CPTTestCase {
    CPTScatterPlot *plot;
    CPTXYPlotSpace *plotSpace;
}

@property (strong) CPTScatterPlot *plot;
@property (strong) CPTXYPlotSpace *plotSpace;

@end
