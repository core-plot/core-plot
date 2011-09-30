#import "CPTPlot.h"
#import "CPTTestCase.h"

@class CPTPlotRange;
@class CPTPlot;

@interface CPTDataSourceTestCase : CPTTestCase<CPTPlotDataSource>{
	@private
	NSArray *xData, *yData;
	CPTPlotRange *xRange, *yRange;

	NSMutableArray *plots;

	NSUInteger nRecords;
}

@property (copy, readwrite) NSArray *xData;
@property (copy, readwrite) NSArray *yData;
@property (assign, readwrite) NSUInteger nRecords;
@property (retain, readonly) CPTPlotRange *xRange;
@property (retain, readonly) CPTPlotRange *yRange;
@property (retain, readwrite) NSMutableArray *plots;

-(void)buildData;

-(void)addPlot:(CPTPlot *)newPlot;

@end
