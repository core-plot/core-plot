//
// DatePlot.m
// Plot Gallery-Mac
//

#import "DatePlot.h"

typedef NSDictionary<NSNumber *, NSNumber *> CPTPlotData;

typedef NSArray<CPTPlotData *>               CPTPlotDataArray;
typedef NSMutableArray<CPTPlotData *>        CPTMutablePlotDataArray;

static const NSUInteger kNumPoints = 10;
static const NSTimeInterval oneDay = 24 * 60 * 60;

@interface DatePlot()

@property (nonatomic, readwrite, strong, nonnull) CPTPlotDataArray *plotData;
@property (nonatomic, readwrite, strong, nullable) CPTPlotSpaceAnnotation *markerAnnotation;

@end

#pragma mark -

@implementation DatePlot

@synthesize plotData;
@synthesize markerAnnotation;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        self.title   = @"Date Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        // Add some data
        CPTMutablePlotDataArray *newData = [NSMutableArray array];

        for ( NSUInteger i = 0; i < kNumPoints; i++ ) {
            NSTimeInterval xVal = oneDay * i;

            double yVal = 1.2 * arc4random() / (double)UINT32_MAX + 1.2;

            [newData addObject:
             @{ @(CPTScatterPlotFieldX): @(xVal),
                @(CPTScatterPlotFieldY): @(yVal) }
            ];

            self.plotData = newData;
        }
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

    dateComponents.month  = 10;
    dateComponents.day    = 29;
    dateComponents.year   = 2009;
    dateComponents.hour   = 12;
    dateComponents.minute = 0;
    dateComponents.second = 0;

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *refDate = [gregorian dateFromComponents:dateComponents];

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft   = 36.0;
    graph.plotAreaFrame.paddingTop    = 12.0;
    graph.plotAreaFrame.paddingRight  = 12.0;
    graph.plotAreaFrame.paddingBottom = 12.0;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    NSTimeInterval xLow = 0.0;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xLow) length:@(oneDay * (kNumPoints - 1))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0 length:@2.0];

    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(oneDay);
    x.orthogonalPosition    = @2.0;
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = CPTFloat(M_PI_4);

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @0.5;
    y.minorTicksPerInterval = 5;
    y.orthogonalPosition    = @(oneDay);

    CPTMutableLineStyle *blueLineStyle = [CPTMutableLineStyle lineStyle];
    blueLineStyle.lineColor = [CPTColor blueColor];
    blueLineStyle.lineWidth = 2.0;

    CPTXYAxis *iAxis = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    iAxis.title          = nil;
    iAxis.labelFormatter = nil;
    iAxis.axisLineStyle  = blueLineStyle;

    iAxis.coordinate         = CPTCoordinateY;
    iAxis.plotSpace          = graph.defaultPlotSpace;
    iAxis.majorTickLineStyle = nil;
    iAxis.minorTickLineStyle = nil;
    iAxis.orthogonalPosition = @0.0;
    iAxis.hidden             = YES;

    graph.axisSet.axes = @[x, y, iAxis];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Date Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor blackColor];
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    hitAnnotationTextStyle.fontSize = self.titleSize * CPTFloat(0.5);

    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Annotation" style:hitAnnotationTextStyle];
    textLayer.borderLineStyle = blueLineStyle;
    textLayer.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    textLayer.cornerRadius    = 3.0;
    textLayer.paddingLeft     = 2.0;
    textLayer.paddingTop      = 2.0;
    textLayer.paddingRight    = 2.0;
    textLayer.paddingBottom   = 2.0;
    textLayer.hidden          = YES;

    CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plotSpace anchorPlotPoint:@[@0, @0]];
    annotation.contentLayer = textLayer;

    [graph addAnnotation:annotation];

    self.markerAnnotation = annotation;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return self.plotData[index][@(fieldEnum)];
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement
{
    return CPTPointMake(0.0, 0.0);
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *updatedRange = nil;

    CPTXYPlotSpace *xySpace = (CPTXYPlotSpace *)space;

    switch ( coordinate ) {
        case CPTCoordinateX:
            updatedRange = xySpace.xRange;
            break;

        case CPTCoordinateY:
            updatedRange = xySpace.yRange;
            break;

        default:
            break;
    }

    return updatedRange;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    CPTXYPlotSpace *xySpace = (CPTXYPlotSpace *)space;

    CPTGraph *graph = space.graph;

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

    CPTAxisArray *axes = axisSet.axes;
    CPTXYAxis *iAxis   = axes.lastObject;

    CPTNumberArray *plotPoint = [space plotPointForEvent:event];

    CPTPlotSpaceAnnotation *annotation = self.markerAnnotation;

    CPTTextLayer *textLayer = (CPTTextLayer *)annotation.contentLayer;

    NSNumber *xNumber = plotPoint[CPTCoordinateX];

    if ( [xySpace.xRange containsNumber:xNumber] ) {
        NSUInteger x = (NSUInteger)lround(xNumber.doubleValue / oneDay);

        xNumber = @(x * oneDay);

        NSString *dateValue = [axisSet.xAxis.labelFormatter stringForObjectValue:xNumber];
        NSNumber *plotValue = self.plotData[x][@(CPTCoordinateY)];

        textLayer.text   = [NSString stringWithFormat:@"%@ → %@", dateValue, [NSString stringWithFormat:@"%1.3f", plotValue.doubleValue]];
        textLayer.hidden = NO;

        annotation.anchorPlotPoint = @[xNumber, xySpace.yRange.maxLimit];

        iAxis.orthogonalPosition = xNumber;
        iAxis.hidden             = NO;
    }
    else {
        textLayer.hidden = YES;
        iAxis.hidden     = YES;
    }

    return NO;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    return [self plotSpace:space shouldHandlePointingDeviceDownEvent:event atPoint:point];
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    return NO;
}

@end
