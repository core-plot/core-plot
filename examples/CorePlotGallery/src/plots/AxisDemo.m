//
//  AxisDemo.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "AxisDemo.h"

@implementation AxisDemo

+ (void)load
{
    // Not working yet...
	//[super registerPlotItem:self];
}

- (id)init
{
    if (self = [super init]) {
        title = @"Axis Demo";
    }
    
    return self;
}

- (void)generateData
{
    if (plotData == nil) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < 10; i++) {
            id x = [NSDecimalNumber numberWithDouble:1.0 + i * 0.05];
            id y = [NSDecimalNumber numberWithDouble:1.2 * rand()/(double)RAND_MAX + 0.5];
            [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
        }
        plotData = [contentArray retain];
    }
}

- (void)renderInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme
{
#if TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    // Create graph
    CPGraph* graph = [[[CPXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPSlateTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    
	graph.fill = [CPFill fillWithColor:[CPColor darkGrayColor]];
	graph.cornerRadius = 20.0;
	
	// Plot area
	graph.plotAreaFrame.fill = [CPFill fillWithColor:[CPColor lightGrayColor]];
	graph.plotAreaFrame.paddingTop = 20.0;
	graph.plotAreaFrame.paddingBottom = 50.0;
	graph.plotAreaFrame.paddingLeft = 50.0;
	graph.plotAreaFrame.paddingRight = 20.0;
	graph.plotAreaFrame.cornerRadius = 10.0;
	
	graph.plotAreaFrame.axisSet.borderLineStyle = [CPLineStyle lineStyle];
    
	graph.plotAreaFrame.plotArea.fill = [CPFill fillWithColor:[CPColor whiteColor]];
	
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.5) length:CPDecimalFromDouble(10.0)];
	
    // Line styles
    CPMutableLineStyle *axisLineStyle = [CPMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;
	axisLineStyle.lineCap = kCGLineCapRound;
    
    CPMutableLineStyle *majorGridLineStyle = [CPMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPColor redColor];
    
    CPMutableLineStyle *minorGridLineStyle = [CPMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPColor blueColor];
	
	// Text styles
	CPMutableTextStyle *axisTitleTextStyle = [CPMutableTextStyle textStyle];
	axisTitleTextStyle.fontName = @"Helvetica Bold";
	axisTitleTextStyle.fontSize = 14.0;
	
    // Axes
    // Label x axis with a fixed interval policy
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
	x.separateLayers = NO;
	x.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.5);
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.minorTicksPerInterval = 4;
	x.tickDirection = CPSignNone;
	x.axisLineStyle = axisLineStyle;
	x.majorTickLength = 12.0;
	x.majorTickLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
	x.minorTickLength = 8.0;
    x.minorGridLineStyle = minorGridLineStyle;
	x.title = @"X Axis";
	x.titleTextStyle = axisTitleTextStyle;
	x.titleOffset = 25.0;
	x.alternatingBandFills = [NSArray arrayWithObjects:[[CPColor redColor] colorWithAlphaComponent:0.1], [[CPColor greenColor] colorWithAlphaComponent:0.1], nil];
	
	// Label y with an automatic label policy.
	axisLineStyle.lineColor = [CPColor greenColor];
	
    CPXYAxis *y = axisSet.yAxis;
	y.separateLayers = YES;
    y.minorTicksPerInterval = 9;
	y.tickDirection = CPSignNone;
	y.axisLineStyle = axisLineStyle;
	y.majorTickLength = 12.0;
	y.majorTickLineStyle = axisLineStyle;
    y.majorGridLineStyle = majorGridLineStyle;
	y.minorTickLength = 8.0;
    y.minorGridLineStyle = minorGridLineStyle;
	y.title = @"Y Axis";
	y.titleTextStyle = axisTitleTextStyle;
	y.titleOffset = 30.0;
	y.alternatingBandFills = [NSArray arrayWithObjects:[[CPColor blueColor] colorWithAlphaComponent:0.1], [NSNull null], nil];
	
	CPFill *bandFill = [CPFill fillWithColor:[[CPColor darkGrayColor] colorWithAlphaComponent:0.5]];
	[y addBackgroundLimitBand:[CPLimitBand limitBandWithRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(7.0) length:CPDecimalFromDouble(1.5)] fill:bandFill]];
	[y addBackgroundLimitBand:[CPLimitBand limitBandWithRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(1.5) length:CPDecimalFromDouble(3.0)] fill:bandFill]];
}

- (void)dealloc
{
    [plotData release];
	[super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber* num = [[plotData objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if (fieldEnum == CPScatterPlotFieldY) {
        num = [NSNumber numberWithDouble:[num doubleValue]];
    }
    
    return num;
}

@end
