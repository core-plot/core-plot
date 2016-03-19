//
// LineCapDemo.m
// Plot Gallery
//

#import "LineCapDemo.h"

@implementation LineCapDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Line Caps";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
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
    graph.plotAreaFrame.paddingTop    = self.titleSize;
    graph.plotAreaFrame.paddingBottom = self.titleSize;
    graph.plotAreaFrame.paddingLeft   = self.titleSize;
    graph.plotAreaFrame.paddingRight  = self.titleSize;
    graph.plotAreaFrame.masksToBorder = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@5.5 length:@(-6.0)];

    // Line styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;

    // Line cap
    CPTLineCap *lineCap = [CPTLineCap lineCap];
    lineCap.size      = CGSizeMake(15.0, 15.0);
    lineCap.lineStyle = axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:[CPTColor blueColor]];

    // Axes
    CPTMutableAxisArray axes = [[NSMutableArray alloc] init];

    CPTLineCapType lineCapType = CPTLineCapTypeNone;
    while ( lineCapType < CPTLineCapTypeCustom ) {
        CPTXYAxis *axis = [[CPTXYAxis alloc] init];
        axis.plotSpace          = graph.defaultPlotSpace;
        axis.labelingPolicy     = CPTAxisLabelingPolicyNone;
        axis.orthogonalPosition = @(lineCapType / 2);
        axis.axisLineStyle      = axisLineStyle;

        lineCap.lineCapType = lineCapType++;
        axis.axisLineCapMin = lineCap;

        lineCap.lineCapType = lineCapType++;
        axis.axisLineCapMax = lineCap;

        [axes addObject:axis];
    }

    // Add axes to the graph
    graph.axisSet.axes = axes;
}

@end
