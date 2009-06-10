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

- (void)dealloc 
{
	[dataForPlot release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    // Create graph
    graph = [[CPXYGraph alloc] initWithFrame:self.view.bounds];

    // Background
	graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];

    // Plot area background
    CPGradient *gradient = [CPGradient aquaSelectedGradient];
    gradient.angle = 90.0;
	graph.plotArea.fill = [CPFill fillWithGradient:gradient]; 
	
    // Host graph layer
	graph.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerMinXMargin | kCPLayerMaxXMargin | kCPLayerHeightSizable | kCPLayerMinYMargin | kCPLayerMaxYMargin;
	[(CPLayerHostingView *)self.view setHostedLayer:graph];
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];

    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [[CPColor blueColor] colorWithAlphaComponent:0.4];
    majorLineStyle.lineWidth = 2.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [[CPColor redColor] colorWithAlphaComponent:0.4];
    minorLineStyle.lineWidth = 2.0f;
	
    axisSet.xAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.2"];
    axisSet.xAxis.constantCoordinateValue = [NSDecimalNumber one];
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.majorTickLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLineStyle = minorLineStyle;
    axisSet.xAxis.axisLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.axisLabelOffset = 18.f;

    axisSet.yAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
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
	
	
	
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return [dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( fieldEnum == CPScatterPlotFieldY ) num = [num decimalNumberByAdding:[NSDecimalNumber one]];
    return num;
}

@end
