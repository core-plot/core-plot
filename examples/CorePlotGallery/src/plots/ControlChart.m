#import "ControlChart.h"

static NSString *const kDataLine    = @"Data Line";
static NSString *const kCenterLine  = @"Center Line";
static NSString *const kControlLine = @"Control Line";
static NSString *const kWarningLine = @"Warning Line";

static const NSUInteger numberOfPoints = 11;

@interface ControlChart()

@property (nonatomic, readwrite, strong, nonnull) CPTNumberArray *plotData;
@property (nonatomic, readwrite, assign) double meanValue;
@property (nonatomic, readwrite, assign) double standardError;

@end

@implementation ControlChart

@synthesize plotData;
@synthesize meanValue;
@synthesize standardError;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Control Chart";
        self.section = kLinePlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        CPTMutableNumberArray *contentArray = [NSMutableArray array];

        double sum = 0.0;

        for ( NSUInteger i = 0; i < numberOfPoints; i++ ) {
            double y = 12.0 * arc4random() / (double)UINT32_MAX + 5.0;
            sum += y;
            [contentArray addObject:@(y)];
        }

        self.plotData = contentArray;

        self.meanValue = sum / numberOfPoints;

        sum = 0.0;
        for ( NSNumber *value in contentArray ) {
            double error = value.doubleValue - self.meanValue;
            sum += error * error;
        }
        double stdDev = sqrt( ( 1.0 / (numberOfPoints - 1) ) * sum);
        self.standardError = stdDev / sqrt(numberOfPoints);
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

    graph.plotAreaFrame.paddingTop    = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(1.5);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(1.5);
    graph.plotAreaFrame.masksToBorder = NO;

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

    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.maximumFractionDigits = 0;

    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy     = CPTAxisLabelingPolicyAutomatic;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    x.labelFormatter     = labelFormatter;

    x.title       = @"X Axis";
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy     = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelFormatter     = labelFormatter;

    y.title       = @"Y Axis";
    y.titleOffset = self.titleSize * CPTFloat(1.25);

    // Center line
    CPTScatterPlot *centerLinePlot = [[CPTScatterPlot alloc] init];
    centerLinePlot.identifier = kCenterLine;

    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth          = 2.0;
    lineStyle.lineColor          = [CPTColor greenColor];
    centerLinePlot.dataLineStyle = lineStyle;

    centerLinePlot.dataSource = self;
    [graph addPlot:centerLinePlot];

    // Control lines
    CPTScatterPlot *controlLinePlot = [[CPTScatterPlot alloc] init];
    controlLinePlot.identifier = kControlLine;

    lineStyle                     = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth           = 2.0;
    lineStyle.lineColor           = [CPTColor redColor];
    lineStyle.dashPattern         = @[@10, @6];
    controlLinePlot.dataLineStyle = lineStyle;

    controlLinePlot.dataSource = self;
    [graph addPlot:controlLinePlot];

    // Warning lines
    CPTScatterPlot *warningLinePlot = [[CPTScatterPlot alloc] init];
    warningLinePlot.identifier = kWarningLine;

    lineStyle                     = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth           = 1.0;
    lineStyle.lineColor           = [CPTColor orangeColor];
    lineStyle.dashPattern         = @[@5, @5];
    warningLinePlot.dataLineStyle = lineStyle;

    warningLinePlot.dataSource = self;
    [graph addPlot:warningLinePlot];

    // Data line
    CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] init];
    linePlot.identifier = kDataLine;

    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth    = 3.0;
    linePlot.dataLineStyle = lineStyle;

    linePlot.dataSource = self;
    [graph addPlot:linePlot];

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill      = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size      = CGSizeMake(10.0, 10.0);
    linePlot.plotSymbol  = plotSymbol;

    // Auto scale the plot space to fit the plot data
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:@[linePlot]];

    // Adjust visible ranges so plot symbols along the edges are not clipped
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

    x.orthogonalPosition = yRange.location;
    y.orthogonalPosition = xRange.location;

    x.visibleRange = xRange;
    y.visibleRange = yRange;

    x.gridLinesRange = yRange;
    y.gridLinesRange = xRange;

    [xRange expandRangeByFactor:@1.05];
    [yRange expandRangeByFactor:@1.05];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    // Add legend
    graph.legend                 = [CPTLegend legendWithPlots:@[linePlot, controlLinePlot, warningLinePlot, centerLinePlot]];
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legend.numberOfRows    = 1;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * CPTFloat(4.0) );
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    if ( plot.identifier == kDataLine ) {
        return self.plotData.count;
    }
    else if ( plot.identifier == kCenterLine ) {
        return 2;
    }
    else {
        return 5;
    }
}

-(double)doubleForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    double number = (double)NAN;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            if ( plot.identifier == kDataLine ) {
                number = (double)index;
            }
            else {
                switch ( index % 3 ) {
                    case 0:
                        number = 0.0;
                        break;

                    case 1:
                        number = (double)(self.plotData.count - 1);
                        break;

                    case 2:
                        number = (double)NAN;
                        break;
                }
            }

            break;

        case CPTScatterPlotFieldY:
            if ( plot.identifier == kDataLine ) {
                number = self.plotData[index].doubleValue;
            }
            else if ( plot.identifier == kCenterLine ) {
                number = self.meanValue;
            }
            else if ( plot.identifier == kControlLine ) {
                switch ( index ) {
                    case 0:
                    case 1:
                        number = self.meanValue + 3.0 * self.standardError;
                        break;

                    case 2:
                        number = (double)NAN;
                        break;

                    case 3:
                    case 4:
                        number = self.meanValue - 3.0 * self.standardError;
                        break;
                }
            }
            else if ( plot.identifier == kWarningLine ) {
                switch ( index ) {
                    case 0:
                    case 1:
                        number = self.meanValue + 2.0 * self.standardError;
                        break;

                    case 2:
                        number = (double)NAN;
                        break;

                    case 3:
                    case 4:
                        number = self.meanValue - 2.0 * self.standardError;
                        break;
                }
            }

            break;
    }

    return number;
}

@end
