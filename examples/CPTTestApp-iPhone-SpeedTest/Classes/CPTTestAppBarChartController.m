//
//  CPTTestAppBarChartController.m
//  CPTTestApp-iPhone
//

#import "CPTTestAppBarChartController.h"

@interface CPTTestAppBarChartController()

@property (nonatomic, readwrite, strong) CPTXYGraph *barChart;

@end

#pragma mark -

@implementation CPTTestAppBarChartController

@synthesize barChart;

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Create barChart from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    self.barChart = newGraph;

    hostingView.hostedGraph              = newGraph;
    newGraph.plotAreaFrame.masksToBorder = NO;

    newGraph.paddingLeft   = 70.0;
    newGraph.paddingTop    = 55.0;
    newGraph.paddingRight  = 20.0;
    newGraph.paddingBottom = 80.0;

    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(300.0)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(16.0)];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromDouble(5.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.title                       = @"X Axis";
    x.titleLocation               = CPTDecimalFromFloat(7.5f);
    x.titleOffset                 = 55.0;

    // Define some custom labels for the data elements
    x.labelRotation  = CPTFloat(M_PI_4);
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = @[@1, @5, @10, @15];
    NSArray *xAxisLabels         = @[@"Label A", @"Label B", @"Label C", @"Label D"];
    NSUInteger labelLocation     = 0;
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabel];
    }

    x.axisLabels = customLabels;

    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.title                       = @"Y Axis";
    y.titleOffset                 = 45.0;
    y.titleLocation               = CPTDecimalFromFloat(150.0f);

    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor darkGrayColor] horizontalBars:NO];
    barPlot.baseValue  = CPTDecimalFromDouble(0.0);
    barPlot.dataSource = self;
    barPlot.barOffset  = CPTDecimalFromFloat(-0.25f);
    barPlot.identifier = @"Bar Plot 1";
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];

    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = CPTDecimalFromDouble(0.0);
    barPlot.barOffset       = CPTDecimalFromFloat(0.25f);
    barPlot.barCornerRadius = 2.0;
    barPlot.identifier      = @"Bar Plot 2";
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];

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
    return 16;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = @(index);
                break;

            case CPTBarPlotFieldBarTip:
                num = @( (index + 1) * (index + 1) );
                if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
                    num = @(num.integerValue - 10);
                }
                break;
        }
    }

    return num;
}

@end
