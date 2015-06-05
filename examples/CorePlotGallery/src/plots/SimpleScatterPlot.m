//
//  SimpleScatterPlot.m
//  CorePlotGallery
//

#import "SimpleScatterPlot.h"

@interface SimpleScatterPlot()

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;
@property (nonatomic, readwrite, strong) NSArray *plotData;
@property (nonatomic, readwrite, assign) CPTScatterPlotHistogramOption histogramOption;

@end

@implementation SimpleScatterPlot

@synthesize symbolTextAnnotation;
@synthesize plotData;
@synthesize histogramOption;

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Simple Scatter Plot";
        self.section = kLinePlots;

        self.histogramOption = CPTScatterPlotHistogramSkipSecond;
    }

    return self;
}

-(void)killGraph
{
    if ( [self.graphs count] ) {
        CPTGraph *graph = (self.graphs)[0];

        CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(void)generateData
{
    if ( self.plotData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 10; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * arc4random() / (double)UINT32_MAX + 0.5);
            [contentArray addObject:@{ @"x": x, @"y": y }
            ];
        }
        self.plotData = contentArray;
    }
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @0.5;
    x.orthogonalPosition    = @1.0;
    x.minorTicksPerInterval = 2;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;

    x.title         = @"X Axis";
    x.titleOffset   = 30.0;
    x.titleLocation = @1.25;

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition          = @1.0;
    y.minorTicksPerInterval       = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.labelOffset                 = 10.0;

    y.title         = @"Y Axis";
    y.titleOffset   = 30.0;
    y.titleLocation = @1.0;

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Data Source Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth                = 3.0;
    lineStyle.lineColor                = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle   = lineStyle;
    dataSourceLinePlot.histogramOption = self.histogramOption;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Auto scale the plot space to fit the plot data
    // Extend the ranges by 30% for neatness
    [plotSpace scaleToFitPlots:@[dataSourceLinePlot]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [xRange expandRangeByFactor:@1.3];
    [yRange expandRangeByFactor:@1.3];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                              length:@2.0];
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
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, 12.0);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.plotData[index][key];

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if ( coordinate == CPTCoordinateX ) {
        CPTPlotRange *maxRange            = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@6.0];
        CPTMutablePlotRange *changedRange = [newRange mutableCopy];
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

    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        annotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSDictionary *dataPoint = self.plotData[index];

    NSNumber *x = dataPoint[@"x"];
    NSNumber *y = dataPoint[@"y"];

    NSArray *anchorPoint = @[x, y];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTPlotSpace *defaultSpace = graph.defaultPlotSpace;
    if ( defaultSpace ) {
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
        annotation                = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
        annotation.contentLayer   = textLayer;
        annotation.displacement   = CGPointMake(0.0, 20.0);
        self.symbolTextAnnotation = annotation;
        [graph.plotAreaFrame.plotArea addAnnotation:annotation];
    }
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
    CPTXYGraph *graph = [self.graphs objectAtIndex:0];

    if ( graph ) {
        // Remove the annotation
        CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
        else {
            CPTScatterPlotInterpolation interpolation = CPTScatterPlotInterpolationHistogram;

            // Decrease the histogram display option, and if < 0 display linear graph
            if ( --self.histogramOption < 0 ) {
                interpolation = CPTScatterPlotInterpolationLinear;

                // Set the histogram option to the count, as that is guaranteed to be the last available option + 1
                // (thus the next time the user clicks in the empty plot area the value will be decremented, becoming last option)
                self.histogramOption = CPTScatterPlotHistogramOptionCount;
            }
            CPTScatterPlot *dataSourceLinePlot = (CPTScatterPlot *)[graph plotWithIdentifier:@"Data Source Plot"];
            dataSourceLinePlot.interpolation   = interpolation;
            dataSourceLinePlot.histogramOption = self.histogramOption;
        }
    }
}

@end
