//
//  CPTestAppPieChartController.m
//  CPTestApp-iPhone
//

#import "CPTestAppPieChartController.h"


@implementation CPTestAppPieChartController

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
	
    // Create pieChart from theme
    pieChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [pieChart applyTheme:theme];
	CPLayerHostingView *hostingView = (CPLayerHostingView *)self.view;
    hostingView.hostedLayer = pieChart;
    pieChart.plotArea.masksToBorder = NO;
	
    pieChart.paddingLeft = 20.0;
	pieChart.paddingTop = 20.0;
	pieChart.paddingRight = 20.0;
	pieChart.paddingBottom = 20.0;
    	
	// Add plot space for horizontal bar charts
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)pieChart.defaultPlotSpace;
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(16.0f)];
    
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)pieChart.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPDecimalFromString(@"5");
    x.constantCoordinateValue = CPDecimalFromString(@"-10");
	x.title = @"";
    x.titleLocation = CPDecimalFromFloat(7.5f);

	CPXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPDecimalFromString(@"50");
    y.constantCoordinateValue = CPDecimalFromString(@"-10");
	y.title = @"";
	y.titleOffset = 0.0f;
    y.titleLocation = CPDecimalFromFloat(150.0f);

    // First bar plot
    CPPieChart *piePlot = [[CPPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = 130.0f;
    piePlot.identifier = @"Pie Chart 1";
    [pieChart addPlot:piePlot toPlotSpace:plotSpace];
    
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:20.0f], [NSNumber numberWithDouble:30.0f], [NSNumber numberWithDouble:60.0f], nil];
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
    return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	if (index >= [self.dataForChart count])
		return nil;
	
	if (fieldEnum == CPBarPlotFieldBarLocation)
		return [NSNumber numberWithInt:index];
	else
		return [self.dataForChart objectAtIndex:index];
}

/*-(CPFill *)sliceFillForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index; 
{
	return nil;
}*/

@end
