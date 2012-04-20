#import "AxisDemoController.h"

@implementation AxisDemoController

-(void)awakeFromNib
{
    [super awakeFromNib];

    // Create graph
    CPTXYGraph *graph = [[(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)] autorelease];
    graph.fill           = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.cornerRadius   = 20.0;
    hostView.hostedGraph = graph;

    // Plot area
    graph.plotAreaFrame.fill          = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingBottom = 50.0;
    graph.plotAreaFrame.paddingLeft   = 50.0;
    graph.plotAreaFrame.paddingRight  = 20.0;
    graph.plotAreaFrame.cornerRadius  = 10.0;

    graph.plotAreaFrame.axisSet.borderLineStyle = [CPTLineStyle lineStyle];

    graph.plotAreaFrame.plotArea.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(-10.0)];
    plotSpace.yRange     = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.5) length:CPTDecimalFromDouble(1500.0)];
    plotSpace.yScaleType = CPTScaleTypeLog;

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
    axisTitleTextStyle.fontName = @"Helvetica Bold";
    axisTitleTextStyle.fontSize = 14.0;

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.separateLayers              = NO;
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.5);
    x.majorIntervalLength         = CPTDecimalFromString(@"0.5");
    x.minorTicksPerInterval       = 4;
    x.tickDirection               = CPTSignNone;
    x.axisLineStyle               = axisLineStyle;
    x.majorTickLength             = 12.0;
    x.majorTickLineStyle          = axisLineStyle;
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorTickLength             = 8.0;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.title                       = @"X Axis";
    x.titleTextStyle              = axisTitleTextStyle;
    x.titleOffset                 = 25.0;
    x.alternatingBandFills        = [NSArray arrayWithObjects:[[CPTColor redColor] colorWithAlphaComponent:0.1], [[CPTColor greenColor] colorWithAlphaComponent:0.1], nil];
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;

    // Label y with an automatic label policy.
    axisLineStyle.lineColor = [CPTColor greenColor];

    CPTXYAxis *y = axisSet.yAxis;
    y.separateLayers        = YES;
    y.minorTicksPerInterval = 9;
    y.tickDirection         = CPTSignNone;
    y.axisLineStyle         = axisLineStyle;
    y.majorTickLength       = 12.0;
    y.majorTickLineStyle    = axisLineStyle;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorTickLength       = 8.0;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.title                 = @"Y Axis";
    y.titleTextStyle        = axisTitleTextStyle;
    y.titleOffset           = 30.0;
    y.alternatingBandFills  = [NSArray arrayWithObjects:[[CPTColor blueColor] colorWithAlphaComponent:0.1], [NSNull null], nil];
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;

    CPTFill *bandFill = [CPTFill fillWithColor:[[CPTColor darkGrayColor] colorWithAlphaComponent:0.5]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(7.0) length:CPTDecimalFromDouble(1.5)] fill:bandFill]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.5) length:CPTDecimalFromDouble(3.0)] fill:bandFill]];
}

@end
