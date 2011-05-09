//
//  SteppedScatterPlot.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "SteppedScatterPlot.h"


@implementation SteppedScatterPlot

+ (void)load
{
	[super registerPlotItem:self];
}

- (id)init
{
    if ((self = [super init])) {
        title = @"Stepped Scatter Plot";
    }
    
    return self;
}

- (void)generateData
{
    if (plotData == nil) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < 10; i++) {
            id x = [NSDecimalNumber numberWithDouble:1.0 + i * 0.05];
            id y = [NSDecimalNumber numberWithDouble:1.2 * rand()/(double)RAND_MAX + 1.2];
            [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
        }
        plotData = [contentArray retain];
    }
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPTGraph* graph = [[[CPTXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth = 1.0;
    lineStyle.lineColor = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;

	CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color = [CPTColor whiteColor];
	dataSourceLinePlot.labelTextStyle = whiteTextStyle;
	dataSourceLinePlot.labelOffset = 5.0;
	dataSourceLinePlot.labelRotation = M_PI_4;
    [graph addPlot:dataSourceLinePlot];

    // Make the data source line use stepped interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationStepped;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");
	
    [self generateData];
    
    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    CPTXYPlotSpace *plotSpace = (id)graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:dataSourceLinePlot, nil]];
    CPTPlotRange *xRange = plotSpace.xRange;
    CPTPlotRange *yRange = plotSpace.yRange;
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.1)];
    plotSpace.yRange = yRange;
    
    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(6.0f)];
    plotSpace.globalYRange = globalYRange;
    
    // set the x and y shift to match the new ranges
	CGFloat length = xRange.lengthDouble;
	xShift = length - 3.0;
	length = yRange.lengthDouble;
	yShift = length - 2.0;

}

- (void)dealloc
{
    [plotData release];
	[super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber* num = [[plotData objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    if (fieldEnum == CPTScatterPlotFieldY) {
        num = [NSNumber numberWithDouble:[num doubleValue]];
    }
    
    return num;
}

@end
