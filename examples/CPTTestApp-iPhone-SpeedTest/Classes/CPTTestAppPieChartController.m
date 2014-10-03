#import "CPTTestAppPieChartController.h"

@interface CPTTestAppPieChartController()

@property (nonatomic, readwrite, strong) CPTXYGraph *pieChart;

@end

#pragma mark -

@implementation CPTTestAppPieChartController

@synthesize dataForChart;
@synthesize pieChart;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CPTPlot *piePlot  = [self.pieChart plotWithIdentifier:@"Pie Chart 1"];
    CGRect plotBounds = self.pieChart.plotAreaFrame.bounds;

    ( (CPTPieChart *)piePlot ).pieRadius = MIN(plotBounds.size.width, plotBounds.size.height) / CPTFloat(2.0) - CPTFloat(10.0);
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Create pieChart from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.pieChart = newGraph;

    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = newGraph;

    newGraph.paddingLeft   = 20.0;
    newGraph.paddingTop    = 20.0;
    newGraph.paddingRight  = 20.0;
    newGraph.paddingBottom = 20.0;

    newGraph.plotAreaFrame.masksToBorder = NO;

    newGraph.axisSet = nil;

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource     = self;
    piePlot.pieRadius      = 130.0;
    piePlot.identifier     = @"Pie Chart 1";
    piePlot.startAngle     = CPTFloat(M_PI_4);
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    [newGraph addPlot:piePlot];

    // Add some initial data
    self.dataForChart = @[@20.0, @30.0, @60.0];

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
    return self.dataForChart.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( index >= self.dataForChart.count ) {
        return nil;
    }

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        return (self.dataForChart)[index];
    }
    else {
        return @(index);
    }
}

@end
