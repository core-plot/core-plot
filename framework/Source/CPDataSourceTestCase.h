
#import "CPTestCase.h"
#import "CPPlot.h"

@class CPPlotRange;

@interface CPDataSourceTestCase : CPTestCase <CPPlotDataSource> {
    NSArray *xData, *yData;
    CPPlotRange *xRange, *yRange;
    
    NSUInteger nRecords;
}

@property (copy,readwrite) NSArray *xData;
@property (copy,readwrite) NSArray *yData;
@property (assign,readwrite) NSUInteger nRecords;
@property (retain,readonly) CPPlotRange * xRange;
@property (retain,readonly) CPPlotRange * yRange;


- (void)buildData;
@end
