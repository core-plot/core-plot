//
//  APYahooDataPullerGraph.m
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APYahooDataPullerGraph.h"

@implementation APYahooDataPullerGraph

-(void)reloadData
{
    if ( !graph ) {
        graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
        [graph applyTheme:theme];
        graph.paddingTop    = 30.0;
        graph.paddingBottom = 30.0;
        graph.paddingLeft   = 50.0;
        graph.paddingRight  = 50.0;

        CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
        dataSourceLinePlot.identifier = @"Data Source Plot";

        CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
        lineStyle.lineWidth              = 1.f;
        lineStyle.lineColor              = [CPTColor redColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;

        dataSourceLinePlot.dataSource = self;
        [graph addPlot:dataSourceLinePlot];
    }

    self.graphHost.hostedGraph = graph;

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    NSDecimalNumber *high   = [dataPuller overallHigh];
    NSDecimalNumber *low    = [dataPuller overallLow];
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];

    //NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromUnsignedInteger([dataPuller.financialData count])];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(10.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    x.minorTicksPerInterval       = 1;

    CPTXYAxis *y  = axisSet.yAxis;
    NSDecimal six = CPTDecimalFromInteger(6);
    y.majorIntervalLength         = CPTDecimalDivide([length decimalValue], six);
    y.majorTickLineStyle          = nil;
    y.minorTicksPerInterval       = 4;
    y.minorTickLineStyle          = nil;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    y.alternatingBandFills        = [NSArray arrayWithObjects:[[CPTColor whiteColor] colorWithAlphaComponent:0.1], [NSNull null], nil];

    [graph reloadData];

    [[self navigationItem] setTitle:[dataPuller symbol]];
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

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    //    NSLog(@"willRotateToInterfaceOrientation");
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    //    NSLog(@"didRotateFromInterfaceOrientation");
}

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords
{
    return self.dataPuller.financialData.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [NSDecimalNumber zero];

    if ( fieldEnum == CPTScatterPlotFieldX ) {
        num = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:index + 1];
    }
    else if ( fieldEnum == CPTScatterPlotFieldY ) {
        NSArray *financialData = self.dataPuller.financialData;

        NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
        num = [fData objectForKey:@"close"];
        NSAssert([num isMemberOfClass:[NSDecimalNumber class]], @"grrr");
    }
    return num;
}

-(void)dataPullerFinancialDataDidChange:(APYahooDataPuller *)dp;
{
    [self reloadData];
}

#pragma mark accessors

@synthesize graphHost;

-(APYahooDataPuller *)dataPuller
{
    //NSLog(@"in -dataPuller, returned dataPuller = %@", dataPuller);

    return dataPuller;
}

-(void)setDataPuller:(APYahooDataPuller *)aDataPuller
{
    //NSLog(@"in -setDataPuller:, old value of dataPuller: %@, changed to: %@", dataPuller, aDataPuller);

    if ( dataPuller != aDataPuller ) {
        [aDataPuller retain];
        [dataPuller release];
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
    [dataPuller release];
    dataPuller = nil;
    [graphHost release];
    graphHost = nil;
    [graph release];
    graph = nil;

    [super dealloc];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self numberOfRecords];
}

@end
