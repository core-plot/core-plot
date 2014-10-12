#import "Controller.h"
#import <CorePlot/CorePlot.h>

@interface Controller()

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) NSArray *plotData;

@end

#pragma mark -

@implementation Controller

@synthesize hostView;
@synthesize graph;
@synthesize plotData;

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

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xLow) length:@(oneDay * 3.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0 length:@3.0];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(oneDay);
    x.orthogonalPosition    = @2.0;
    x.minorTicksPerInterval = 3;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *myDateFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    myDateFormatter.referenceDate = refDate;
    x.labelFormatter              = myDateFormatter;

    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.timeStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *myTimeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:timeFormatter];
    myTimeFormatter.referenceDate = refDate;
    x.minorTickLabelFormatter     = myTimeFormatter;
//	x.minorTickLabelRotation = M_PI_2;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @0.5;
    y.minorTicksPerInterval = 5;
    y.orthogonalPosition    = @(0.5 * oneDay);

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];

    // Add some data
    NSMutableArray *newData = [NSMutableArray array];
    for ( NSUInteger i = 0; i < 7; i++ ) {
        NSTimeInterval xVal = oneDay * i * 0.5;

        double yVal = 1.2 * arc4random() / (double)UINT32_MAX + 1.2;

        [newData addObject:
         @{ @(CPTScatterPlotFieldX): @(xVal),
            @(CPTScatterPlotFieldY): @(yVal) }
        ];
    }
    self.plotData = newData;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return self.plotData[index][@(fieldEnum)];
}

@end
