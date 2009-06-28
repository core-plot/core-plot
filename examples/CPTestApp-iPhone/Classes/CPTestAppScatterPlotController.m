//
//  CPTestAppScatterPlotController.m
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CPTestAppScatterPlotController.h"


@implementation CPTestAppScatterPlotController

@synthesize dataForPlot;

#pragma mark -
#pragma mark Initialization and teardown

-(void)dealloc 
{
	[dataForPlot release];
    [super dealloc];
}

-(void)viewDidLoad 
{
    [super viewDidLoad];

    // Create graph from theme
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	graph = [theme newGraph];
	CPLayerHostingView *hostingView = (CPLayerHostingView *)self.view;
    hostingView.hostedLayer = graph;
    graph.paddingLeft = 20.0;
	graph.paddingTop = 20.0;
	graph.paddingRight = 20.0;
	graph.paddingBottom = 20.0;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];

    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    x.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];
    x.minorTicksPerInterval = 2;
    
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];

    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

	// Add plot symbols
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
	
    // Add some initial data
	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *x2 = [NSDecimalNumber decimalNumberWithString:@"1.7"];
	NSDecimalNumber *x3 = [NSDecimalNumber decimalNumberWithString:@"2.8"];
	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:@"2.3"];
	NSDecimalNumber *y3 = [NSDecimalNumber decimalNumberWithString:@"2"];
	
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
									[NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil],
									[NSMutableDictionary dictionaryWithObjectsAndKeys:x2, @"x", y2, @"y", nil],
									[NSMutableDictionary dictionaryWithObjectsAndKeys:x3, @"x", y3, @"y", nil],
									nil];
	self.dataForPlot = contentArray;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
}

-(void)changePlotRange 
{
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(3.0 + 2.0*rand()/RAND_MAX)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(3.0 + 2.0*rand()/RAND_MAX)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return [dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( fieldEnum == CPScatterPlotFieldY ) num = [num decimalNumberByAdding:[NSDecimalNumber one]];
    return num;
}

@end
