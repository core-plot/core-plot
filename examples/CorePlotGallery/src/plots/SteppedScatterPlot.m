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
    if (self = [super init]) {
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

- (void)renderInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme
{
#if TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPGraph* graph = [[[CPXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPSlateTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    
    CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
	dataSourceLinePlot.cachePrecision = CPPlotCachePrecisionDouble;
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.0;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;

	CPTextStyle *whiteTextStyle = [CPTextStyle textStyle];
    whiteTextStyle.color = [CPColor whiteColor];
	dataSourceLinePlot.labelTextStyle = whiteTextStyle;
	dataSourceLinePlot.labelOffset = 5.0;
	dataSourceLinePlot.labelRotation = M_PI_4;
    [graph addPlot:dataSourceLinePlot];

    // Make the data source line use stepped interpolation
    dataSourceLinePlot.interpolation = CPScatterPlotInterpolationStepped;
    
    // Put an area gradient under the plot above
    CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
    areaGradient.angle = -90.0;
    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"1.75");
	
    [self generateData];
    
    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    CPXYPlotSpace *plotSpace = (id)graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:dataSourceLinePlot, nil]];
    CPPlotRange *xRange = plotSpace.xRange;
    CPPlotRange *yRange = plotSpace.yRange;
    [yRange expandRangeByFactor:CPDecimalFromDouble(1.1)];
    plotSpace.yRange = yRange;
    
    // Restrict y range to a global range
    CPPlotRange *globalYRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(6.0f)];
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
