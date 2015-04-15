#import "CPTTestAppPieChartController.h"

@interface CPTTestAppPieChartController()

@property (nonatomic, readwrite, strong) CPTXYGraph *pieChart;
@property (nonatomic, readonly, assign) CGFloat pieMargin;
@property (nonatomic, readonly, assign) CGFloat pieRadius;
@property (nonatomic, readonly, assign) CGPoint pieCenter;

@end

#pragma mark -

@implementation CPTTestAppPieChartController

@synthesize dataForChart;
@synthesize pieChart;

-(CGFloat)pieMargin
{
    return self.pieChart.plotAreaFrame.borderLineStyle.lineWidth + CPTFloat(20.0);
}

-(CGFloat)pieRadius
{
    CGRect plotBounds = self.pieChart.plotAreaFrame.bounds;

    return MIN(plotBounds.size.width, plotBounds.size.height) / CPTFloat(2.0) - self.pieMargin;
}

-(CGPoint)pieCenter
{
    CGRect plotBounds = self.pieChart.plotAreaFrame.bounds;

    CGFloat y = 0.0;

    if ( plotBounds.size.width > plotBounds.size.height ) {
        y = 0.45;
    }
    else {
        y = (self.pieRadius + self.pieMargin) / plotBounds.size.height;
    }

    return CGPointMake(0.5, y);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CPTPieChart *piePlot = (CPTPieChart *)[self.pieChart plotWithIdentifier:@"Pie Chart 1"];

    piePlot.pieRadius    = self.pieRadius;
    piePlot.centerAnchor = self.pieCenter;
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
    piePlot.pieRadius      = 1.0;
    piePlot.identifier     = @"Pie Chart 1";
    piePlot.startAngle     = CPTFloat(M_PI_4);
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    [newGraph addPlot:piePlot];

    // Add some initial data
    self.dataForChart = @[@20.0, @30.0, @60.0];

    [newGraph layoutIfNeeded];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];

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
