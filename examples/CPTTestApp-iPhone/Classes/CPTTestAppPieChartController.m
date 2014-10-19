#import "CPTTestAppPieChartController.h"

@interface CPTTestAppPieChartController()

@property (nonatomic, readwrite, strong) CPTXYGraph *pieChart;

@end

#pragma mark -

@implementation CPTTestAppPieChartController

@synthesize dataForChart;
@synthesize timer;
@synthesize pieChart;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat margin = self.pieChart.plotAreaFrame.borderLineStyle.lineWidth + CPTFloat(5.0);

    CPTPieChart *piePlot = (CPTPieChart *)[self.pieChart plotWithIdentifier:@"Pie Chart 1"];
    CGRect plotBounds    = self.pieChart.plotAreaFrame.bounds;
    CGFloat newRadius    = MIN(plotBounds.size.width, plotBounds.size.height) / CPTFloat(2.0) - margin;

    CGFloat y = 0.0;

    if ( plotBounds.size.width > plotBounds.size.height ) {
        y = 0.5;
    }
    else {
        y = (newRadius + margin) / plotBounds.size.height;
    }
    CGPoint newAnchor = CGPointMake(0.5, y);

    // Animate the change
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"pieRadius"];
        animation.toValue  = @(newRadius);
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [piePlot addAnimation:animation forKey:@"pieRadius"];

        animation          = [CABasicAnimation animationWithKeyPath:@"centerAnchor"];
        animation.toValue  = [NSValue valueWithBytes:&newAnchor objCType:@encode(CGPoint)];
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [piePlot addAnimation:animation forKey:@"centerAnchor"];
    }
    [CATransaction commit];
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Add some initial data
    self.dataForChart = @[@20.0, @30.0, @60.0];

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

    newGraph.axisSet = nil;

    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor whiteColor];

    newGraph.titleTextStyle = whiteText;
    newGraph.title          = @"Graph Title";

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = 131.0;
    piePlot.identifier      = @"Pie Chart 1";
    piePlot.startAngle      = CPTFloat(M_PI_4);
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.centerAnchor    = CPTPointMake(0.5, 0.38);
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    piePlot.delegate        = self;
    [newGraph addPlot:piePlot];

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

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( index >= [self.dataForChart count] ) {
        return nil;
    }

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        return (self.dataForChart)[index];
    }
    else {
        return @(index);
    }
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label            = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];

    textStyle.color = [CPTColor lightGrayColor];
    label.textStyle = textStyle;
    return label;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)piePlot recordIndex:(NSUInteger)index
{
    CGFloat offset = 0.0;

    if ( index == 0 ) {
        offset = piePlot.pieRadius / CPTFloat(8.0);
    }

    return offset;
}

#pragma mark -
#pragma mark Delegate Methods

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    self.pieChart.title = [NSString stringWithFormat:@"Selected index: %lu", (unsigned long)index];
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    CPTPieChart *piePlot             = (CPTPieChart *)[self.pieChart plotWithIdentifier:@"Pie Chart 1"];
    CABasicAnimation *basicAnimation = (CABasicAnimation *)theAnimation;

    [piePlot removeAnimationForKey:basicAnimation.keyPath];
    [piePlot setValue:basicAnimation.toValue forKey:basicAnimation.keyPath];
    [piePlot repositionAllLabelAnnotations];
}

@end
