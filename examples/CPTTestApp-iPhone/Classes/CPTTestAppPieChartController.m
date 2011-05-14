#import "CPTTestAppPieChartController.h"

@implementation CPTTestAppPieChartController

@synthesize dataForChart;
@synthesize timer;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CGFloat margin = pieChart.plotAreaFrame.borderLineStyle.lineWidth + 5.0;
	
	CPTPlot *piePlot = [pieChart plotWithIdentifier:@"Pie Chart 1"];
	CGRect plotBounds = pieChart.plotAreaFrame.bounds;
	CGFloat newRadius = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - margin;
	((CPTPieChart *)piePlot).pieRadius = newRadius;
	
	CGFloat y = 0.0;
	
	if ( plotBounds.size.width > plotBounds.size.height ) {
		y = 0.5; 
	}
	else {
		y = (newRadius + margin) / plotBounds.size.height;
	}
	((CPTPieChart *)piePlot).centerAnchor = CGPointMake(0.5, y);
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
    pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [pieChart applyTheme:theme];
	CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = pieChart;
	
    pieChart.paddingLeft = 20.0;
	pieChart.paddingTop = 20.0;
	pieChart.paddingRight = 20.0;
	pieChart.paddingBottom = 20.0;
	
	pieChart.axisSet = nil;
	
	pieChart.titleTextStyle.color = [CPTColor whiteColor];
	pieChart.title = @"Graph Title";
	
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
	piePlot.pieRadius = 131.0;
    piePlot.identifier = @"Pie Chart 1";
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
	piePlot.centerAnchor = CGPointMake(0.5, 0.38);
	piePlot.borderLineStyle = [CPTLineStyle lineStyle];
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

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	if ( index >= [self.dataForChart count] ) return nil;
	
	if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
		return [self.dataForChart objectAtIndex:index];
	}
	else {
		return [NSNumber numberWithInt:index];
	}
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index 
{
	CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", index]];
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
	textStyle.color = [CPTColor lightGrayColor];
    label.textStyle = textStyle;
    [textStyle release];
	return [label autorelease];
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return ( index == 0 ? 30.0f : 0.0f );
}

/*-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index; 
{
	return nil;
}*/

#pragma mark -
#pragma mark Delegate Methods

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
	pieChart.title = [NSString stringWithFormat:@"Selected index: %lu", index];
}

@end
