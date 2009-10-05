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
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [graph applyTheme:theme];
	CPLayerHostingView *hostingView = (CPLayerHostingView *)self.view;
    hostingView.hostedLayer = graph;
	
    graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 10.0;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];

    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.constantCoordinateValue = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 2;
 	NSArray *exclusionRanges = [NSArray arrayWithObjects:
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(2.99) length:CPDecimalFromFloat(0.02)],
		nil];
	x.labelExclusionRanges = exclusionRanges;
   
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = CPDecimalFromString(@"2");
	exclusionRanges = [NSArray arrayWithObjects:
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
		[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(3.99) length:CPDecimalFromFloat(0.02)],
		nil];
	y.labelExclusionRanges = exclusionRanges;
  
	// Create a blue plot area
	CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Blue Plot";
	boundLinePlot.dataLineStyle.miterLimit = 1.0f;
	boundLinePlot.dataLineStyle.lineWidth = 3.0f;
	boundLinePlot.dataLineStyle.lineColor = [CPColor blueColor];
    boundLinePlot.dataSource = self;
	[graph addPlot:boundLinePlot];
	
	// Do a blue gradient
	CPColor *areaColor1 = [CPColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor clearColor]];
    areaGradient1.angle = -90.0f;
    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];    
 
	// Add plot symbols
	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPColor blackColor];
	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;

    // Create a green plot area
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Green Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

   // Put an area gradient under the plot above
    CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
    areaGradient.angle = -90.0f;
    areaGradientFill = [CPFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"1.75");
	
    // Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	NSUInteger i;
	for ( i = 0; i < 60; i++ ) {
		id x = [NSNumber numberWithFloat:1+i*0.05];
		id y = [NSNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.dataForPlot = contentArray;

#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
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

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    NSNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
	// Green plot gets shifted above the blue
	if ([(NSString *)plot.identifier isEqualToString:@"Green Plot"])
	{
		if ( fieldEnum == CPScatterPlotFieldY ) 
			num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
	}
    return num;
}

@end
