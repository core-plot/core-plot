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

-(instancetype)init
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
    linearPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
    linearPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@6.5 length:@(-6.0)];

    CPTXYPlotSpace *negativeLinearPlotSpace = [[CPTXYPlotSpace alloc] init];
    negativeLinearPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@100.0 length:@(-100.0)];
    negativeLinearPlotSpace.yRange = linearPlotSpace.yRange;

    CPTXYPlotSpace *logPlotSpace = [[CPTXYPlotSpace alloc] init];
    logPlotSpace.xScaleType = CPTScaleTypeLog;
    logPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:@0.1 length:@99.9];
    logPlotSpace.yRange     = linearPlotSpace.yRange;

    CPTXYPlotSpace *negativeLogPlotSpace = [[CPTXYPlotSpace alloc] init];
    negativeLogPlotSpace.xScaleType = CPTScaleTypeLog;
    negativeLogPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:@100.0 length:@(-99.9)];
    negativeLogPlotSpace.yRange     = linearPlotSpace.yRange;

    CPTXYPlotSpace *logModulusPlotSpace = [[CPTXYPlotSpace alloc] init];
    logModulusPlotSpace.xScaleType = CPTScaleTypeLogModulus;
    logModulusPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:@(-100.0) length:@1100.0];
    logModulusPlotSpace.yRange     = linearPlotSpace.yRange;

    CPTXYPlotSpace *negativeLogModulusPlotSpace = [[CPTXYPlotSpace alloc] init];
    negativeLogModulusPlotSpace.xScaleType = CPTScaleTypeLogModulus;
    negativeLogModulusPlotSpace.xRange     = [CPTPlotRange plotRangeWithLocation:@0.1 length:@(-0.2)];
    negativeLogModulusPlotSpace.yRange     = linearPlotSpace.yRange;

    [graph removePlotSpace:graph.defaultPlotSpace];
    [graph addPlotSpace:linearPlotSpace];
    [graph addPlotSpace:negativeLinearPlotSpace];
    [graph addPlotSpace:logPlotSpace];
    [graph addPlotSpace:negativeLogPlotSpace];
    [graph addPlotSpace:logModulusPlotSpace];
    [graph addPlotSpace:negativeLogModulusPlotSpace];

    // Axes
    // Linear axis--positive direction
    CPTXYAxis *linearAxis = [[CPTXYAxis alloc] init];
    linearAxis.plotSpace             = linearPlotSpace;
    linearAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    linearAxis.orthogonalPosition    = @1.0;
    linearAxis.minorTicksPerInterval = 9;
    linearAxis.tickDirection         = CPTSignNone;
    linearAxis.axisLineStyle         = axisLineStyle;
    linearAxis.majorTickLength       = majorTickLength;
    linearAxis.majorTickLineStyle    = majorTickLineStyle;
    linearAxis.minorTickLength       = minorTickLength;
    linearAxis.minorTickLineStyle    = minorTickLineStyle;
    linearAxis.title                 = @"Linear Plot Space—Positive Length";
    linearAxis.titleTextStyle        = axisTitleTextStyle;
    linearAxis.titleOffset           = titleOffset;

    // Linear axis--negative direction
    CPTXYAxis *negativeLinearAxis = [[CPTXYAxis alloc] init];
    negativeLinearAxis.plotSpace             = negativeLinearPlotSpace;
    negativeLinearAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    negativeLinearAxis.orthogonalPosition    = @2.0;
    negativeLinearAxis.minorTicksPerInterval = 4;
    negativeLinearAxis.tickDirection         = CPTSignNone;
    negativeLinearAxis.axisLineStyle         = axisLineStyle;
    negativeLinearAxis.majorTickLength       = majorTickLength;
    negativeLinearAxis.majorTickLineStyle    = majorTickLineStyle;
    negativeLinearAxis.minorTickLength       = minorTickLength;
    negativeLinearAxis.minorTickLineStyle    = minorTickLineStyle;
    negativeLinearAxis.title                 = @"Linear Plot Space—Negative Length";
    negativeLinearAxis.titleTextStyle        = axisTitleTextStyle;
    negativeLinearAxis.titleOffset           = titleOffset;

    // Log axis--positive direction
    CPTXYAxis *logAxis = [[CPTXYAxis alloc] init];
    logAxis.plotSpace             = logPlotSpace;
    logAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    logAxis.orthogonalPosition    = @3.0;
    logAxis.minorTicksPerInterval = 8;
    logAxis.tickDirection         = CPTSignNone;
    logAxis.axisLineStyle         = axisLineStyle;
    logAxis.majorTickLength       = majorTickLength;
    logAxis.majorTickLineStyle    = majorTickLineStyle;
    logAxis.minorTickLength       = minorTickLength;
    logAxis.minorTickLineStyle    = minorTickLineStyle;
    logAxis.title                 = @"Log Plot Space—Positive Length";
    logAxis.titleTextStyle        = axisTitleTextStyle;
    logAxis.titleOffset           = titleOffset;

    // Log axis--negative direction
    CPTXYAxis *negativeLogAxis = [[CPTXYAxis alloc] init];
    negativeLogAxis.plotSpace             = negativeLogPlotSpace;
    negativeLogAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    negativeLogAxis.orthogonalPosition    = @4.0;
    negativeLogAxis.minorTicksPerInterval = 4;
    negativeLogAxis.tickDirection         = CPTSignNone;
    negativeLogAxis.axisLineStyle         = axisLineStyle;
    negativeLogAxis.majorTickLength       = majorTickLength;
    negativeLogAxis.majorTickLineStyle    = majorTickLineStyle;
    negativeLogAxis.minorTickLength       = minorTickLength;
    negativeLogAxis.minorTickLineStyle    = minorTickLineStyle;
    negativeLogAxis.title                 = @"Log Plot Space—Negative Length";
    negativeLogAxis.titleTextStyle        = axisTitleTextStyle;
    negativeLogAxis.titleOffset           = titleOffset;

    // Log modulus axis--positive direction
    CPTXYAxis *logModulusAxis = [[CPTXYAxis alloc] init];
    logModulusAxis.plotSpace             = logModulusPlotSpace;
    logModulusAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    logModulusAxis.orthogonalPosition    = @5.0;
    logModulusAxis.minorTicksPerInterval = 8;
    logModulusAxis.tickDirection         = CPTSignNone;
    logModulusAxis.axisLineStyle         = axisLineStyle;
    logModulusAxis.majorTickLength       = majorTickLength;
    logModulusAxis.majorTickLineStyle    = majorTickLineStyle;
    logModulusAxis.minorTickLength       = minorTickLength;
    logModulusAxis.minorTickLineStyle    = minorTickLineStyle;
    logModulusAxis.title                 = @"Log Modulus Plot Space—Positive Length";
    logModulusAxis.titleTextStyle        = axisTitleTextStyle;
    logModulusAxis.titleOffset           = titleOffset;

    // Log modulus axis--negative direction
    CPTXYAxis *negativeLogModulusAxis = [[CPTXYAxis alloc] init];
    negativeLogModulusAxis.plotSpace             = negativeLogModulusPlotSpace;
    negativeLogModulusAxis.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    negativeLogModulusAxis.orthogonalPosition    = @6.0;
    negativeLogModulusAxis.minorTicksPerInterval = 4;
    negativeLogModulusAxis.tickDirection         = CPTSignNone;
    negativeLogModulusAxis.axisLineStyle         = axisLineStyle;
    negativeLogModulusAxis.majorTickLength       = majorTickLength;
    negativeLogModulusAxis.majorTickLineStyle    = majorTickLineStyle;
    negativeLogModulusAxis.minorTickLength       = minorTickLength;
    negativeLogModulusAxis.minorTickLineStyle    = minorTickLineStyle;
    negativeLogModulusAxis.title                 = @"Log Modulus Plot Space—Negative Length";
    negativeLogModulusAxis.titleTextStyle        = axisTitleTextStyle;
    negativeLogModulusAxis.titleOffset           = titleOffset;

    // Add axes to the graph
    graph.axisSet.axes = @[linearAxis, negativeLinearAxis, logAxis, negativeLogAxis, logModulusAxis, negativeLogModulusAxis];
}

@end
