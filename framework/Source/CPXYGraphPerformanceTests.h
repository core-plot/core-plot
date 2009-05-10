
#import "CPDataSourceTestCase.h"
#import "CPXYGraph.h"

@interface CPXYGraphPerformanceTests : CPDataSourceTestCase {
    CPXYGraph *graph;
    
}

@property (retain,readwrite) CPXYGraph *graph;

- (void)addScatterPlot;
@end