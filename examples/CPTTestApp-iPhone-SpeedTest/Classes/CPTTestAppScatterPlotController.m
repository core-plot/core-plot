//
//  CPTTestAppScatterPlotController.m
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CPTTestAppScatterPlotController.h"
#import "TestXYTheme.h"

#define USE_DOUBLEFASTPATH true
#define USE_ONEVALUEPATH   false

@interface CPTTestAppScatterPlotController()

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;

@property (nonatomic, readwrite, strong) NSData *xxx;
@property (nonatomic, readwrite, strong) NSData *yyy1;
@property (nonatomic, readwrite, strong) NSData *yyy2;

@end

#pragma mark -

@implementation CPTTestAppScatterPlotController

@synthesize graph;

@synthesize xxx;
@synthesize yyy1;
@synthesize yyy2;

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Create graph from a custom theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [[TestXYTheme alloc] init];
    [newGraph applyTheme:theme];
    self.graph = newGraph;

    newGraph.paddingLeft   = 10.0;
    newGraph.paddingTop    = 20.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 10.0;

    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = newGraph;

    newGraph.plotAreaFrame.masksToBorder = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(NUM_POINTS)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(NUM_POINTS)];

    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";

    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;

    boundLinePlot.dataSource = self;
    [newGraph addPlot:boundLinePlot];

    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";

    lineStyle                        = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];

    // Create plot data
    NSMutableData *xData  = [[NSMutableData alloc] initWithCapacity:NUM_POINTS * sizeof(double)];
    NSMutableData *y1Data = [[NSMutableData alloc] initWithCapacity:NUM_POINTS * sizeof(double)];
    NSMutableData *y2Data = [[NSMutableData alloc] initWithCapacity:NUM_POINTS * sizeof(double)];

    double *xArray  = xData.mutableBytes;
    double *y1Array = y1Data.mutableBytes;
    double *y2Array = y2Data.mutableBytes;

    for ( NSUInteger i = 0; i < NUM_POINTS; i++ ) {
        xArray[i]  = i;
        y1Array[i] = (NUM_POINTS / 3) * (arc4random() / (double)UINT32_MAX);
        y2Array[i] = (NUM_POINTS / 3) * (arc4random() / (double)UINT32_MAX) + NUM_POINTS / 3;
    }

    self.xxx  = xData;
    self.yyy1 = y1Data;
    self.yyy2 = y2Data;

#define PERFORMANCE_TEST1
#ifdef PERFORMANCE_TEST1
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif

#ifdef PERFORMANCE_TEST2
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadPlots) userInfo:nil repeats:YES];
#endif
}

-(void)reloadPlots
{
    NSArray *plots = [self.graph allPlots];

    for ( CPTPlot *plot in plots ) {
        [plot reloadData];
    }
}

-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    double ylen = NUM_POINTS * (arc4random() / (double)UINT32_MAX);

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(NUM_POINTS)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(ylen)];
}

#pragma mark -
#pragma mark Plot Data

-(const double *)valuesForPlotWithIdentifier:(id)identifier field:(NSUInteger)fieldEnum
{
    if ( fieldEnum == 0 ) {
        return (const double *)self.xxx.bytes;
    }
    else {
        if ( [identifier isEqualToString:@"Blue Plot"] ) {
            return (const double *)self.yyy1.bytes;
        }
        else {
            return (const double *)self.yyy2.bytes;
        }
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return NUM_POINTS;
}

#if USE_DOUBLEFASTPATH
#if USE_ONEVALUEPATH
-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)indx
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum];

    return values[indx];
}

#else
-(double *)doublesForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum];

    return values + indexRange.location;
}
#endif

#else
#if USE_ONEVALUEPATH
-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)indx
{
    NSNumber *num  = nil;
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum];

    if ( values ) {
        num = @(values[indx]);
    }
    return num;
}

#else
-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum];

    if ( values == NULL ) {
        return nil;
    }

    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:indexRange.length];
    for ( NSUInteger i = indexRange.location; i < indexRange.location + indexRange.length; i++ ) {
        [returnArray addObject:@(values[i])];
    }
    return returnArray;
}
#endif
#endif

@end
