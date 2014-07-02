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

@implementation CPTTestAppScatterPlotController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Create graph from a custom theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [[TestXYTheme alloc] init];
    [graph applyTheme:theme];

    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = graph;

    graph.plotAreaFrame.masksToBorder = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];

    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";

    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;

    boundLinePlot.dataSource = self;
    [graph addPlot:boundLinePlot];

    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";

    lineStyle                        = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    for ( NSUInteger i = 0; i < NUM_POINTS; i++ ) {
        xxx[i]  = i;
        yyy1[i] = (NUM_POINTS / 3) * (rand() / (double)RAND_MAX);
        yyy2[i] = (NUM_POINTS / 3) * (rand() / (double)RAND_MAX) + NUM_POINTS / 3;
    }

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
    NSArray *plots = [graph allPlots];

    for ( CPTPlot *plot in plots ) {
        [plot reloadData];
    }
}

-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    float ylen                = NUM_POINTS * (rand() / (double)RAND_MAX);

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(ylen)];
}

#pragma mark -
#pragma mark Plot Data

-(double *)valuesForPlotWithIdentifier:(id)identifier field:(NSUInteger)fieldEnum
{
    if ( fieldEnum == 0 ) {
        return xxx;
    }
    else {
        if ( [identifier isEqualToString:@"Blue Plot"] ) {
            return yyy1;
        }
        else {
            return yyy2;
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
        NSNumber *number = [[NSNumber alloc] initWithDouble:values[i]];
        [returnArray addObject:number];
        [number release];
    }
    return returnArray;
}
#endif
#endif

@end
