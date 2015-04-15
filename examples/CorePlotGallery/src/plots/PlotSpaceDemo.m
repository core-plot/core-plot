//
//  PlotSpaceDemo.m
//  Plot Gallery
//

#import "PlotSpaceDemo.h"

@implementation PlotSpaceDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Plot Space Demo";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    const CGFloat majorTickLength = 12.0;
    const CGFloat minorTickLength = 8.0;
    const CGFloat titleOffset     = self.titleSize;

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
    graph.plotAreaFrame.paddingTop    = self.titleSize;
    graph.plotAreaFrame.paddingBottom = self.titleSize;
    graph.plotAreaFrame.paddingLeft   = self.titleSize;
    graph.plotAreaFrame.paddingRight  = self.titleSize;
    graph.plotAreaFrame.masksToBorder = NO;

    // Line styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;

    CPTMutableLineStyle *majorTickLineStyle = [axisLineStyle mutableCopy];
    majorTickLineStyle.lineWidth = 3.0;
    majorTickLineStyle.lineCap   = kCGLineCapRound;

    CPTMutableLineStyle *minorTickLineStyle = [axisLineStyle mutableCopy];
    minorTickLineStyle.lineWidth = 2.0;
    minorTickLineStyle.lineCap   = kCGLineCapRound;

    // Text styles
    CPTMutableTextStyle *axisTitleTextStyle = [CPTMutableTextStyle textStyle];
    axisTitleTextStyle.fontName = @"Helvetica-Bold";

    // Plot Spaces
    CPTXYPlotSpace *linearPlotSpace = [[CPTXYPlotSpace alloc] init];
    linearPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(100)];
    linearPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(4.5) length:CPTDecimalFromInteger(-4)];

    CPTXYPlotSpace *negativeLinearPlotSpace = [[CPTXYPlotSpace alloc] init];
    negativeLinearPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(100) length:CPTDecimalFromInteger(-100)];
    negativeLinearPlotSpace.yRange = linearPlotSpace.yRange;

    CPTXYPlotSpace *logPlotSpace = [[CPTXYPlotSpace alloc] init];
    logPlotSpace.xScaleType = CPTScaleTypeLog;
    logPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.1) length:CPTDecimalFromDouble(99.9)];
    logPlotSpace.yRange     = linearPlotSpace.yRange;

    CPTXYPlotSpace *negativeLogPlotSpace = [[CPTXYPlotSpace alloc] init];
    negativeLogPlotSpace.xScaleType = CPTScaleTypeLog;
    negativeLogPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(100) length:CPTDecimalFromDouble(-99.9)];
    negativeLogPlotSpace.yRange     = linearPlotSpace.yRange;

    [graph removePlotSpace:graph.defaultPlotSpace];
    [graph addPlotSpace:linearPlotSpace];
    [graph addPlotSpace:negativeLinearPlotSpace];
    [graph addPlotSpace:logPlotSpace];
    [graph addPlotSpace:negativeLogPlotSpace];

    // Axes
    // Linear axis--positive direction
    CPTXYAxis *linearAxis = [[CPTXYAxis alloc] init];
    linearAxis.plotSpace                   = linearPlotSpace;
    linearAxis.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    linearAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(1);
    linearAxis.minorTicksPerInterval       = 9;
    linearAxis.tickDirection               = CPTSignNone;
    linearAxis.axisLineStyle               = axisLineStyle;
    linearAxis.majorTickLength             = majorTickLength;
    linearAxis.majorTickLineStyle          = majorTickLineStyle;
    linearAxis.minorTickLength             = minorTickLength;
    linearAxis.minorTickLineStyle          = minorTickLineStyle;
    linearAxis.title                       = @"Linear Plot Space—Positive Length";
    linearAxis.titleTextStyle              = axisTitleTextStyle;
    linearAxis.titleOffset                 = titleOffset;

    // Linear axis--negative direction
    CPTXYAxis *negativeLinearAxis = [[CPTXYAxis alloc] init];
    negativeLinearAxis.plotSpace                   = negativeLinearPlotSpace;
    negativeLinearAxis.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    negativeLinearAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(2);
    negativeLinearAxis.minorTicksPerInterval       = 9;
    negativeLinearAxis.tickDirection               = CPTSignNone;
    negativeLinearAxis.axisLineStyle               = axisLineStyle;
    negativeLinearAxis.majorTickLength             = majorTickLength;
    negativeLinearAxis.majorTickLineStyle          = majorTickLineStyle;
    negativeLinearAxis.minorTickLength             = minorTickLength;
    negativeLinearAxis.minorTickLineStyle          = minorTickLineStyle;
    negativeLinearAxis.title                       = @"Linear Plot Space—Negative Length";
    negativeLinearAxis.titleTextStyle              = axisTitleTextStyle;
    negativeLinearAxis.titleOffset                 = titleOffset;

    // Log axis--positive direction
    CPTXYAxis *logAxis = [[CPTXYAxis alloc] init];
    logAxis.plotSpace                   = logPlotSpace;
    logAxis.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    logAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(3);
    logAxis.minorTicksPerInterval       = 9;
    logAxis.tickDirection               = CPTSignNone;
    logAxis.axisLineStyle               = axisLineStyle;
    logAxis.majorTickLength             = majorTickLength;
    logAxis.majorTickLineStyle          = majorTickLineStyle;
    logAxis.minorTickLength             = minorTickLength;
    logAxis.minorTickLineStyle          = minorTickLineStyle;
    logAxis.title                       = @"Log Plot Space—Positive Length";
    logAxis.titleTextStyle              = axisTitleTextStyle;
    logAxis.titleOffset                 = titleOffset;

    // Log axis--negative direction
    CPTXYAxis *negativeLogAxis = [[CPTXYAxis alloc] init];
    negativeLogAxis.plotSpace                   = negativeLogPlotSpace;
    negativeLogAxis.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    negativeLogAxis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(4);
    negativeLogAxis.minorTicksPerInterval       = 9;
    negativeLogAxis.tickDirection               = CPTSignNone;
    negativeLogAxis.axisLineStyle               = axisLineStyle;
    negativeLogAxis.majorTickLength             = majorTickLength;
    negativeLogAxis.majorTickLineStyle          = majorTickLineStyle;
    negativeLogAxis.minorTickLength             = minorTickLength;
    negativeLogAxis.minorTickLineStyle          = minorTickLineStyle;
    negativeLogAxis.title                       = @"Log Plot Space—Negative Length";
    negativeLogAxis.titleTextStyle              = axisTitleTextStyle;
    negativeLogAxis.titleOffset                 = titleOffset;

    // Add axes to the graph
    graph.axisSet.axes = @[linearAxis, negativeLinearAxis, logAxis, negativeLogAxis];
}

@end
