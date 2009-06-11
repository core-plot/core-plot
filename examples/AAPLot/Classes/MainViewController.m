//
//  MainViewController.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import "MainViewController.h"
#import "CPYahooDataPuller.h"

@interface MainViewController()

@property(nonatomic, retain)CPXYGraph *graph;
@property(nonatomic, retain)CPYahooDataPuller *datapuller;

@end


@implementation MainViewController

@synthesize graph;
@synthesize datapuller;
@synthesize layerHost;

- (void)dealloc
{
    [datapuller release];
    [graph release];
    [layerHost release];
    
    datapuller = nil;
    graph = nil;
    layerHost = nil;
    
    [super dealloc];
}

- (void)setView:(UIView *)aView;
{
    [super setView:aView];
    if (nil == aView)
    {
        self.graph = nil;
        self.layerHost = nil;
    }
}

- (void)viewDidLoad 
{    // Create graph
    CPXYGraph *aGraph = [[CPXYGraph alloc] initWithFrame:self.view.bounds];
    self.graph = aGraph;
    
    [aGraph release];
    [super viewDidLoad];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CPYahooDataPuller *dp = [[CPYahooDataPuller alloc] init];
        [dp setDelegate:self];
        [self setDatapuller:dp];
        [dp release];
    }
    return self;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    //NSLog(@"-(NSUInteger)numberOfRecords {");
    return self.datapuller.financialData.count;;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    //NSLog(@"-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {");
    NSDecimalNumber *num = [NSDecimalNumber zero];
    if (fieldEnum == CPScatterPlotFieldX) 
    {
        num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
    }
    else if (fieldEnum == CPScatterPlotFieldY)
    {
        NSArray *financialData = self.datapuller.financialData;
        
        CPFinancialData *fData = (CPFinancialData *)[financialData objectAtIndex:[financialData count] - index - 1];
        num = [fData close];
    }
    NSLog(@"%@", num);
    return num;
}


-(void)dataPullerDidFinishFetch:(CPYahooDataPuller *)dp;
{
    NSLog(@"Fetch is done!");
    
    // Background
	graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];
    
    // Plot area background
    CPGradient *gradient = [CPGradient aquaSelectedGradient];
    gradient.angle = 90.0;
	graph.plotArea.fill = [CPFill fillWithGradient:gradient]; 
	
    // Host graph layer
	graph.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerMinXMargin | kCPLayerMaxXMargin | kCPLayerHeightSizable | kCPLayerMinYMargin | kCPLayerMaxYMargin;
	[(CPLayerHostingView *)self.layerHost setHostedLayer:graph];
    [self.layerHost setNeedsDisplay];
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    //NSDecimalNumber *high = [datapuller overallHigh];
    //NSDecimalNumber *low = [datapuller overallLow];
    //NSDecimalNumber *high = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:200];
    //NSDecimalNumber *low = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:100];
    //NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromInt([datapuller.financialData count])];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(120.0) length:CPDecimalFromFloat(30.0)];
    //plotSpace.yRange = [CPPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [[CPColor blueColor] colorWithAlphaComponent:0.4];
    majorLineStyle.lineWidth = 2.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [[CPColor redColor] colorWithAlphaComponent:0.4];
    minorLineStyle.lineWidth = 2.0f;
	
    axisSet.xAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    axisSet.xAxis.constantCoordinateValue = [NSDecimalNumber one];
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.majorTickLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLineStyle = minorLineStyle;
    axisSet.xAxis.axisLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.axisLabelOffset = 18.f;
    
    axisSet.yAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"50.0"];
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.constantCoordinateValue = [NSDecimalNumber one];
    axisSet.yAxis.majorTickLineStyle = majorLineStyle;
    axisSet.yAxis.minorTickLineStyle = minorLineStyle;
    axisSet.yAxis.axisLineStyle = majorLineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.axisLabelOffset = 18.f;
	
    // Create a second plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
	// Add plot symbols
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol plusPlotSymbol];
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    dataSourceLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
    [dataSourceLinePlot reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (CPYahooDataPuller *)datapuller
{
    //NSLog(@"in -datapuller, returned datapuller = %@", datapuller);
    
    return datapuller; 
}
- (void)setDatapuller:(CPYahooDataPuller *)aDatapuller
{
    //NSLog(@"in -setDatapuller:, old value of datapuller: %@, changed to: %@", datapuller, aDatapuller);
    
    if (datapuller != aDatapuller)
    {
        [aDatapuller retain];
        [datapuller release];
        datapuller = aDatapuller;
    }
}

@end


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

