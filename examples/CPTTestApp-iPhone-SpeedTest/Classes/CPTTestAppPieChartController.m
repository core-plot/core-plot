#import "CPTTestAppPieChartController.h"

@implementation CPTTestAppPieChartController

@synthesize dataForChart;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CPTPlot *piePlot  = [pieChart plotWithIdentifier:@"Pie Chart 1"];
	CGRect plotBounds = pieChart.plotAreaFrame.bounds;

	( (CPTPieChart *)piePlot ).pieRadius = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - 10.0;
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)dealloc
{
	[dataForChart release];
	[super dealloc];
}

-(void)viewDidLoad
{
	[super viewDidLoad];

	// Create pieChart from theme
	pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[pieChart applyTheme:theme];
	CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
	hostingView.hostedGraph = pieChart;

	pieChart.paddingLeft   = 20.0;
	pieChart.paddingTop	   = 20.0;
	pieChart.paddingRight  = 20.0;
	pieChart.paddingBottom = 20.0;

	pieChart.axisSet = nil;

	// Add pie chart
	CPTPieChart *piePlot = [[CPTPieChart alloc] init];
	piePlot.dataSource	   = self;
	piePlot.pieRadius	   = 130.0;
	piePlot.identifier	   = @"Pie Chart 1";
	piePlot.startAngle	   = M_PI_4;
	piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
	[pieChart addPlot:piePlot];
	[piePlot release];

	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:20.0], [NSNumber numberWithDouble:30.0], [NSNumber numberWithDouble:60.0], nil];
	self.dataForChart = contentArray;

#ifdef PERFORMANCE_TEST
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	if ( index >= [self.dataForChart count] ) {
		return nil;
	}

	if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
		return [self.dataForChart objectAtIndex:index];
	}
	else {
		return [NSNumber numberWithInt:index];
	}
}

/*-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index;
 * {
 *  return nil;
 * }*/

@end
