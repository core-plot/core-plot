#import "CPTTestCase.h"

#import "CPTPlot.h"

@class CPTMutablePlotRange;

@interface CPTDataSourceTestCase : CPTTestCase<CPTPlotDataSource>

@property (copy, readwrite) NSArray *xData;
@property (copy, readwrite) NSArray *yData;
@property (assign, readwrite) NSUInteger nRecords;
@property (readonly) CPTMutablePlotRange *xRange;
@property (readonly) CPTMutablePlotRange *yRange;
@property (strong, readwrite) NSMutableArray *plots;

-(void)buildData;

-(void)addPlot:(CPTPlot *)newPlot;

@end
