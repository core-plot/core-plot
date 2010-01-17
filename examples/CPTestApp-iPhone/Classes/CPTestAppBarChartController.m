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
	[super viewDidLoad];
	
    // Create barChart from theme
    barChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [barChart applyTheme:theme];
	CPLayerHostingView *hostingView = (CPLayerHostingView *)self.view;
    hostingView.hostedLayer = barChart;
    barChart.plotArea.masksToBorder = NO;
	
    barChart.paddingLeft = 70.0;
	barChart.paddingTop = 20.0;
	barChart.paddingRight = 20.0;
	barChart.paddingBottom = 80.0;
	
	// Add plot space for horizontal bar charts
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(16.0f)];
    
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)barChart.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPDecimalFromString(@"5");
    x.constantCoordinateValue = CPDecimalFromString(@"0");
	x.title = @"X Axis";
    x.titleLocation = CPDecimalFromFloat(7.5f);
	x.titleOffset = 55.0f;

	// Define some custom labels for the data elements
	x.labelRotation = M_PI/4;
	x.labelingPolicy = CPAxisLabelingPolicyNone;
	NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:5], [NSDecimalNumber numberWithInt:10], [NSDecimalNumber numberWithInt:15], nil];
	NSArray *xAxisLabels = [NSArray arrayWithObjects:@"Label A", @"Label B", @"Label C", @"Label D", @"Label E", nil];
	NSUInteger labelLocation = 0;
	NSMutableArray *customLabels = [[NSMutableArray alloc] initWithCapacity:[xAxisLabels count]];
	for (NSNumber *tickLocation in customTickLocations)
	{
		CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = x.labelOffset + x.majorTickLength;
		newLabel.rotation = M_PI/4;
		[customLabels addObject:newLabel];
		[newLabel release];
	}
	
	x.axisLabels =  [NSSet setWithArray:customLabels];
	
	
	CPXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPDecimalFromString(@"50");
    y.constantCoordinateValue = CPDecimalFromString(@"0");
	y.title = @"Y Axis";
	y.titleOffset = 45.0f;
    y.titleLocation = CPDecimalFromFloat(150.0f);

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
