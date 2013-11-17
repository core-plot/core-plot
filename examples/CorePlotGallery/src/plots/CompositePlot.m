//
//  CompositePlot.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "CompositePlot.h"

@implementation CompositePlot

@synthesize dataForChart;
@synthesize dataForPlot;

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Composite Plot";
        self.section = kDemoPlots;
    }

    return self;
}

#pragma mark -
#pragma mark Plot construction methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(void)setFrameSize:(NSSize)newSize
{
    scatterPlotView.frame = NSMakeRect(0.0,
                                       0.0,
                                       newSize.width,
                                       newSize.height * 0.5);

    barChartView.frame = NSMakeRect(0.0,
                                    newSize.height * 0.5,
                                    newSize.width * 0.5,
                                    newSize.height * 0.5);

    pieChartView.frame = NSMakeRect(newSize.width * 0.5,
                                    newSize.height * 0.5,
                                    newSize.width * 0.5,
                                    newSize.height * 0.5);

    [scatterPlotView needsDisplay];
    [barChartView needsDisplay];
    [pieChartView needsDisplay];
}
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#endif
{
    [self killGraph];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect viewRect = [hostingView bounds];

    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0.0,
                                                                            0.0,
                                                                            viewRect.size.width,
                                                                            viewRect.size.height * 0.5)];

    barChartView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0.0,
                                                                         viewRect.size.height * 0.5,
                                                                         viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5)];

    pieChartView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5,
                                                                         viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5)];
#else
    NSRect viewRect = [hostingView bounds];

    scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect(0.0,
                                                                            0.0,
                                                                            viewRect.size.width,
                                                                            viewRect.size.height * 0.5)];

    barChartView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect(0.0,
                                                                         viewRect.size.height * 0.5,
                                                                         viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5)];

    pieChartView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect(viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5,
                                                                         viewRect.size.width * 0.5,
                                                                         viewRect.size.height * 0.5)];

    [scatterPlotView setAutoresizesSubviews:YES];
    [scatterPlotView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [barChartView setAutoresizesSubviews:YES];
    [barChartView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [pieChartView setAutoresizesSubviews:YES];
    [pieChartView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif

    [hostingView addSubview:scatterPlotView];
    [hostingView addSubview:barChartView];
    [hostingView addSubview:pieChartView];

    [self renderScatterPlotInLayer:scatterPlotView withTheme:theme];
    [self renderBarPlotInLayer:barChartView withTheme:theme];
    [self renderPieChartInLayer:pieChartView withTheme:theme];
}

-(void)killGraph
{
    scatterPlotView.hostedGraph = nil;
    barChartView.hostedGraph    = nil;
    pieChartView.hostedGraph    = nil;

    [scatterPlotView removeFromSuperview];
    [barChartView removeFromSuperview];
    [pieChartView removeFromSuperview];

    [scatterPlotView release];
    [barChartView release];
    [pieChartView release];

    scatterPlotView = nil;
    barChartView    = nil;
    pieChartView    = nil;

    [super killGraph];
}

-(void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
    // Create graph from theme
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGRect bounds = scatterPlotView.bounds;
#else
    CGRect bounds = NSRectToCGRect(scatterPlotView.bounds);
#endif

    scatterPlot = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:scatterPlot toHostingView:layerHostingView];

    [self applyTheme:theme toGraph:scatterPlot withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    scatterPlot.paddingLeft   = 10.0;
    scatterPlot.paddingTop    = 10.0;
    scatterPlot.paddingRight  = 10.0;
    scatterPlot.paddingBottom = 10.0;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)scatterPlot.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(2.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(3.0)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)scatterPlot.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    x.minorTicksPerInterval       = 2;
    NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(2.99) length:CPTDecimalFromFloat(0.02)],
                                nil];
    x.labelExclusionRanges = exclusionRanges;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    exclusionRanges               = [NSArray arrayWithObjects:
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(3.99) length:CPTDecimalFromFloat(0.02)],
                                     nil];
    y.labelExclusionRanges = exclusionRanges;

    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Blue Plot";

    CPTMutableLineStyle *lineStyle = [[boundLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 3.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource    = self;
    [scatterPlot addPlot:boundLinePlot];

    // Do a blue gradient
    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill      = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;

    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Green Plot";

    lineStyle             = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth   = 3.0;
    lineStyle.lineColor   = [CPTColor greenColor];
    lineStyle.dashPattern = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:5.0f],
                             [NSNumber numberWithFloat:5.0f],
                             nil];

    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource    = self;

    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle               = -90.0;
    areaGradientFill                 = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);

    // Animate in the new plot, as an example
    dataSourceLinePlot.opacity = 1.0;
    [scatterPlot addPlot:dataSourceLinePlot];

    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    NSUInteger i;
    for ( i = 0; i < 60; i++ ) {
        NSNumber *x = [NSNumber numberWithFloat:1 + i * 0.05];
        NSNumber *y = [NSNumber numberWithFloat:1.2 * rand() / (float)RAND_MAX + 1.2];
        [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    self.dataForPlot = contentArray;
}

-(void)renderBarPlotInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    BOOL drawAxis = YES;
    if ( bounds.size.width < 200.0 ) {
        drawAxis = NO;
    }

    barChart = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:barChart toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:barChart withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    barChart.plotAreaFrame.masksToBorder = NO;

    if ( drawAxis ) {
        barChart.paddingLeft   = 70.0;
        barChart.paddingTop    = 20.0;
        barChart.paddingRight  = 20.0;
        barChart.paddingBottom = 80.0;
    }
    else {
        [self setPaddingDefaultsForGraph:barChart withBounds:bounds];
    }

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(17.0f)];

    if ( drawAxis ) {
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
        CPTXYAxis *x          = axisSet.xAxis;
        x.axisLineStyle               = nil;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.majorIntervalLength         = CPTDecimalFromDouble(5.0);
        x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
        x.title                       = @"X Axis";
        x.titleLocation               = CPTDecimalFromFloat(7.5f);
        x.titleOffset                 = 55.0;

        // Define some custom labels for the data elements
        x.labelRotation  = M_PI_4;
        x.labelingPolicy = CPTAxisLabelingPolicyNone;
        NSArray *customTickLocations = [NSArray arrayWithObjects:
                                        [NSDecimalNumber numberWithInt:1],
                                        [NSDecimalNumber numberWithInt:5],
                                        [NSDecimalNumber numberWithInt:10],
                                        [NSDecimalNumber numberWithInt:15],
                                        nil];
        NSArray *xAxisLabels       = [NSArray arrayWithObjects:@"Label A", @"Label B", @"Label C", @"Label D", nil];
        NSUInteger labelLocation   = 0;
        NSMutableSet *customLabels = [NSMutableSet setWithCapacity:[xAxisLabels count]];
        for ( NSNumber *tickLocation in customTickLocations ) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
            newLabel.tickLocation = [tickLocation decimalValue];
            newLabel.offset       = x.labelOffset + x.majorTickLength;
            newLabel.rotation     = M_PI_4;
            [customLabels addObject:newLabel];
            [newLabel release];
        }

        x.axisLabels = customLabels;

        CPTXYAxis *y = axisSet.yAxis;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
        y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
        y.title                       = @"Y Axis";
        y.titleOffset                 = 45.0;
        y.titleLocation               = CPTDecimalFromFloat(150.0f);
    }

    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];

    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.barOffset       = CPTDecimalFromFloat(0.25f); // 25% offset, 75% overlap
    barPlot.barCornerRadius = 2.0;
    barPlot.identifier      = @"Bar Plot 2";
    barPlot.delegate        = self;
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
}

-(void)renderPieChartInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    pieChart = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:pieChart toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:pieChart withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    pieChart.plotAreaFrame.masksToBorder = NO;

    [self setPaddingDefaultsForGraph:pieChart withBounds:bounds];

    pieChart.axisSet = nil;

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.7 * (layerHostingView.frame.size.height - 2 * pieChart.paddingLeft) / 2.0,
                             0.7 * (layerHostingView.frame.size.width - 2 * pieChart.paddingTop) / 2.0);
    piePlot.identifier      = @"Pie Chart 1";
    piePlot.startAngle      = M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    //piePlot.sliceLabelOffset = 5.0;
    [pieChart addPlot:piePlot];
    [piePlot release];

    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithDouble:20.0],
                                    [NSNumber numberWithDouble:30.0],
                                    [NSNumber numberWithDouble:60.0],
                                    nil];
    self.dataForChart = contentArray;
}

#pragma mark -
#pragma mark CPTBarPlot delegate method

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"barWasSelectedAtRecordIndex %d", (int)index);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        return [self.dataForChart count];
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        return 16;
    }
    else {
        return [dataForPlot count];
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;

    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        if ( index >= [self.dataForChart count] ) {
            return nil;
        }

        if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
            return [self.dataForChart objectAtIndex:index];
        }
        else {
            return [NSNumber numberWithInt:index];
        }
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;

            case CPTBarPlotFieldBarTip:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:(index + 1) * (index + 1)];
                if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
                    num = [num decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
                }
                break;
        }
    }
    else {
        NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
        num = [[dataForPlot objectAtIndex:index] valueForKey:key];

        // Green plot gets shifted above the blue
        if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
            if ( fieldEnum == CPTScatterPlotFieldY ) {
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[num doubleValue] + 1.0];
            }
        }
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;

    if ( !whiteText ) {
        whiteText       = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    }

    CPTTextLayer *newLayer = nil;

    switch ( index ) {
        case 0:
            newLayer = (id)[NSNull null];
            break;

        case 1:
            newLayer = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                     style:[CPTTextStyle textStyle]] autorelease];
            break;

        default:
            newLayer = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                     style:whiteText] autorelease];
            break;
    }

    return newLayer;
}

-(void)dealloc
{
    [dataForChart release];
    [dataForPlot release];

    [super dealloc];
}

#if TARGET_OS_IPHONE
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ) {
        // Move the plots into place for portrait
        scatterPlotView.frame = CGRectMake(20.0, 55.0, 728.0, 556.0);
        barChartView.frame    = CGRectMake(20.0, 644.0, 340.0, 340.0);
        pieChartView.frame    = CGRectMake(408.0, 644.0, 340.0, 340.0);
    }
    else {
        // Move the plots into place for landscape
        scatterPlotView.frame = CGRectMake(20.0, 51.0, 628.0, 677.0);
        barChartView.frame    = CGRectMake(684.0, 51.0, 320.0, 320.0);
        pieChartView.frame    = CGRectMake(684.0, 408.0, 320.0, 320.0);
    }
}
#endif

@end
