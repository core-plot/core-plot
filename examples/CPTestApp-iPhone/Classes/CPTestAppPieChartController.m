#import "CPTestAppPieChartController.h"

@implementation CPTestAppPieChartController

@synthesize dataForChart;
@synthesize timer;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CGFloat margin = pieChart.plotAreaFrame.borderLineStyle.lineWidth + 5.0;
	
	CPPlot *piePlot = [pieChart plotWithIdentifier:@"Pie Chart 1"];
	CGRect plotBounds = pieChart.plotAreaFrame.bounds;
	CGFloat newRadius = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - margin;
	((CPPieChart *)piePlot).pieRadius = newRadius;
	
	CGFloat y = 0.0;
	
	if ( plotBounds.size.width > plotBounds.size.height ) {
		y = 0.5; 
	}
	else {
		y = (newRadius + margin) / plotBounds.size.height;
	}
	((CPPieChart *)piePlot).centerAnchor = CGPointMake(0.5, y);
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)dealloc 
{
	[dataForChart release];
	[timer release];
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated
{
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:20.0], [NSNumber numberWithDouble:30.0], [NSNumber numberWithDouble:60.0], nil];
	self.dataForChart = contentArray;

	[self timerFired];
#ifdef MEMORY_TEST
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
												selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif
}

-(void)timerFired
{
#ifdef MEMORY_TEST
	static NSUInteger counter = 0;
	
	NSLog(@"\n----------------------------\ntimerFired: %lu", counter++);
#endif
	
	[pieChart release];
	
    // Create pieChart from theme
    pieChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [pieChart applyTheme:theme];
	CPGraphHostingView *hostingView = (CPGraphHostingView *)self.view;
    hostingView.hostedGraph = pieChart;
	
    pieChart.paddingLeft = 20.0;
	pieChart.paddingTop = 20.0;
	pieChart.paddingRight = 20.0;
	pieChart.paddingBottom = 20.0;
	
	pieChart.axisSet = nil;
	
	pieChart.titleTextStyle.color = [CPColor whiteColor];
	pieChart.title = @"Graph Title";
	
    // Add pie chart
    CPPieChart *piePlot = [[CPPieChart alloc] init];
    piePlot.dataSource = self;
	piePlot.pieRadius = 131.0;
    piePlot.identifier = @"Pie Chart 1";
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPPieDirectionCounterClockwise;
	piePlot.centerAnchor = CGPointMake(0.5, 0.38);
	piePlot.borderLineStyle = [CPLineStyle lineStyle];
	piePlot.delegate = self;
    [pieChart addPlot:piePlot];
    [piePlot release];
	
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

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index 
{
	CPTextLayer *label = [[CPTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", index]];
    CPMutableTextStyle *textStyle = [label.textStyle mutableCopy];
	textStyle.color = [CPColor lightGrayColor];
    label.textStyle = textStyle;
    [textStyle release];
	return [label autorelease];
}

-(CGFloat)radialOffsetForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return ( index == 0 ? 30.0f : 0.0f );
}

/*-(CPFill *)sliceFillForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index; 
{
	return nil;
}*/

#pragma mark -
#pragma mark Delegate Methods

-(void)pieChart:(CPPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
	pieChart.title = [NSString stringWithFormat:@"Selected index: %lu", index];
}

@end
