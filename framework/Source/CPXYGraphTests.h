
#import "CPTestCase.h"
#import "CPXYGraph.h"
#import "CPPlot.h"

@interface CPXYGraphTests : CPTestCase <CPPlotDataSource> {
    CPXYGraph *graph;
    
    NSArray *xData;
    NSArray *yData;
}

@property (retain,readwrite) CPXYGraph *graph;

@property (copy,readwrite) NSArray *xData;
@property (copy,readwrite) NSArray *yData;

@end
