//
// AxisDemo.m
// Plot Gallery-Mac
//

#import "AxisDemo.h"

@implementation AxisDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Axis Demo";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    // Create graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];

    graph.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];

    // Plot area
    graph.plotAreaFrame.fill          = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.plotAreaFrame.paddingTop    = self.titleSize;
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.cornerRadius  = 10.0;
    graph.plotAreaFrame.masksToBorder = NO;

    graph.plotAreaFrame.axisSet.borderLineStyle = [CPTLineStyle lineStyle];

    graph.plotAreaFrame.plotArea.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(-10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.5 length:@10.0];

    // Line styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;
    axisLineStyle.lineCap   = kCGLineCapRound;

    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPTColor redColor];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPTColor blueColor];

    // Text styles
    CPTMutableTextStyle *axisTitleTextStyle = [CPTMutableTextStyle textStyle];
    axisTitleTextStyle.fontName = @"Helvetica-Bold";

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.separateLayers        = NO;
    x.orthogonalPosition    = @0.5;
    x.majorIntervalLength   = @0.5;
    x.minorTicksPerInterval = 4;
    x.tickDirection         = CPTSignNone;
    x.axisLineStyle         = axisLineStyle;
    x.majorTickLength       = 12.0;
    x.majorTickLineStyle    = axisLineStyle;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorTickLength       = 8.0;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.title                 = @"X Axis";
    x.titleTextStyle        = axisTitleTextStyle;
    x.titleOffset           = self.titleSize;
    x.alternatingBandFills  = @[[[CPTColor redColor] colorWithAlphaComponent:CPTFloat(0.1)], [[CPTColor greenColor] colorWithAlphaComponent:CPTFloat(0.1)]];
    x.delegate              = self;

    // Label y with an automatic labeling policy.
    axisLineStyle.lineColor = [CPTColor greenColor];

    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    y.separateLayers        = YES;
    y.minorTicksPerInterval = 9;
    y.tickDirection         = CPTSignNegative;
    y.axisLineStyle         = axisLineStyle;
    y.majorTickLength       = 6.0;
    y.majorTickLineStyle    = axisLineStyle;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorTickLength       = 4.0;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.title                 = @"Y Axis";
    y.titleTextStyle        = axisTitleTextStyle;
    y.titleOffset           = self.titleSize * CPTFloat(1.1);
    y.alternatingBandFills  = @[[[CPTColor blueColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.delegate              = self;

    CPTFill *bandFill = [CPTFill fillWithColor:[[CPTColor darkGrayColor] colorWithAlphaComponent:0.5]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:@7.0 length:@1.5] fill:bandFill]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:@1.5 length:@3.0] fill:bandFill]];

    // Label y2 with an equal division labeling policy.
    axisLineStyle.lineColor = [CPTColor orangeColor];

    CPTXYAxis *y2 = [[CPTXYAxis alloc] init];
    y2.coordinate                  = CPTCoordinateY;
    y2.plotSpace                   = plotSpace;
    y2.orthogonalPosition          = @(-10.0);
    y2.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    y2.separateLayers              = NO;
    y2.preferredNumberOfMajorTicks = 6;
    y2.minorTicksPerInterval       = 9;
    y2.tickDirection               = CPTSignNone;
    y2.tickLabelDirection          = CPTSignPositive;
    y2.labelTextStyle              = y.labelTextStyle;
    y2.axisLineStyle               = axisLineStyle;
    y2.majorTickLength             = 12.0;
    y2.majorTickLineStyle          = axisLineStyle;
    y2.minorTickLength             = 8.0;
    y2.title                       = @"Y2 Axis";
    y2.titleTextStyle              = axisTitleTextStyle;
    y2.titleOffset                 = self.titleSize * CPTFloat(-2.1);
    y2.delegate                    = self;

    // Add the y2 axis to the axis set
    graph.axisSet.axes = @[x, y, y2];
}

#pragma mark - Axis delegate

-(void)axis:(CPTAxis *)axis labelWasSelected:(CPTAxisLabel *)label
{
    NSLog(@"%@ label was selected at location %@", axis.title, label.tickLocation);
}

@end
