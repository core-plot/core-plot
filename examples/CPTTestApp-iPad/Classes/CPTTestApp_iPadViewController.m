//
//  CPTTestApp_iPadViewController.m
//  CPTTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import "CPTTestApp_iPadViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CPTTestApp_iPadViewController()

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *scatterPlotView;
@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *barChartView;
@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *pieChartView;

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) CPTXYGraph *barChart;
@property (nonatomic, readwrite, strong) CPTXYGraph *pieGraph;

@property (nonatomic, readwrite, strong) CPTPieChart *piePlot;
@property (nonatomic, readwrite, assign) BOOL piePlotIsRotating;

@end

#pragma mark -

@implementation CPTTestApp_iPadViewController

@synthesize dataForChart;
@synthesize dataForPlot;

@synthesize scatterPlotView;
@synthesize barChartView;
@synthesize pieChartView;

@synthesize graph;
@synthesize barChart;
@synthesize pieGraph;

@synthesize piePlot;
@synthesize piePlotIsRotating;

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self constructScatterPlot];
    [self constructBarChart];
    [self constructPieChart];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Add a rotation animation
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.removedOnCompletion = YES;
    rotation.fromValue           = @(M_PI * 5);
    rotation.toValue             = @0.0;
    rotation.duration            = 1.0;
    rotation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotation.delegate            = self;
    [self.piePlot addAnimation:rotation forKey:@"rotation"];

    self.piePlotIsRotating = YES;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    self.piePlotIsRotating = NO;
    [self.piePlot performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ) {
        // Move the plots into place for portrait
        self.scatterPlotView.frame = CGRectMake(20.0, 55.0, 728.0, 556.0);
        self.barChartView.frame    = CGRectMake(20.0, 644.0, 340.0, 340.0);
        self.pieChartView.frame    = CGRectMake(408.0, 644.0, 340.0, 340.0);
    }
    else {
        // Move the plots into place for landscape
        self.scatterPlotView.frame = CGRectMake(20.0, 51.0, 628.0, 677.0);
        self.barChartView.frame    = CGRectMake(684.0, 51.0, 320.0, 320.0);
        self.pieChartView.frame    = CGRectMake(684.0, 408.0, 320.0, 320.0);
    }
}

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Plot construction methods

-(void)constructScatterPlot
{
    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];
    self.scatterPlotView.hostedGraph = newGraph;
    self.graph                       = newGraph;

    newGraph.paddingLeft   = 10.0;
    newGraph.paddingTop    = 10.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 10.0;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:@1.0 length:@2.0];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:@1.0 length:@3.0];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @0.5;
    x.orthogonalPosition    = @2.0;
    x.minorTicksPerInterval = 2;
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:@1.99 length:@0.02],
                                 [CPTPlotRange plotRangeWithLocation:@0.99 length:@0.02],
                                 [CPTPlotRange plotRangeWithLocation:@2.99 length:@0.02]];
    x.labelExclusionRanges = exclusionRanges;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @0.5;
    y.minorTicksPerInterval = 5;
    y.orthogonalPosition    = @2.0;
    exclusionRanges         = @[[CPTPlotRange plotRangeWithLocation:@1.99 length:@0.02],
                                [CPTPlotRange plotRangeWithLocation:@0.99 length:@0.02],
                                [CPTPlotRange plotRangeWithLocation:@3.99 length:@0.02]];
    y.labelExclusionRanges = exclusionRanges;

    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    lineStyle.dashPattern            = @[@5.0f, @5.0f];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;

    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = @1.75;

    // Animate in the new plot, as an example
    dataSourceLinePlot.opacity        = 0.0;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDecimal;
    [newGraph addPlot:dataSourceLinePlot];

    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0;
    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];

    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";

    lineStyle            = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 1.0;
    lineStyle.lineWidth  = 3.0;
    lineStyle.lineColor  = [CPTColor blueColor];

    boundLinePlot.dataSource     = self;
    boundLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    boundLinePlot.interpolation  = CPTScatterPlotInterpolationHistogram;
    [newGraph addPlot:boundLinePlot];

    // Do a blue gradient
    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(0.3) blue:CPTFloat(1.0) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle         = -90.0;
    areaGradientFill            = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill      = areaGradientFill;
    boundLinePlot.areaBaseValue = @0.0;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;

    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 60; i++ ) {
        NSNumber *xVal = @(1 + i * 0.05);
        NSNumber *yVal = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);
        [contentArray addObject:@{ @"x": xVal, @"y": yVal }];
    }
    self.dataForPlot = contentArray;
}

-(void)constructBarChart
{
    // Create barChart from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];

    self.barChartView.hostedGraph = newGraph;
    self.barChart                 = newGraph;

    newGraph.plotAreaFrame.masksToBorder = NO;

    newGraph.paddingLeft   = 70.0;
    newGraph.paddingTop    = 20.0;
    newGraph.paddingRight  = 20.0;
    newGraph.paddingBottom = 80.0;

    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@300.0];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@16.0];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle       = nil;
    x.majorTickLineStyle  = nil;
    x.minorTickLineStyle  = nil;
    x.majorIntervalLength = @5.0;
    x.orthogonalPosition  = @0.0;
    x.title               = @"X Axis";
    x.titleLocation       = @7.5;
    x.titleOffset         = 55.0;

    // Define some custom labels for the data elements
    x.labelRotation  = CPTFloat(M_PI_4);
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = @[@1, @5, @10, @15];
    NSArray *xAxisLabels         = @[@"Label A", @"Label B", @"Label C", @"Label D"];
    NSUInteger labelLocation     = 0;
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = tickLocation;
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = CPTFloat(M_PI_4);
        [customLabels addObject:newLabel];
    }

    x.axisLabels = customLabels;

    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle       = nil;
    y.majorTickLineStyle  = nil;
    y.minorTickLineStyle  = nil;
    y.majorIntervalLength = @50.0;
    y.orthogonalPosition  = @0.0;
    y.title               = @"Y Axis";
    y.titleOffset         = 45.0;
    y.titleLocation       = @150.0;

    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor darkGrayColor] horizontalBars:NO];
    barPlot.baseValue  = @0.0;
    barPlot.dataSource = self;
    barPlot.barOffset  = @(-0.25);
    barPlot.identifier = @"Bar Plot 1";
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];

    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = @0.0;
    barPlot.barOffset       = @0.25;
    barPlot.barCornerRadius = 2.0;
    barPlot.identifier      = @"Bar Plot 2";
    barPlot.delegate        = self;
    [newGraph addPlot:barPlot toPlotSpace:plotSpace];
}

-(void)constructPieChart
{
    // Create pieChart from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];

    self.pieChartView.hostedGraph = newGraph;
    self.pieGraph                 = newGraph;

    newGraph.plotAreaFrame.masksToBorder = NO;

    newGraph.paddingLeft   = 20.0;
    newGraph.paddingTop    = 20.0;
    newGraph.paddingRight  = 20.0;
    newGraph.paddingBottom = 20.0;

    newGraph.axisSet = nil;

    // Prepare a radial overlay gradient for shading/gloss
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.0)] atPosition:CPTFloat(0.0)];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.3)] atPosition:CPTFloat(0.9)];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.7)] atPosition:CPTFloat(1.0)];

    // Add pie chart
    CPTPieChart *newPlot = [[CPTPieChart alloc] init];
    newPlot.dataSource      = self;
    newPlot.pieRadius       = 130.0;
    newPlot.identifier      = @"Pie Chart 1";
    newPlot.startAngle      = CPTFloat(M_PI_4);
    newPlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    newPlot.borderLineStyle = [CPTLineStyle lineStyle];
    newPlot.labelOffset     = 5.0;
    newPlot.overlayFill     = [CPTFill fillWithGradient:overlayGradient];
    [newGraph addPlot:newPlot];
    self.piePlot = newPlot;

    // Add some initial data
    self.dataForChart = @[@20.0, @30.0, @(NAN), @60.0];
}

#pragma mark -
#pragma mark CPTBarPlot delegate method

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"barWasSelectedAtRecordIndex %lu", (unsigned long)index);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        return self.dataForChart.count;
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        return 16;
    }
    else {
        return self.dataForPlot.count;
    }
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        if ( index >= [self.dataForChart count] ) {
            return nil;
        }

        if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
            num = (self.dataForChart)[index];
        }
        else {
            num = @(index);
        }
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                if ( index == 4 ) {
                    num = @(NAN);
                }
                else {
                    num = @(index);
                }
                break;

            case CPTBarPlotFieldBarTip:
                if ( index == 8 ) {
                    num = @(NAN);
                }
                else {
                    num = @( (index + 1) * (index + 1) );
                    if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
                        num = @(num.integerValue - 10);
                    }
                }
                break;
        }
    }
    else {
        if ( index % 8 ) {
            NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
            num = self.dataForPlot[index][key];
            // Green plot gets shifted above the blue
            if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
                if ( fieldEnum == CPTScatterPlotFieldY ) {
                    num = @([num doubleValue] + 1.0);
                }
            }
        }
        else {
            num = @(NAN);
        }
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( self.piePlotIsRotating ) {
        return nil;
    }

    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        whiteText = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    });

    CPTTextLayer *newLayer = nil;

    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        switch ( index ) {
            case 0:
                newLayer = (id)[NSNull null];
                break;

            default:
                newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index] style:whiteText];
                break;
        }
    }
    else if ( [plot isKindOfClass:[CPTScatterPlot class]] ) {
        newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index] style:whiteText];
    }

    return newLayer;
}

@end
