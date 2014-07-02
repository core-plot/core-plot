//
//  SimpleScatterPlot.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "SimpleScatterPlot.h"

@implementation SimpleScatterPlot

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Simple Scatter Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    if ( [self.graphs count] ) {
        CPTGraph *graph = (self.graphs)[0];

        if ( symbolTextAnnotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
            [symbolTextAnnotation release];
            symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(void)generateData
{
    if ( plotData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 10; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * rand() / (double)RAND_MAX + 0.5);
            [contentArray addObject:@{ @"x": x, @"y": y }
            ];
        }
        plotData = [contentArray retain];
    }
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:bounds] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(1.0);
    x.minorTicksPerInterval       = 2;
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;

    x.title         = @"X Axis";
    x.titleOffset   = 30.0;
    x.titleLocation = CPTDecimalFromDouble(1.25);

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(1.0);
    y.minorTicksPerInterval       = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.labelOffset                 = 10.0;

    y.title         = @"Y Axis";
    y.titleOffset   = 30.0;
    y.titleLocation = CPTDecimalFromDouble(1.0);

    // Set axes
    //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
    graph.axisSet.axes = @[x, y];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";

    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Auto scale the plot space to fit the plot data
    // Extend the ranges by 30% for neatness
    [plotSpace scaleToFitPlots:@[dataSourceLinePlot]];
    CPTMutablePlotRange *xRange = [[plotSpace.xRange mutableCopy] autorelease];
    CPTMutablePlotRange *yRange = [[plotSpace.yRange mutableCopy] autorelease];
    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.3)];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.3)];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
                                                              length:CPTDecimalFromFloat(2.0f)];
    plotSpace.globalYRange = globalYRange;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate                        = self;
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legend.swatchSize      = CGSizeMake(25.0, 25.0);
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, 12.0);
}

-(void)dealloc
{
    [symbolTextAnnotation release];
    [plotData release];
    [super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = plotData[index][key];

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if ( coordinate == CPTCoordinateX ) {
        CPTPlotRange *maxRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(6.0f)];
        CPTMutablePlotRange *changedRange = [[newRange mutableCopy] autorelease];
        [changedRange shiftEndToFitInRange:maxRange];
        [changedRange shiftLocationToFitInRange:maxRange];
        newRange = changedRange;
    }

    return newRange;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *graph = (self.graphs)[0];

    if ( symbolTextAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        [symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSDictionary *dataPoint = plotData[index];

    NSNumber *x = dataPoint[@"x"];
    NSNumber *y = dataPoint[@"y"];

    NSArray *anchorPoint = @[x, y];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0, 20.0);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
}

-(void)scatterPlotDataLineWasSelected:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
}

-(void)scatterPlotDataLineTouchDown:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchDown: %@", plot);
}

-(void)scatterPlotDataLineTouchUp:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchUp: %@", plot);
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea
{
    // Remove the annotation
    if ( symbolTextAnnotation ) {
        CPTXYGraph *graph = [self.graphs objectAtIndex:0];

        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        [symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }
}

@end
