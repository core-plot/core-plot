//
//  RealTimePlot.m
//  CorePlotGallery
//

#import "RealTimePlot.h"

const double kFrameRate         = 5.0;  // frames per second
const double kAlpha             = 0.25; // smoothing constant
const NSUInteger kMaxDataPoints = 51;
NSString *kPlotIdentifier       = @"Data Source Plot";

@implementation RealTimePlot

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
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
    [dataTimer invalidate];
    [dataTimer release];
    dataTimer = nil;

    [super killGraph];
}

-(void)generateData
{
    [plotData removeAllObjects];
    currentIndex = 0;
    [dataTimer release];
    dataTimer = [[NSTimer timerWithTimeInterval:1.0 / kFrameRate
                                         target:self
                                       selector:@selector(newData:)
                                       userInfo:nil
                                        repeats:YES] retain];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSDefaultRunLoopMode];
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

    graph.plotAreaFrame.paddingTop    = 15.0;
    graph.plotAreaFrame.paddingRight  = 15.0;
    graph.plotAreaFrame.paddingBottom = 55.0;
    graph.plotAreaFrame.paddingLeft   = 55.0;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];

    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    x.minorTicksPerInterval       = 9;
    x.title                       = @"X Axis";
    x.titleOffset                 = 35.0;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    [labelFormatter release];

    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.minorTicksPerInterval       = 3;
    y.labelOffset                 = 5.0;
    y.title                       = @"Y Axis";
    y.titleOffset                 = 30.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];

    // Rotate the labels by 45 degrees, just to show it can be done.
    x.labelRotation = M_PI * 0.25;

    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 1)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(1)];
}

-(void)dealloc
{
    [plotData release];
    [dataTimer invalidate];
    [dataTimer release];

    [super dealloc];
}

#pragma mark -
#pragma mark Timer callback

-(void)newData:(NSTimer *)theTimer
{
    CPTGraph *theGraph = [self.graphs objectAtIndex:0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];

    if ( thePlot ) {
        if ( plotData.count >= kMaxDataPoints ) {
            [plotData removeObjectAtIndex:0];
            [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
        }

        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        NSUInteger location       = (currentIndex >= kMaxDataPoints ? currentIndex - kMaxDataPoints + 1 : 0);
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                        length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 1)];

        currentIndex++;
        [plotData addObject:[NSNumber numberWithDouble:(1.0 - kAlpha) * [[plotData lastObject] doubleValue] + kAlpha * rand() / (double)RAND_MAX]];
        [thePlot insertDataAtIndex:plotData.count - 1 numberOfRecords:1];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = [NSNumber numberWithUnsignedInteger:index + currentIndex - plotData.count];
            break;

        case CPTScatterPlotFieldY:
            num = [plotData objectAtIndex:index];
            break;

        default:
            break;
    }

    return num;
}

@end
