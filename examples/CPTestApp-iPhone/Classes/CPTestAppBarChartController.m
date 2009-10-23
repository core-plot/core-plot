//
//  CPTestAppBarChartController.m
//  CPTestApp-iPhone
//

#import "CPTestAppBarChartController.h"


@implementation CPTestAppBarChartController

@synthesize dataForChart;

#pragma mark -
#pragma mark Initialization and teardown

-(void)dealloc 
{
	[dataForChart release];
    [super dealloc];
}

- (void)viewDidLoad 
{
	NSLog(@"Loading view");
	[super viewDidLoad];
	
    // Create barChart from theme
    barChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [barChart applyTheme:theme];
	CPLayerHostingView *hostingView = (CPLayerHostingView *)self.view;
    hostingView.hostedLayer = barChart;
	
    barChart.paddingLeft = 10.0;
	barChart.paddingTop = 10.0;
	barChart.paddingRight = 10.0;
	barChart.paddingBottom = 10.0;
    
	barChart.plotArea.plotGroup.paddingLeft = 70.0;
	barChart.plotArea.plotGroup.paddingTop = 10.0;
	barChart.plotArea.plotGroup.paddingBottom = 55.0;
	barChart.plotArea.plotGroup.paddingRight = 10.0;
	barChart.plotArea.axisSet.paddingLeft = 70.0;
	barChart.plotArea.axisSet.paddingTop = 10.0;
	barChart.plotArea.axisSet.paddingBottom = 55.0;
	barChart.plotArea.axisSet.paddingRight = 10.0;
	
	// Add plot space for horizontal bar charts
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(16.0f)];
    
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)barChart.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"5");
    x.constantCoordinateValue = CPDecimalFromString(@"0");
    x.minorTicksPerInterval = 2;
	x.title = @"X Axis";

	CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"50");
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = CPDecimalFromString(@"0");
	y.title = @"Y Axis";
	y.axisTitleOffset = 45.0f;

    // First bar plot
    CPBarPlot *barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor darkGrayColor] horizontalBars:NO];
    barPlot.baseValue = CPDecimalFromString(@"0");
    barPlot.dataSource = self;
    barPlot.barOffset = -0.25f;
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // Second bar plot
    barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor blueColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.baseValue = CPDecimalFromString(@"0");
    barPlot.barOffset = 0.25f;
    barPlot.cornerRadius = 2.0f;
    barPlot.identifier = @"Bar Plot 2";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
	
	
//    // Setup plot space
//    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)barChart.defaultPlotSpace;
//    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
//    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
//	
//    // Axes
//	CPXYAxisSet *axisSet = (CPXYAxisSet *)barChart.axisSet;
//    CPXYAxis *x = axisSet.xAxis;
//    x.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
//    x.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];
//    x.minorTicksPerInterval = 2;
// 	NSArray *exclusionRanges = [NSArray arrayWithObjects:
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(2.99) length:CPDecimalFromFloat(0.02)],
//								nil];
//	x.labelExclusionRanges = exclusionRanges;
//	
//    CPXYAxis *y = axisSet.yAxis;
//    y.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
//    y.minorTicksPerInterval = 5;
//    y.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];
//	exclusionRanges = [NSArray arrayWithObjects:
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(3.99) length:CPDecimalFromFloat(0.02)],
//					   nil];
//	y.labelExclusionRanges = exclusionRanges;
//	
//	// Create a blue plot area
//	CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
//    boundLinePlot.identifier = @"Blue Plot";
//	boundLinePlot.dataLineStyle.miterLimit = 1.0f;
//	boundLinePlot.dataLineStyle.lineWidth = 3.0f;
//	boundLinePlot.dataLineStyle.lineColor = [CPColor blueColor];
//    boundLinePlot.dataSource = self;
//	[barChart addPlot:boundLinePlot];
//	
//	// Do a blue gradient
//	CPColor *areaColor1 = [CPColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
//    CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor clearColor]];
//    areaGradient1.angle = -90.0f;
//    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
//    boundLinePlot.areaFill = areaGradientFill;
//    boundLinePlot.areaBaseValue = [NSDecimalNumber zero];    
//	
//	// Add plot symbols
//	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
//	symbolLineStyle.lineColor = [CPColor blackColor];
//	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
//	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
//	plotSymbol.lineStyle = symbolLineStyle;
//    plotSymbol.size = CGSizeMake(10.0, 10.0);
//    boundLinePlot.plotSymbol = plotSymbol;
//	
//    // Create a green plot area
//	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
//    dataSourceLinePlot.identifier = @"Green Plot";
//	dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
//    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
//    dataSourceLinePlot.dataSource = self;
//    [barChart addPlot:dataSourceLinePlot];
//	
//	// Put an area gradient under the plot above
//    CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
//    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
//    areaGradient.angle = -90.0f;
//    areaGradientFill = [CPFill fillWithGradient:areaGradient];
//    dataSourceLinePlot.areaFill = areaGradientFill;
//    dataSourceLinePlot.areaBaseValue = [NSDecimalNumber decimalNumberWithString:@"1.75"];    
	
    // Add some initial data
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	NSUInteger i;
	for ( i = 0; i < 60; i++ ) {
		id x = [NSNumber numberWithFloat:1+i*0.05];
		id y = [NSNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.dataForChart = contentArray;
	
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return 16;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    NSDecimalNumber *num = [[dataForChart objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( [plot isKindOfClass:[CPBarPlot class]] ) {
        num = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:(index+1)*(index+1)];
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) 
            num = [num decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
    }
	else
	{
	// Green plot gets shifted above the blue
	if ([(NSString *)plot.identifier isEqualToString:@"Bar Plot 1"])
	{
		if ( fieldEnum == CPScatterPlotFieldY ) 
			num = [num decimalNumberByAdding:[NSDecimalNumber one]];
	}
	}
	
    return num;
}

-(CPFill *) barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSNumber *)index; 
{
	return nil;
}

@end
