//
// LabelingPolicyDemo.m
// Plot Gallery
//

#import "LabelingPolicyDemo.h"

@implementation LabelingPolicyDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Axis Labeling Policies";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
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

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@5.75 length:@(-5.0)];

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

    // Tick locations
    CPTNumberSet majorTickLocations = [NSSet setWithObjects:@0, @30, @50, @85, @100, nil];

    CPTMutableNumberSet minorTickLocations = [NSMutableSet set];
    for ( NSUInteger loc = 0; loc <= 100; loc += 10 ) {
        [minorTickLocations addObject:@(loc)];
    }

    // Axes
    // CPTAxisLabelingPolicyNone
    CPTXYAxis *axisNone = [[CPTXYAxis alloc] init];
    axisNone.plotSpace          = graph.defaultPlotSpace;
    axisNone.labelingPolicy     = CPTAxisLabelingPolicyNone;
    axisNone.orthogonalPosition = @1.0;
    axisNone.tickDirection      = CPTSignNone;
    axisNone.axisLineStyle      = axisLineStyle;
    axisNone.majorTickLength    = majorTickLength;
    axisNone.majorTickLineStyle = majorTickLineStyle;
    axisNone.minorTickLength    = minorTickLength;
    axisNone.minorTickLineStyle = minorTickLineStyle;
    axisNone.title              = @"CPTAxisLabelingPolicyNone";
    axisNone.titleTextStyle     = axisTitleTextStyle;
    axisNone.titleOffset        = titleOffset;
    axisNone.majorTickLocations = majorTickLocations;
    axisNone.minorTickLocations = minorTickLocations;

    CPTMutableAxisLabelSet newAxisLabels = [NSMutableSet set];
    for ( NSUInteger i = 0; i <= 5; i++ ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"Label %lu", (unsigned long)i]
                                                          textStyle:axisNone.labelTextStyle];
        newLabel.tickLocation = @(i * 20);
        newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / CPTFloat(2.0);

        [newAxisLabels addObject:newLabel];
    }
    axisNone.axisLabels = newAxisLabels;

    // CPTAxisLabelingPolicyLocationsProvided
    CPTXYAxis *axisLocationsProvided = [[CPTXYAxis alloc] init];
    axisLocationsProvided.plotSpace          = graph.defaultPlotSpace;
    axisLocationsProvided.labelingPolicy     = CPTAxisLabelingPolicyLocationsProvided;
    axisLocationsProvided.orthogonalPosition = @2.0;
    axisLocationsProvided.tickDirection      = CPTSignNone;
    axisLocationsProvided.axisLineStyle      = axisLineStyle;
    axisLocationsProvided.majorTickLength    = majorTickLength;
    axisLocationsProvided.majorTickLineStyle = majorTickLineStyle;
    axisLocationsProvided.minorTickLength    = minorTickLength;
    axisLocationsProvided.minorTickLineStyle = minorTickLineStyle;
    axisLocationsProvided.title              = @"CPTAxisLabelingPolicyLocationsProvided";
    axisLocationsProvided.titleTextStyle     = axisTitleTextStyle;
    axisLocationsProvided.titleOffset        = titleOffset;
    axisLocationsProvided.majorTickLocations = majorTickLocations;
    axisLocationsProvided.minorTickLocations = minorTickLocations;

    // CPTAxisLabelingPolicyFixedInterval
    CPTXYAxis *axisFixedInterval = [[CPTXYAxis alloc] init];
    axisFixedInterval.plotSpace             = graph.defaultPlotSpace;
    axisFixedInterval.labelingPolicy        = CPTAxisLabelingPolicyFixedInterval;
    axisFixedInterval.orthogonalPosition    = @3.0;
    axisFixedInterval.majorIntervalLength   = @25.0;
    axisFixedInterval.minorTicksPerInterval = 4;
    axisFixedInterval.tickDirection         = CPTSignNone;
    axisFixedInterval.axisLineStyle         = axisLineStyle;
    axisFixedInterval.majorTickLength       = majorTickLength;
    axisFixedInterval.majorTickLineStyle    = majorTickLineStyle;
    axisFixedInterval.minorTickLength       = minorTickLength;
    axisFixedInterval.minorTickLineStyle    = minorTickLineStyle;
    axisFixedInterval.title                 = @"CPTAxisLabelingPolicyFixedInterval";
    axisFixedInterval.titleTextStyle        = axisTitleTextStyle;
    axisFixedInterval.titleOffset           = titleOffset;

    // CPTAxisLabelingPolicyAutomatic
    CPTXYAxis *axisAutomatic = [[CPTXYAxis alloc] init];
    axisAutomatic.plotSpace             = graph.defaultPlotSpace;
    axisAutomatic.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    axisAutomatic.orthogonalPosition    = @4.0;
    axisAutomatic.minorTicksPerInterval = 9;
    axisAutomatic.tickDirection         = CPTSignNone;
    axisAutomatic.axisLineStyle         = axisLineStyle;
    axisAutomatic.majorTickLength       = majorTickLength;
    axisAutomatic.majorTickLineStyle    = majorTickLineStyle;
    axisAutomatic.minorTickLength       = minorTickLength;
    axisAutomatic.minorTickLineStyle    = minorTickLineStyle;
    axisAutomatic.title                 = @"CPTAxisLabelingPolicyAutomatic";
    axisAutomatic.titleTextStyle        = axisTitleTextStyle;
    axisAutomatic.titleOffset           = titleOffset;

    // CPTAxisLabelingPolicyEqualDivisions
    CPTXYAxis *axisEqualDivisions = [[CPTXYAxis alloc] init];
    axisEqualDivisions.plotSpace                   = graph.defaultPlotSpace;
    axisEqualDivisions.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisEqualDivisions.orthogonalPosition          = @5.0;
    axisEqualDivisions.preferredNumberOfMajorTicks = 7;
    axisEqualDivisions.minorTicksPerInterval       = 4;
    axisEqualDivisions.tickDirection               = CPTSignNone;
    axisEqualDivisions.axisLineStyle               = axisLineStyle;
    axisEqualDivisions.majorTickLength             = majorTickLength;
    axisEqualDivisions.majorTickLineStyle          = majorTickLineStyle;
    axisEqualDivisions.minorTickLength             = minorTickLength;
    axisEqualDivisions.minorTickLineStyle          = minorTickLineStyle;
    axisEqualDivisions.title                       = @"CPTAxisLabelingPolicyEqualDivisions";
    axisEqualDivisions.titleTextStyle              = axisTitleTextStyle;
    axisEqualDivisions.titleOffset                 = titleOffset;

    // Add axes to the graph
    graph.axisSet.axes = @[axisNone, axisLocationsProvided, axisFixedInterval, axisAutomatic, axisEqualDivisions];
}

@end
