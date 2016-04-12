//
// SteppedScatterPlot.m
// Plot Gallery-Mac
//

#import "SteppedScatterPlot.h"

@interface SteppedScatterPlot()

@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary *> *plotData;

@end

@implementation SteppedScatterPlot

@synthesize plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Stepped Scatter Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData == nil ) {
        NSMutableArray<NSDictionary *> *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 10; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);
            [contentArray addObject:@{ @"x": x, @"y": y }
            ];
        }
        self.plotData = contentArray;
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
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];

    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    dataSourceLinePlot.delegate   = self;

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color              = [CPTColor whiteColor];
    dataSourceLinePlot.labelTextStyle = whiteTextStyle;
    dataSourceLinePlot.labelOffset    = 5.0;
    dataSourceLinePlot.labelRotation  = CPTFloat(M_PI_4);
    dataSourceLinePlot.identifier     = @"Stepped Plot";
    [graph addPlot:dataSourceLinePlot];

    // Make the data source line use stepped interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationStepped;

    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = @1.75;

    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    CPTXYPlotSpace *plotSpace = (id)graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:@[dataSourceLinePlot]];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:@1.1];
    plotSpace.yRange = yRange;

    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@6.0];
    plotSpace.globalYRange = globalYRange;
}

#pragma mark -
#pragma mark CPTScatterPlotDelegate Methods

-(void)Plot:(nonnull CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = self.plotData[index][key];

    return num;
}

@end
