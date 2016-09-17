//
// RangePlot.m
// CorePlotGallery
//

#import "RangePlot.h"

static const NSTimeInterval oneDay = 24 * 60 * 60;

@interface RangePlot()

@property (nonatomic, readwrite, strong, nullable) CPTGraph *graph;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary *> *plotData;
@property (nonatomic, readwrite, strong, nonnull) CPTFill *areaFill;
@property (nonatomic, readwrite, strong, nonnull) CPTLineStyle *barLineStyle;

@end

@implementation RangePlot

@synthesize graph;
@synthesize plotData;
@synthesize areaFill;
@synthesize barLineStyle;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        graph    = nil;
        plotData = @[];

        self.title   = @"Range Plot";
        self.section = kFinancialPlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        NSMutableArray<NSDictionary *> *newData = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 5; i++ ) {
            NSTimeInterval x = oneDay * (i + 1.0);

            double y      = 3.0 * arc4random() / (double)UINT32_MAX + 1.2;
            double rHigh  = arc4random() / (double)UINT32_MAX * 0.5 + 0.25;
            double rLow   = arc4random() / (double)UINT32_MAX * 0.5 + 0.25;
            double rLeft  = (arc4random() / (double)UINT32_MAX * 0.125 + 0.125) * oneDay;
            double rRight = (arc4random() / (double)UINT32_MAX * 0.125 + 0.125) * oneDay;

            [newData addObject:
             @{ @(CPTRangePlotFieldX): @(x),
                @(CPTRangePlotFieldY): @(y),
                @(CPTRangePlotFieldHigh): @(rHigh),
                @(CPTRangePlotFieldLow): @(rLow),
                @(CPTRangePlotFieldLeft): @(rLeft),
                @(CPTRangePlotFieldRight): @(rRight) }
            ];
        }

        self.plotData = newData;
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    self.graph = newGraph;

    [self addGraph:newGraph toHostingView:hostingView];
    [self applyTheme:theme toGraph:newGraph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    newGraph.plotAreaFrame.masksToBorder = NO;

    // Instructions
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color    = [CPTColor whiteColor];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = self.titleSize * CPTFloat(0.5);

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Touch to Toggle Range Plot Style" style:textStyle];
#else
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Click to Toggle Range Plot Style" style:textStyle];
#endif

    CPTLayer *anchorLayer = newGraph.plotAreaFrame.plotArea;
    if ( anchorLayer ) {
        CPTLayerAnnotation *instructionsAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:anchorLayer];
        instructionsAnnotation.contentLayer       = textLayer;
        instructionsAnnotation.rectAnchor         = CPTRectAnchorBottom;
        instructionsAnnotation.contentAnchorPoint = CGPointMake(0.5, 0.0);
        instructionsAnnotation.displacement       = CGPointMake(0.0, 10.0);
        [newGraph.plotAreaFrame.plotArea addAnnotation:instructionsAnnotation];
    }

    // Setup fill and bar style
    if ( !self.areaFill ) {
        CPTColor *transparentGreen = [[CPTColor greenColor] colorWithAlphaComponent:CPTFloat(0.2)];
        self.areaFill = [[CPTFill alloc] initWithColor:transparentGreen];
    }

    if ( !self.barLineStyle ) {
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 1.0;
        lineStyle.lineColor = [CPTColor greenColor];
        self.barLineStyle   = lineStyle;
    }

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    NSTimeInterval xLow       = oneDay * 0.5;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xLow) length:@(oneDay * 5.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.5 length:@3.5];

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
    CPTRangePlot *rangePlot = [[CPTRangePlot alloc] init];
    rangePlot.identifier   = @"Range Plot";
    rangePlot.barLineStyle = self.barLineStyle;
    rangePlot.dataSource   = self;
    rangePlot.delegate     = self;

    // Bar properties
    rangePlot.barWidth  = 10.0;
    rangePlot.gapWidth  = 20.0;
    rangePlot.gapHeight = 20.0;

    // Add plot
    [newGraph addPlot:rangePlot];
    newGraph.defaultPlotSpace.delegate = self;

    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
    newGraph.legend.textStyle          = x.titleTextStyle;
    newGraph.legend.fill               = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    newGraph.legend.borderLineStyle    = x.axisLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 3.0;
    newGraph.legendAnchor              = CPTRectAnchorTop;
    newGraph.legendDisplacement        = CGPointMake( 0.0, self.titleSize * CPTFloat(-2.0) - CPTFloat(12.0) );
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

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point
{
    CPTRangePlot *rangePlot = (CPTRangePlot *)[self.graph plotWithIdentifier:@"Range Plot"];

    rangePlot.areaFill = (rangePlot.areaFill ? nil : self.areaFill);

    if ( rangePlot.areaFill ) {
        CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
        lineStyle.lineColor = [CPTColor lightGrayColor];

        rangePlot.areaBorderLineStyle = lineStyle;
    }
    else {
        rangePlot.areaBorderLineStyle = nil;
    }

    return NO;
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(void)rangePlot:(nonnull CPTRangePlot *)plot rangeWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Range for '%@' was selected at index %d.", plot.identifier, (int)index);
}

@end
