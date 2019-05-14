//
// RealTimePlot.m
// CorePlotGallery
//

#import "RealTimePlot.h"

static const double kFrameRate = 5.0;  // frames per second
static const double kAlpha     = 0.25; // smoothing constant

static const NSUInteger kMaxDataPoints = 52;
static NSString *const kPlotIdentifier = @"Data Source Plot";

@interface RealTimePlot()

@property (nonatomic, readwrite, strong, nonnull) CPTMutableNumberArray *plotData;
@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong, nullable) NSTimer *dataTimer;

@end

@implementation RealTimePlot

@synthesize plotData;
@synthesize currentIndex;
@synthesize dataTimer;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        plotData  = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
        dataTimer = nil;

        self.title   = @"Real Time Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    [self.dataTimer invalidate];
    self.dataTimer = nil;

    [super killGraph];
}

-(void)generateData
{
    [self.plotData removeAllObjects];
    self.currentIndex = 0;
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
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingTop    = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(2.625);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(2.5);
    graph.plotAreaFrame.masksToBorder = NO;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalPosition    = @0.0;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.minorTicksPerInterval = 9;
    x.labelOffset           = self.titleSize * CPTFloat(0.25);
    x.title                 = @"X Axis";
    x.titleOffset           = self.titleSize * CPTFloat(1.5);

    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;

    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition    = @0.0;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.minorTicksPerInterval = 3;
    y.labelOffset           = self.titleSize * CPTFloat(0.25);
    y.title                 = @"Y Axis";
    y.titleOffset           = self.titleSize * CPTFloat(1.25);
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];

    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = CPTFloat(M_PI_4);

    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(kMaxDataPoints - 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@1.0];

    [self.dataTimer invalidate];

    if ( animated ) {
        NSTimer *newTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                                    target:self
                                                  selector:@selector(newData:)
                                                  userInfo:nil
                                                   repeats:YES];
        self.dataTimer = newTimer;
        [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
    }
    else {
        self.dataTimer = nil;
    }
}

-(void)dealloc
{
    [dataTimer invalidate];
}

#pragma mark -
#pragma mark Timer callback

-(void)newData:(nonnull NSTimer *)theTimer
{
    CPTGraph *theGraph = (self.graphs)[0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];

    if ( thePlot ) {
        if ( self.plotData.count >= kMaxDataPoints ) {
            [self.plotData removeObjectAtIndex:0];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
        }

        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        NSUInteger location       = (self.currentIndex >= kMaxDataPoints ? self.currentIndex - kMaxDataPoints + 2 : 0);

        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:@( (location > 0) ? (location - 1) : 0)
                                                              length:@(kMaxDataPoints - 2)];
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:@(location)
                                                              length:@(kMaxDataPoints - 2)];

        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:oldRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / kFrameRate)];

        self.currentIndex++;
        [self.plotData addObject:@( (1.0 - kAlpha) * self.plotData.lastObject.doubleValue + kAlpha * arc4random() / (double)UINT32_MAX)];
        [thePlot insertDataAtIndex:self.plotData.count - 1 numberOfRecords:1];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index + self.currentIndex - self.plotData.count);
            break;

        case CPTScatterPlotFieldY:
            num = self.plotData[index];
            break;

        default:
            break;
    }

    return num;
}

@end
