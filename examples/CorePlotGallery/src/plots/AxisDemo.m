//
//  AxisDemo.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "AxisDemo.h"

@implementation AxisDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Axis Demo";
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
    graph.plotAreaFrame.fill          = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingBottom = 50.0;
    graph.plotAreaFrame.paddingLeft   = 50.0;
    graph.plotAreaFrame.paddingRight  = 50.0;
    graph.plotAreaFrame.cornerRadius  = 10.0;
    graph.plotAreaFrame.masksToBorder = NO;

    graph.plotAreaFrame.axisSet.borderLineStyle = [CPTLineStyle lineStyle];

    graph.plotAreaFrame.plotArea.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(-10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.5) length:CPTDecimalFromDouble(10.0)];

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
    axisTitleTextStyle.fontSize = 14.0;

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.separateLayers              = NO;
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.5);
    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
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
    y.titleOffset           = 30.0;
    y.alternatingBandFills  = [NSArray arrayWithObjects:[[CPTColor blueColor] colorWithAlphaComponent:0.1], [NSNull null], nil];

    CPTFill *bandFill = [CPTFill fillWithColor:[[CPTColor darkGrayColor] colorWithAlphaComponent:0.5]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(7.0) length:CPTDecimalFromDouble(1.5)] fill:bandFill]];
    [y addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.5) length:CPTDecimalFromDouble(3.0)] fill:bandFill]];

    // Label y2 with an equal division labeling policy.
    axisLineStyle.lineColor = [CPTColor orangeColor];

    CPTXYAxis *y2 = [[[CPTXYAxis alloc] init] autorelease];
    y2.coordinate                  = CPTCoordinateY;
    y2.plotSpace                   = plotSpace;
    y2.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-10.0);
    y2.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    y2.separateLayers              = NO;
    y2.preferredNumberOfMajorTicks = 6;
    y2.minorTicksPerInterval       = 9;
    y2.tickDirection               = CPTSignPositive;
    y2.axisLineStyle               = axisLineStyle;
    y2.majorTickLength             = 6.0;
    y2.majorTickLineStyle          = axisLineStyle;
    y2.minorTickLength             = 4.0;
    y2.title                       = @"Y2 Axis";
    y2.titleTextStyle              = axisTitleTextStyle;
    y2.titleOffset                 = 30.0;

    // Add the y2 axis to the axis set
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
}

@end
