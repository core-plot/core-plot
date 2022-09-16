//
// CurvedScatterPlot.m
// Plot_Gallery_iOS
//
// Created by Nino Ag on 23/10/11.

#import "CurvedScatterPlot.h"

static NSString *const kData   = @"Data Source Plot";
static NSString *const kFirst  = @"First Derivative";
static NSString *const kSecond = @"Second Derivative";

@interface CurvedScatterPlot()

@property (nonatomic, readwrite, strong, nullable) CPTPlotSpaceAnnotation *symbolTextAnnotation;

@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData1;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData2;

@end

@implementation CurvedScatterPlot

@synthesize symbolTextAnnotation;
@synthesize plotData;
@synthesize plotData1;
@synthesize plotData2;

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        self.title   = @"Curved Scatter Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    if ( self.graphs.count ) {
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
    if ( self.plotData.count == 0 ) {
        NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *contentArray = [NSMutableArray array];

        for ( NSUInteger i = 0; i < 11; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * arc4random() / (double)UINT32_MAX + 0.5);
            [contentArray addObject:
             @{ @"x": x,
                @"y": y }
            ];
        }

        self.plotData = contentArray;
    }

    if ( self.plotData1 == nil ) {
        NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *contentArray = [NSMutableArray array];

        NSArray<NSDictionary<NSString *, NSNumber *> *> *dataArray = self.plotData;

        for ( NSUInteger i = 1; i < dataArray.count; i++ ) {
            NSDictionary<NSString *, NSNumber *> *point1 = dataArray[i - 1];
            NSDictionary<NSString *, NSNumber *> *point2 = dataArray[i];

            double x1   = point1[@"x"].doubleValue;
            double x2   = point2[@"x"].doubleValue;
            double dx   = x2 - x1;
            double xLoc = (x1 + x2) * 0.5;

            double y1 = point1[@"y"].doubleValue;
            double y2 = point2[@"y"].doubleValue;
            double dy = y2 - y1;

            [contentArray addObject:
             @{ @"x": @(xLoc),
                @"y": @((dy / dx) / 20.0) }
            ];
        }

        self.plotData1 = contentArray;
    }

    if ( self.plotData2 == nil ) {
        NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *contentArray = [NSMutableArray array];

        NSArray<NSDictionary<NSString *, NSNumber *> *> *dataArray = self.plotData1;

        for ( NSUInteger i = 1; i < dataArray.count; i++ ) {
            NSDictionary<NSString *, NSNumber *> *point1 = dataArray[i - 1];
            NSDictionary<NSString *, NSNumber *> *point2 = dataArray[i];

            double x1   = point1[@"x"].doubleValue;
            double x2   = point2[@"x"].doubleValue;
            double dx   = x2 - x1;
            double xLoc = (x1 + x2) * 0.5;

            double y1 = point1[@"y"].doubleValue;
            double y2 = point2[@"y"].doubleValue;
            double dy = y2 - y1;

            [contentArray addObject:
             @{ @"x": @(xLoc),
                @"y": @((dy / dx) / 20.0) }
            ];
        }

        self.plotData2 = contentArray;
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL __unused)animated
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft   += self.titleSize * CPTFloat(2.25);
    graph.plotAreaFrame.paddingTop    += self.titleSize;
    graph.plotAreaFrame.paddingRight  += self.titleSize;
    graph.plotAreaFrame.paddingBottom += self.titleSize;
    graph.plotAreaFrame.masksToBorder  = NO;

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

    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake(self.titleSize * CPTFloat(0.625), self.titleSize * CPTFloat(0.625));

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @0.1;
    x.minorTicksPerInterval = 4;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];

    lineCap.lineStyle = x.axisLineStyle;
    CPTColor *lineColor = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    x.axisLineCapMax = lineCap;

    x.title       = @"X Axis";
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 4;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.alternatingBandAnchor       = @0.0;

    lineCap.lineStyle = y.axisLineStyle;
    lineColor         = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    y.axisLineCapMax = lineCap;
    y.axisLineCapMin = lineCap;

    y.title       = @"Y Axis";
    y.titleOffset = self.titleSize * CPTFloat(1.25);

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = kData;

    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // First derivative
    CPTScatterPlot *firstPlot = [[CPTScatterPlot alloc] init];
    firstPlot.identifier    = kFirst;
    lineStyle.lineWidth     = 2.0;
    lineStyle.lineColor     = [CPTColor redColor];
    firstPlot.dataLineStyle = lineStyle;
    firstPlot.dataSource    = self;

// [graph addPlot:firstPlot];

    // Second derivative
    CPTScatterPlot *secondPlot = [[CPTScatterPlot alloc] init];
    secondPlot.identifier    = kSecond;
    lineStyle.lineColor      = [CPTColor blueColor];
    secondPlot.dataLineStyle = lineStyle;
    secondPlot.dataSource    = self;

// [graph addPlot:secondPlot];

    // Auto scale the plot space to fit the plot data
    [plotSpace scaleToFitEntirePlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

    // Expand the ranges to put some space around the plot
    [xRange expandRangeByFactor:@1.025];
    xRange.location = plotSpace.xRange.location;
    [yRange expandRangeByFactor:@1.05];
    x.visibleAxisRange = xRange;
    y.visibleAxisRange = yRange;

    [xRange expandRangeByFactor:@3.0];
    [yRange expandRangeByFactor:@3.0];
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;

    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, self.titleSize * CPTFloat(2.0));
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:kData] ) {
        numRecords = self.plotData.count;
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        numRecords = self.plotData1.count;
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        numRecords = self.plotData2.count;
    }

    return numRecords;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:kData] ) {
        num = self.plotData[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        num = self.plotData1[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        num = self.plotData2[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(nullable CPTPlotRange *)plotSpace:(nonnull CPTPlotSpace *)space willChangePlotRangeTo:(nonnull CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;

    CPTMutablePlotRange *changedRange = [newRange mutableCopy];

    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:@1.025];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;

        case CPTCoordinateY:
            [changedRange expandRangeByFactor:@1.05];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;

        default:
            break;
    }

    return newRange;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(nonnull CPTScatterPlot *__unused)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *graph = (self.graphs)[0];

    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];

    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSDictionary<NSString *, NSNumber *> *dataPoint = self.plotData[index];

    NSNumber *x = dataPoint[@"x"];
    NSNumber *y = dataPoint[@"y"];

    CPTNumberArray *anchorPoint = @[x, y];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    formatter.maximumFractionDigits = 2;
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    CPTImage *background    = [CPTImage imageNamed:@"BlueBackground"];

    background.edgeInsets   = CPTEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    textLayer.fill          = [CPTFill fillWithImage:background];
    textLayer.paddingLeft   = 2.0;
    textLayer.paddingTop    = 2.0;
    textLayer.paddingRight  = 2.0;
    textLayer.paddingBottom = 2.0;

    CPTPlotSpace *defaultSpace = graph.defaultPlotSpace;

    if ( defaultSpace ) {
        annotation                    = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
        annotation.contentLayer       = textLayer;
        annotation.contentAnchorPoint = CGPointMake(0.5, 0.0);
        annotation.displacement       = CGPointMake(0.0, 10.0);
        [graph.plotAreaFrame.plotArea addAnnotation:annotation];

        self.symbolTextAnnotation = annotation;
    }
}

-(void)scatterPlotDataLineWasSelected:(nonnull CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
}

-(void)scatterPlotDataLineTouchDown:(nonnull CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchDown: %@", plot);
}

-(void)scatterPlotDataLineTouchUp:(nonnull CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchUp: %@", plot);
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(nonnull CPTPlotArea *__unused)plotArea
{
    // Remove the annotation
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        CPTXYGraph *graph = (self.graphs)[0];

        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
}

@end
