#import "Controller.h"
#import <CorePlot/CorePlot.h>

@interface Controller()

@property (nonatomic, readwrite, strong, nullable) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, strong, nonnull) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary *> *plotData;
@property (nonatomic, readwrite, strong, nonnull) CPTFill *areaFill;
@property (nonatomic, readwrite, strong, nonnull) CPTLineStyle *barLineStyle;

@end

#pragma mark -

@implementation Controller

@synthesize hostView;
@synthesize graph;
@synthesize plotData;
@synthesize areaFill;
@synthesize barLineStyle;

-(void)awakeFromNib
{
    [super awakeFromNib];

    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *refDate            = [formatter dateFromString:@"12:00 Oct 29, 2009"];
    NSTimeInterval oneDay      = 24 * 60 * 60;

    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];

    self.graph = newGraph;

    self.hostView.hostedGraph = newGraph;

    // Title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];

    textStyle.color            = [CPTColor whiteColor];
    textStyle.fontSize         = 18.0;
    textStyle.fontName         = @"Helvetica";
    newGraph.title             = @"Click to Toggle Range Plot Style";
    newGraph.titleTextStyle    = textStyle;
    newGraph.titleDisplacement = CGPointMake(0.0, -20.0);

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = oneDay * 0.5;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xLow) length:@(oneDay * 5.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0 length:@3.0];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;

    x.majorIntervalLength   = @(oneDay);
    x.orthogonalPosition    = @2.0;
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];

    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;

    CPTXYAxis *y = axisSet.yAxis;

    y.majorIntervalLength   = @0.5;
    y.minorTicksPerInterval = 5;
    y.orthogonalPosition    = @(oneDay);

    // Create a plot that uses the data source method
    CPTRangePlot *dataSourceLinePlot = [[CPTRangePlot alloc] init];

    dataSourceLinePlot.identifier = @"Date Plot";

    // Add line style
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];

    lineStyle.lineWidth             = 1.0;
    lineStyle.lineColor             = [CPTColor greenColor];
    self.barLineStyle               = lineStyle;
    dataSourceLinePlot.barLineStyle = lineStyle;

    // Bar properties
    dataSourceLinePlot.barWidth   = 10.0;
    dataSourceLinePlot.gapWidth   = 20.0;
    dataSourceLinePlot.gapHeight  = 20.0;
    dataSourceLinePlot.dataSource = self;

    // Add plot
    [newGraph addPlot:dataSourceLinePlot];
    newGraph.defaultPlotSpace.delegate = self;

    // Store area fill for use later
    CPTColor *transparentGreen = [[CPTColor greenColor] colorWithAlphaComponent:0.2];

    self.areaFill = [[CPTFill alloc] initWithColor:transparentGreen];

    // Add some data
    NSMutableArray<NSDictionary *> *newData = [NSMutableArray array];

    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSTimeInterval xVal = oneDay * (i + 1.0);

        double yVal   = 3.0 * arc4random() / (double)UINT32_MAX + 1.2;
        double rHigh  = arc4random() / (double)UINT32_MAX * 0.5 + 0.25;
        double rLow   = arc4random() / (double)UINT32_MAX * 0.5 + 0.25;
        double rLeft  = (arc4random() / (double)UINT32_MAX * 0.125 + 0.125) * oneDay;
        double rRight = (arc4random() / (double)UINT32_MAX * 0.125 + 0.125) * oneDay;

        [newData addObject:
         @{ @(CPTRangePlotFieldX): @(xVal),
            @(CPTRangePlotFieldY): @(yVal),
            @(CPTRangePlotFieldHigh): @(rHigh),
            @(CPTRangePlotFieldLow): @(rLow),
            @(CPTRangePlotFieldLeft): @(rLeft),
            @(CPTRangePlotFieldRight): @(rRight) }
        ];
    }
    self.plotData = newData;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *__unused)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *__unused)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return self.plotData[index][@(fieldEnum)];
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *__unused)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint __unused)point
{
    CPTRangePlot *rangePlot = (CPTRangePlot *)[self.graph plotWithIdentifier:@"Date Plot"];

    rangePlot.areaFill     = (rangePlot.areaFill ? nil : self.areaFill);
    rangePlot.barLineStyle = (rangePlot.barLineStyle ? nil : self.barLineStyle);

    return NO;
}

@end
