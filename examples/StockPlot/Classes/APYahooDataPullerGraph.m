//
//  APYahooDataPullerGraph.m
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APYahooDataPullerGraph.h"

@interface APYahooDataPullerGraph()

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;

@end

#pragma mark -

@implementation APYahooDataPullerGraph

@synthesize graphHost;
@synthesize dataPuller;
@synthesize graph;

-(void)reloadData
{
    if ( !self.graph ) {
        CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
        [newGraph applyTheme:theme];
        self.graph = newGraph;

        newGraph.paddingTop    = 30.0;
        newGraph.paddingBottom = 30.0;
        newGraph.paddingLeft   = 50.0;
        newGraph.paddingRight  = 50.0;

        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
        dataSourceLinePlot.identifier = @"Data Source Plot";

        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.0;
        lineStyle.lineColor              = [CPTColor redColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;

        dataSourceLinePlot.dataSource = self;
        [newGraph addPlot:dataSourceLinePlot];
    }

    CPTXYGraph *theGraph = self.graph;
    self.graphHost.hostedGraph = theGraph;

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;

    NSDecimalNumber *high   = self.dataPuller.overallHigh;
    NSDecimalNumber *low    = self.dataPuller.overallLow;
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];

    //NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(self.dataPuller.financialData.count)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:low length:length];
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;

    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength   = @10.0;
    x.orthogonalPosition    = @0.0;
    x.minorTicksPerInterval = 1;

    CPTXYAxis *y  = axisSet.yAxis;
    NSDecimal six = CPTDecimalFromInteger(6);
    y.majorIntervalLength   = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalDivide(length.decimalValue, six)];
    y.majorTickLineStyle    = nil;
    y.minorTicksPerInterval = 4;
    y.minorTickLineStyle    = nil;
    y.orthogonalPosition    = @0.0;
    y.alternatingBandFills  = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];

    [theGraph reloadData];

    [[self navigationItem] setTitle:[self.dataPuller symbol]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //    NSLog(@"willRotateToInterfaceOrientation");
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //    NSLog(@"didRotateFromInterfaceOrientation");
}

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords
{
    return self.dataPuller.financialData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = @0;

    if ( fieldEnum == CPTScatterPlotFieldX ) {
        num = @(index + 1);
    }
    else if ( fieldEnum == CPTScatterPlotFieldY ) {
        NSArray *financialData = self.dataPuller.financialData;

        NSDictionary *fData = (NSDictionary *)financialData[[financialData count] - index - 1];
        num = fData[@"close"];
        NSAssert([num isMemberOfClass:[NSDecimalNumber class]], @"grrr");
    }

    return num;
}

-(void)dataPullerFinancialDataDidChange:(APYahooDataPuller *)dp
{
    [self reloadData];
}

#pragma mark accessors

-(void)setDataPuller:(APYahooDataPuller *)aDataPuller
{
    //NSLog(@"in -setDataPuller:, old value of dataPuller: %@, changed to: %@", dataPuller, aDataPuller);

    if ( dataPuller != aDataPuller ) {
        dataPuller = aDataPuller;
        [dataPuller setDelegate:self];
        [self reloadData];
    }
}

-(void)dealloc
{
    if ( dataPuller.delegate == self ) {
        [dataPuller setDelegate:nil];
    }
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self numberOfRecords];
}

@end
