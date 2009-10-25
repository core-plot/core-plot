
#import "CPTestCase.h"
#import "CPPlot.h"

@class CPPlotRange;
@class CPPlot;

@interface CPDataSourceTestCase : CPTestCase <CPPlotDataSource> {
    NSArray *xData, *yData;
    CPPlotRange *xRange, *yRange;
    
    NSMutableArray *plots;
    
    NSUInteger nRecords;
}

@property (copy,readwrite) NSArray *xData;
@property (copy,readwrite) NSArray *yData;
@property (assign,readwrite) NSUInteger nRecords;
@property (retain,readonly) CPPlotRange * xRange;
@property (retain,readonly) CPPlotRange * yRange;
@property (retain,readwrite) NSMutableArray *plots;

- (void)buildData;

/**
If you are using this data source for more than one plot, you must call addPlot:
 for each plot.
 */
- (void)addPlot:(CPPlot*)newPlot;
@end
