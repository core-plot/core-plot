//
//  CandlestickPlot.m
//  CorePlotGallery
//

#import "CandlestickPlot.h"

static const NSTimeInterval oneDay = 24 * 60 * 60;

@interface CandlestickPlot()

@property (nonatomic, readwrite, strong) CPTGraph *graph;
@property (nonatomic, readwrite, strong) NSArray *plotData;

@end

@implementation CandlestickPlot

@synthesize graph;
@synthesize plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(instancetype)init
{
    if ( (self = [super init]) ) {
        graph    = nil;
        plotData = nil;

        self.title   = @"Candlestick Plot";
        self.section = kFinancialPlots;
    }

    return self;
}

-(void)generateData
{
    if ( !self.plotData ) {
        NSMutableArray *newData = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 8; i++ ) {
            NSTimeInterval x = oneDay * i;

            double rOpen  = 3.0 * arc4random() / (double)UINT32_MAX + 1.0;
            double rClose = (arc4random() / (double)UINT32_MAX - 0.5) * 0.125 + rOpen;
            double rHigh  = MAX( rOpen, MAX(rClose, (arc4random() / (double)UINT32_MAX - 0.5) * 0.5 + rOpen) );
            double rLow   = MIN( rOpen, MIN(rClose, (arc4random() / (double)UINT32_MAX - 0.5) * 0.5 + rOpen) );

            [newData addObject:
             @{ @(CPTTradingRangePlotFieldX): @(x),
                @(CPTTradingRangePlotFieldOpen): @(rOpen),
                @(CPTTradingRangePlotFieldHigh): @(rHigh),
                @(CPTTradingRangePlotFieldLow): @(rLow),
                @(CPTTradingRangePlotFieldClose): @(rClose) }
            ];
        }

        self.plotData = newData;
    }
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:newGraph toHostingView:hostingView];
    [self applyTheme:theme toGraph:newGraph withDefault:[CPTTheme themeNamed:kCPTStocksTheme]];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor              = [CPTColor whiteColor];
    borderLineStyle.lineWidth              = 2.0;
    newGraph.plotAreaFrame.borderLineStyle = borderLineStyle;
    newGraph.plotAreaFrame.paddingTop      = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingRight    = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingBottom   = self.titleSize * CPTFloat(1.25);
    newGraph.plotAreaFrame.paddingLeft     = self.titleSize * CPTFloat(1.5);
    newGraph.plotAreaFrame.masksToBorder   = NO;

    self.graph = newGraph;

    // Axes
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = @(oneDay);
    xAxis.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    xAxis.labelFormatter        = timeFormatter;

    CPTLineCap *lineCap = [[CPTLineCap alloc] init];
    lineCap.lineStyle    = xAxis.axisLineStyle;
    lineCap.lineCapType  = CPTLineCapTypeSweptArrow;
    lineCap.size         = CGSizeMake( self.titleSize * CPTFloat(0.5), self.titleSize * CPTFloat(0.625) );
    lineCap.fill         = [CPTFill fillWithColor:xAxis.axisLineStyle.lineColor];
    xAxis.axisLineCapMax = lineCap;

    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.orthogonalPosition = @(-0.5 * oneDay);

    // Line plot with gradient fill
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
    dataSourceLinePlot.identifier    = @"Data Source Plot";
    dataSourceLinePlot.title         = @"Close Values";
    dataSourceLinePlot.dataLineStyle = nil;
    dataSourceLinePlot.dataSource    = self;
    [newGraph addPlot:dataSourceLinePlot];

    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(1.0) green:CPTFloat(1.0) blue:CPTFloat(1.0) alpha:CPTFloat(0.6)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = @0.0;

    areaColor                         = [CPTColor colorWithComponentRed:CPTFloat(0.0) green:CPTFloat(1.0) blue:CPTFloat(0.0) alpha:CPTFloat(0.6)];
    areaGradient                      = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
    areaGradient.angle                = -90.0;
    areaGradientFill                  = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill2      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue2 = @5.0;

    CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
    whiteShadow.shadowOffset     = CGSizeMake(2.0, -2.0);
    whiteShadow.shadowBlurRadius = 4.0;
    whiteShadow.shadowColor      = [CPTColor whiteColor];

    // OHLC plot
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 2.0;
    CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:newGraph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle  = whiteLineStyle;
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color     = [CPTColor whiteColor];
    ohlcPlot.labelTextStyle  = whiteTextStyle;
    ohlcPlot.labelOffset     = 0.0;
    ohlcPlot.barCornerRadius = 3.0;
    ohlcPlot.barWidth        = 15.0;
    ohlcPlot.increaseFill    = [CPTFill fillWithColor:[CPTColor greenColor]];
    ohlcPlot.decreaseFill    = [CPTFill fillWithColor:[CPTColor redColor]];
    ohlcPlot.dataSource      = self;
    ohlcPlot.delegate        = self;
    ohlcPlot.plotStyle       = CPTTradingRangePlotStyleCandleStick;
    ohlcPlot.shadow          = whiteShadow;
    ohlcPlot.labelShadow     = whiteShadow;
    [newGraph addPlot:ohlcPlot];

    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
    newGraph.legend.textStyle          = xAxis.titleTextStyle;
    newGraph.legend.fill               = newGraph.plotAreaFrame.fill;
    newGraph.legend.borderLineStyle    = newGraph.plotAreaFrame.borderLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 5.0;
    newGraph.legendAnchor              = CPTRectAnchorBottom;
    newGraph.legendDisplacement        = CGPointMake( 0.0, self.titleSize * CPTFloat(3.0) );

    // Set plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-0.5 * oneDay) length:@(oneDay * self.plotData.count)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@4.0];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [NSDecimalNumber zero];

    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        switch ( fieldEnum ) {
            case CPTScatterPlotFieldX:
                num = self.plotData[index][@(CPTTradingRangePlotFieldX)];
                break;

            case CPTScatterPlotFieldY:
                num = self.plotData[index][@(CPTTradingRangePlotFieldClose)];
                break;

            default:
                break;
        }
    }
    else {
        num = self.plotData[index][@(fieldEnum)];
    }
    return num;
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(void)tradingRangePlot:(CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Bar for '%@' was selected at index %d.", plot.identifier, (int)index);
}

@end
