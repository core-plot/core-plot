#import "CPTTestCase.h"

#import "CPTPlot.h"

@class CPTMutablePlotRange;

@interface CPTDataSourceTestCase : CPTTestCase<CPTPlotDataSource>

@property (nonatomic, readwrite, copy) CPTNumberArray *xData;
@property (nonatomic, readwrite, copy) CPTNumberArray *yData;
@property (nonatomic, readwrite, assign) NSUInteger nRecords;
@property (nonatomic, readonly, strong) CPTPlotRange *xRange;
@property (nonatomic, readonly, strong) CPTPlotRange *yRange;
@property (nonatomic, readwrite, strong) CPTMutablePlotArray plots;

-(void)buildData;

-(void)addPlot:(CPTPlot *)newPlot;

@end
