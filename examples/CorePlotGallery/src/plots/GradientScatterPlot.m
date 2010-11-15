//
//  GradientScatterPlot.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "GradientScatterPlot.h"

@implementation GradientScatterPlot

+ (void)load
{
	[super registerPlotItem:self];
}

- (id)init
{
    if (self = [super init]) {
        title = @"Gradient Scatter Plot";
    }

    return self;
}

- (void)killGraph
{
    if ([graphs count]) {		
        CPGraph *graph = [graphs objectAtIndex:0];

        if (symbolTextAnnotation) {
            [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
            [symbolTextAnnotation release];
            symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

- (void)generateData
{
    if (plotData == nil) {
        NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
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
    
    CPGraph* graph = [[[CPXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPSlateTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
   
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    // Grid line styles
    CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];

    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.1];    

    CPLineStyle *redLineStyle = [CPLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPColor redColor] colorWithAlphaComponent:0.5];

    // Axes
    // Label x axis with a fixed interval policy
    CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"1.0");
    x.minorTicksPerInterval = 2;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;

    x.title = @"X Axis";
    x.titleOffset = 30.0;
    x.titleLocation = CPDecimalFromString(@"1.25");
	
	// Label y with an automatic label policy.
    CPXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPDecimalFromString(@"1.0");
    y.minorTicksPerInterval = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelOffset = 10.0;

    y.title = @"Y Axis";
    y.titleOffset = 30.0;
    y.titleLocation = CPDecimalFromString(@"1.0");

    // Rotate the labels by 45 degrees, just to show it can be done.
    labelRotation = M_PI * 0.25;

    // Add an extra y axis (red)
    // We add constraints to this axis below
    CPXYAxis *y2 = [[(CPXYAxis *)[CPXYAxis alloc] initWithFrame:CGRectZero] autorelease];
    y2.labelingPolicy = CPAxisLabelingPolicyAutomatic;
    y2.orthogonalCoordinateDecimal = CPDecimalFromString(@"3");
    y2.minorTicksPerInterval = 0;
    y2.preferredNumberOfMajorTicks = 4;
    y2.majorGridLineStyle = majorGridLineStyle;
    y2.minorGridLineStyle = minorGridLineStyle;
    y2.labelOffset = 10.0;    
    y2.coordinate = CPCoordinateY;
    y2.plotSpace = graph.defaultPlotSpace;
    y2.axisLineStyle = redLineStyle;
    y2.majorTickLineStyle = redLineStyle;
    y2.minorTickLineStyle = nil;
    y2.labelTextStyle = nil;
    y2.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(2) length:CPDecimalFromInteger(3)];

    // Set axes
    //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];

    // Put an area gradient under the plot above
    //NSString *pathToFillImage = [[NSBundle mainBundle] pathForResource:@"BlueTexture" ofType:@"png"];
    //CPImage *fillImage = [CPImage imageForPNGFile:pathToFillImage];
    //fillImage.tiled = YES;
    //CPFill *areaGradientFill = [CPFill fillWithImage:fillImage];

    // Create a plot that uses the data source method
    CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
    dataSourceLinePlot.dataLineStyle.lineWidth = 3.0;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Put an area gradient under the plot above
    CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
    areaGradient.angle = -90.0;
    CPFill* areaGradientFill = [CPFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"0.0");

    [self generateData];
    
    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:dataSourceLinePlot, nil]];
    CPPlotRange *xRange = plotSpace.xRange;
    CPPlotRange *yRange = plotSpace.yRange;
    [xRange expandRangeByFactor:CPDecimalFromDouble(1.3)];
    [yRange expandRangeByFactor:CPDecimalFromDouble(1.3)];
    plotSpace.yRange = yRange;

    // Restrict y range to a global range
    CPPlotRange *globalYRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f)
                                                            length:CPDecimalFromFloat(2.0f)];
    plotSpace.globalYRange = globalYRange;

    // set the x and y shift to match the new ranges
    CGFloat length = xRange.lengthDouble;
    xShift = length - 3.0;
    length = yRange.lengthDouble;
    yShift = length - 2.0;

    // Position y2 axis relative to the plot area, ie, not moving when dragging
    CPConstraints y2Constraints = {CPConstraintNone, CPConstraintFixed};
    y2.isFloatingAxis = YES;
    y2.constraints = y2Constraints;

    // Add plot symbols
    CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPColor blackColor];
    CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
    plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self; 
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0f;
}

- (void)dealloc
{
    [plotData release];
	[super dealloc];
}

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

#pragma mark Plot Space Delegate Methods

-(CPPlotRange *)plotSpace:(CPPlotSpace *)space willChangePlotRangeTo:(CPPlotRange *)newRange forCoordinate:(CPCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if ( coordinate == CPCoordinateX ) {
        CPPlotRange *maxRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0f) length:CPDecimalFromFloat(6.0f)];
        CPPlotRange *changedRange = [[newRange copy] autorelease];
        [changedRange shiftEndToFitInRange:maxRange];
        [changedRange shiftLocationToFitInRange:maxRange];
        newRange = changedRange;
    }
    return newRange;
}

#pragma mark -
#pragma mark CPScatterPlot delegate method

-(void)scatterPlot:(CPScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPGraph* graph = [graphs objectAtIndex:0];

    if ( symbolTextAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTextStyle *hitAnnotationTextStyle = [CPTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSNumber *x = [[plotData objectAtIndex:index] valueForKey:@"x"];
    NSNumber *y = [[plotData objectAtIndex:index] valueForKey:@"y"];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTextLayer *textLayer = [[[CPTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}

@end
