#import "Controller.h"
#import <CorePlot/CorePlot.h>

@implementation Controller

-(void)dealloc
{
    [plotData release];
    [graph release];
    [areaFill release];
    [barLineStyle release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *refDate            = [formatter dateFromString:@"12:00 Oct 29, 2009"];
    [formatter release];
    NSTimeInterval oneDay = 24 * 60 * 60;

    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    hostView.hostedGraph = graph;

    // Title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color         = [CPTColor whiteColor];
    textStyle.fontSize      = 18.0;
    textStyle.fontName      = @"Helvetica";
    graph.title             = @"Click to Toggle Range Plot Style";
    graph.titleTextStyle    = textStyle;
    graph.titleDisplacement = CGPointMake(0.0, -20.0);

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow       = oneDay * 0.5;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 5.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(3.0)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);

    // Create a plot that uses the data source method
    CPTRangePlot *dataSourceLinePlot = [[[CPTRangePlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";

    // Add line style
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth             = 1.0;
    lineStyle.lineColor             = [CPTColor greenColor];
    barLineStyle                    = [lineStyle retain];
    dataSourceLinePlot.barLineStyle = barLineStyle;

    // Bar properties
    dataSourceLinePlot.barWidth   = 10.0;
    dataSourceLinePlot.gapWidth   = 20.0;
    dataSourceLinePlot.gapHeight  = 20.0;
    dataSourceLinePlot.dataSource = self;

    // Add plot
    [graph addPlot:dataSourceLinePlot];
    graph.defaultPlotSpace.delegate = self;

    // Store area fill for use later
    CPTColor *transparentGreen = [[CPTColor greenColor] colorWithAlphaComponent:0.2];
    areaFill = [[CPTFill alloc] initWithColor:(id)transparentGreen];

    // Add some data
    NSMutableArray *newData = [NSMutableArray array];
    for ( NSUInteger i = 0; i < 5; i++ ) {
        NSTimeInterval x = oneDay * (i + 1.0);
        double y         = 3.0 * rand() / (double)RAND_MAX + 1.2;
        double rHigh     = rand() / (double)RAND_MAX * 0.5 + 0.25;
        double rLow      = rand() / (double)RAND_MAX * 0.5 + 0.25;
        double rLeft     = (rand() / (double)RAND_MAX * 0.125 + 0.125) * oneDay;
        double rRight    = (rand() / (double)RAND_MAX * 0.125 + 0.125) * oneDay;

        [newData addObject:
         @{ @(CPTRangePlotFieldX): @(x),
            @(CPTRangePlotFieldY): @(y),
            @(CPTRangePlotFieldHigh): @(rHigh),
            @(CPTRangePlotFieldLow): @(rLow),
            @(CPTRangePlotFieldLeft): @(rLeft),
            @(CPTRangePlotFieldRight): @(rRight) }
        ];
    }
    plotData = newData;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return plotData[index][@(fieldEnum)];
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point
{
    CPTRangePlot *rangePlot = (CPTRangePlot *)[graph plotWithIdentifier:@"Date Plot"];

    rangePlot.areaFill     = (rangePlot.areaFill ? nil : areaFill);
    rangePlot.barLineStyle = (rangePlot.barLineStyle ? nil : barLineStyle);

    return NO;
}

@end
