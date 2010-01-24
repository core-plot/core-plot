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
    	
	pieChart.axisSet = nil;
	
    // Add pie chart
    CPPieChart *piePlot = [[CPPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = 130.0;
    piePlot.identifier = @"Pie Chart 1";
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPPieDirectionCounterClockwise;
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

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	if ( index >= [self.dataForChart count] ) return nil;
	
	if ( fieldEnum == CPPieChartFieldSliceWidth ) {
		return [self.dataForChart objectAtIndex:index];
	}
	else {
		return [NSNumber numberWithInt:index];
	}
}

/*-(CPFill *)sliceFillForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index; 
{
	return nil;
}*/

@end
