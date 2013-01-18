#import "CPTTestCase.h"

#import "CPTPlot.h"

@class CPTMutablePlotRange;

@interface CPTDataSourceTestCase : CPTTestCase<CPTPlotDataSource> {
    @private
    NSArray *xData, *yData;
    NSMutableArray *plots;

    NSUInteger nRecords;
}

@property (copy, readwrite) NSArray *xData;
@property (copy, readwrite) NSArray *yData;
@property (assign, readwrite) NSUInteger nRecords;
@property (retain, readonly) CPTMutablePlotRange *xRange;
@property (retain, readonly) CPTMutablePlotRange *yRange;
@property (retain, readwrite) NSMutableArray *plots;

-(void)buildData;

-(void)addPlot:(CPTPlot *)newPlot;

@end
