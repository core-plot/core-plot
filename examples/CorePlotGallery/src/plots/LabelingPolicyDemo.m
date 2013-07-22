//
//  LabelingPolicyDemo.m
//  Plot Gallery
//

#import "LabelingPolicyDemo.h"

static const CGFloat majorTickLength = 12.0;
static const CGFloat minorTickLength = 8.0;
static const CGFloat titleOffset     = 25.0;

@implementation LabelingPolicyDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Axis Labeling Policies";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    // Create graph
    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:bounds] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    graph.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];

    // Plot area
    graph.plotAreaFrame.paddingTop    = 25.0;
    graph.plotAreaFrame.paddingBottom = 25.0;
    graph.plotAreaFrame.paddingLeft   = 25.0;
    graph.plotAreaFrame.paddingRight  = 25.0;
    graph.plotAreaFrame.masksToBorder = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(100)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(5.75) length:CPTDecimalFromInteger(-5)];

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
    axisTitleTextStyle.fontSize = 14.0;

    // Tick locations
    NSSet *majorTickLocations = [NSSet setWithObjects:@0, @30, @50, @85, @100, nil];

    NSMutableSet *minorTickLocations = [NSMutableSet set];
    for ( NSUInteger loc = 0; loc <= 100; loc += 10 ) {
        [minorTickLocations addObject:@(loc)];
    }

    // Axes
    // CPTAxisLabelingPolicyNone
    CPTXYAxis *axisNone = [[[CPTXYAxis alloc] init] autorelease];
    axisNone.plotSpace                   = graph.defaultPlotSpace;
    axisNone.labelingPolicy              = CPTAxisLabelingPolicyNone;
    axisNone.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(1);
    axisNone.tickDirection               = CPTSignNone;
    axisNone.axisLineStyle               = axisLineStyle;
    axisNone.majorTickLength             = majorTickLength;
    axisNone.majorTickLineStyle          = majorTickLineStyle;
    axisNone.minorTickLength             = minorTickLength;
    axisNone.minorTickLineStyle          = minorTickLineStyle;
    axisNone.title                       = @"CPTAxisLabelingPolicyNone";
    axisNone.titleTextStyle              = axisTitleTextStyle;
    axisNone.titleOffset                 = titleOffset;
    axisNone.majorTickLocations          = majorTickLocations;
    axisNone.minorTickLocations          = minorTickLocations;
    NSMutableSet *newAxisLabels = [NSMutableSet set];
    for ( NSUInteger i = 0; i <= 5; i++ ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"Label %lu", (unsigned long)i]
                                                          textStyle:axisNone.labelTextStyle];
        newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 20);
        newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;

        [newAxisLabels addObject:newLabel];
    }
    axisNone.axisLabels = newAxisLabels;

    // CPTAxisLabelingPolicyLocationsProvided
    CPTXYAxis *axisLocationsProvided = [[[CPTXYAxis alloc] init] autorelease];
    axisLocationsProvided.plotSpace                   = graph.defaultPlotSpace;
    axisLocationsProvided.labelingPolicy              = CPTAxisLabelingPolicyLocationsProvided;
    axisLocationsProvided.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(2);
    axisLocationsProvided.tickDirection               = CPTSignNone;
    axisLocationsProvided.axisLineStyle               = axisLineStyle;
    axisLocationsProvided.majorTickLength             = majorTickLength;
    axisLocationsProvided.majorTickLineStyle          = majorTickLineStyle;
    axisLocationsProvided.minorTickLength             = minorTickLength;
    axisLocationsProvided.minorTickLineStyle          = minorTickLineStyle;
    axisLocationsProvided.title                       = @"CPTAxisLabelingPolicyLocationsProvided";
    axisLocationsProvided.titleTextStyle              = axisTitleTextStyle;
    axisLocationsProvided.titleOffset                 = titleOffset;
    axisLocationsProvided.majorTickLocations          = majorTickLocations;
    axisLocationsProvided.minorTickLocations          = minorTickLocations;

    // CPTAxisLabelingPolicyFixedInterval
    CPTXYAxis *axisFixedInterval = [[[CPTXYAxis alloc] init] autorelease];
    axisFixedInterval.plotSpace                   = graph.defaultPlotSpace;
    axisFixedInterval.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    axisFixedInterval.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(3);
    axisFixedInterval.majorIntervalLength         = CPTDecimalFromDouble(25.0);
    axisFixedInterval.minorTicksPerInterval       = 4;
    axisFixedInterval.tickDirection               = CPTSignNone;
    axisFixedInterval.axisLineStyle               = axisLineStyle;
    axisFixedInterval.majorTickLength             = majorTickLength;
    axisFixedInterval.majorTickLineStyle          = majorTickLineStyle;
    axisFixedInterval.minorTickLength             = minorTickLength;
    axisFixedInterval.minorTickLineStyle          = minorTickLineStyle;
    axisFixedInterval.title                       = @"CPTAxisLabelingPolicyFixedInterval";
    axisFixedInterval.titleTextStyle              = axisTitleTextStyle;
    axisFixedInterval.titleOffset                 = titleOffset;

    // CPTAxisLabelingPolicyAutomatic
    CPTXYAxis *axisAutomatic = [[[CPTXYAxis alloc] init] autorelease];
    axisAutomatic.plotSpace                   = graph.defaultPlotSpace;
    axisAutomatic.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    axisAutomatic.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(4);
    axisAutomatic.minorTicksPerInterval       = 9;
    axisAutomatic.tickDirection               = CPTSignNone;
    axisAutomatic.axisLineStyle               = axisLineStyle;
    axisAutomatic.majorTickLength             = majorTickLength;
    axisAutomatic.majorTickLineStyle          = majorTickLineStyle;
    axisAutomatic.minorTickLength             = minorTickLength;
    axisAutomatic.minorTickLineStyle          = minorTickLineStyle;
    axisAutomatic.title                       = @"CPTAxisLabelingPolicyAutomatic";
    axisAutomatic.titleTextStyle              = axisTitleTextStyle;
    axisAutomatic.titleOffset                 = titleOffset;

    // CPTAxisLabelingPolicyEqualDivisions
    CPTXYAxis *axisEqualDivisions = [[[CPTXYAxis alloc] init] autorelease];
    axisEqualDivisions.plotSpace                   = graph.defaultPlotSpace;
    axisEqualDivisions.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisEqualDivisions.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(5);
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
