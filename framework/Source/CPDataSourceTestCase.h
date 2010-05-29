#import "CPTestCase.h"
#import "CPPlot.h"

@class CPPlotRange;
@class CPPlot;

@interface CPDataSourceTestCase : CPTestCase <CPPlotDataSource> {
@private
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

-(void)buildData;

-(void)addPlot:(CPPlot*)newPlot;

@end
