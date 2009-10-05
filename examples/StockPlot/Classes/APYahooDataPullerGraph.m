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
    if(!graph)
    {
    	graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
        CPTheme *theme = [CPTheme themeNamed:@"Dark Gradients"];
        [graph applyTheme:theme];
        graph.paddingTop = 30.0;
        graph.paddingBottom = 30.0;
        graph.paddingLeft = 50.0;
        graph.paddingRight = 50.0;

        CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
        dataSourceLinePlot.identifier = @"Data Source Plot";
        dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
        dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
        dataSourceLinePlot.dataSource = self;
        [graph addPlot:dataSourceLinePlot];
    }
    
    if([[self.layerHost.layer sublayers] indexOfObject:graph] == NSNotFound)
        [self.layerHost.layer addSublayer:graph];
    
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    
    NSDecimalNumber *high = [dataPuller overallHigh];
    NSDecimalNumber *low = [dataPuller overallLow];
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
    
    //NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromInt([dataPuller.financialData count])];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
    // Axes
    CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    axisSet.xAxis.majorIntervalLength = CPDecimalFromString(@"10.0");
    axisSet.xAxis.constantCoordinateValue = [[NSDecimalNumber zero] decimalValue];
    axisSet.xAxis.minorTicksPerInterval = 1;
    
    NSDecimalNumber *four = [NSDecimalNumber decimalNumberWithString:@"4"];
    axisSet.yAxis.majorIntervalLength = CPDecimalDivide([length decimalValue], [four decimalValue]);
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.constantCoordinateValue = [[NSDecimalNumber zero] decimalValue];
    [graph reloadData];
    
    
    [[self navigationItem] setTitle:[dataPuller symbol]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    graph.frame = self.view.bounds;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || 
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    //    NSLog(@"willRotateToInterfaceOrientation");
    //[graph.axisSet relabelAxes];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation; 
{
    //    NSLog(@"didRotateFromInterfaceOrientation");
    [graph.axisSet relabelAxes];
}    

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return self.dataPuller.financialData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    if (fieldEnum == CPScatterPlotFieldX) 
    {
        num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
    }
    else if (fieldEnum == CPScatterPlotFieldY)
    {
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

@synthesize layerHost;

- (APYahooDataPuller *)dataPuller
{
    //NSLog(@"in -dataPuller, returned dataPuller = %@", dataPuller);
    
    return dataPuller; 
}
- (void)setDataPuller:(APYahooDataPuller *)aDataPuller
{
    //NSLog(@"in -setDataPuller:, old value of dataPuller: %@, changed to: %@", dataPuller, aDataPuller);
    
    if (dataPuller != aDataPuller) {
        [aDataPuller retain];
        [dataPuller release];
        dataPuller = aDataPuller;
        [dataPuller setDelegate:self];
        [self reloadData];
    }
}

- (void)dealloc {
    if(dataPuller.delegate == self)
        [dataPuller setDelegate:nil];
    [dataPuller release]; dataPuller = nil;
    [layerHost release]; layerHost = nil;
    [graph release]; graph = nil;
    
    [super dealloc];
}

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	return [self numberOfRecords];
}

@end
