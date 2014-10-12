#import "ColoredBarChart.h"

@interface ColoredBarChart()

@property (nonatomic, readwrite, strong) NSArray *plotData;

@end

@implementation ColoredBarChart

@synthesize plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Colored Bar Chart";
        self.section = kBarPlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 8; i++ ) {
            [contentArray addObject:@(10.0 * arc4random() / (double)UINT32_MAX + 5.0)];
        }
        self.plotData = contentArray;
    }
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    graph.plotAreaFrame.paddingLeft   += CPTFloat(60.0);
    graph.plotAreaFrame.paddingTop    += CPTFloat(25.0);
    graph.plotAreaFrame.paddingRight  += CPTFloat(20.0);
    graph.plotAreaFrame.paddingBottom += CPTFloat(20.0);
    graph.plotAreaFrame.masksToBorder  = NO;

    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.0;
    majorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1.0;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        x.majorIntervalLength   = @1.0;
        x.minorTicksPerInterval = 0;
        x.orthogonalPosition    = @0.0;
        x.majorGridLineStyle    = majorGridLineStyle;
        x.minorGridLineStyle    = minorGridLineStyle;
        x.axisLineStyle         = nil;
        x.majorTickLineStyle    = nil;
        x.minorTickLineStyle    = nil;
        x.labelFormatter        = nil;
    }

    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = @10.0;
        y.minorTicksPerInterval       = 9;
        y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = majorGridLineStyle;
        y.minorGridLineStyle          = minorGridLineStyle;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = 10.0;
        y.labelRotation               = CPTFloat(M_PI_2);
        y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;

        y.title       = @"Y Axis";
        y.titleOffset = 30.0;
    }

    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor whiteColor];

    // Create bar plot
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.lineStyle         = barLineStyle;
    barPlot.barWidth          = @0.75; // bar is 75% of the available space
    barPlot.barCornerRadius   = 4.0;
    barPlot.barsAreHorizontal = NO;
    barPlot.dataSource        = self;
    barPlot.identifier        = @"Bar Plot 1";

    [graph addPlot:barPlot];

    // Plot space
    CPTMutablePlotRange *barRange = [[barPlot plotRangeEnclosingBars] mutableCopy];
    [barRange expandRangeByFactor:@1.05];

    CPTXYPlotSpace *barPlotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    barPlotSpace.xRange = barRange;
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@16.0];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:CPTFloat(0.15)]];
    theLegend.borderLineStyle = barLineStyle;
    theLegend.cornerRadius    = 10.0;
    theLegend.swatchSize      = CGSizeMake(16.0, 16.0);
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 12.0;
    theLegend.textStyle     = whiteTextStyle;
    theLegend.rowMargin     = 10.0;
    theLegend.numberOfRows  = 1;
    theLegend.paddingLeft   = 12.0;
    theLegend.paddingTop    = 12.0;
    theLegend.paddingRight  = 12.0;
    theLegend.paddingBottom = 12.0;

    graph.legend             = theLegend;
    graph.legendAnchor       = CPTRectAnchorBottom;
    graph.legendDisplacement = CGPointMake(0.0, 5.0);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSArray *nums = nil;

    switch ( fieldEnum ) {
        case CPTBarPlotFieldBarLocation:
            nums = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                [(NSMutableArray *)nums addObject : @(i)];
            }
            break;

        case CPTBarPlotFieldBarTip:
            nums = [self.plotData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;

        default:
            break;
    }

    return nums;
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    CPTColor *color = nil;

    switch ( index ) {
        case 0:
            color = [CPTColor redColor];
            break;

        case 1:
            color = [CPTColor greenColor];
            break;

        case 2:
            color = [CPTColor blueColor];
            break;

        case 3:
            color = [CPTColor yellowColor];
            break;

        case 4:
            color = [CPTColor purpleColor];
            break;

        case 5:
            color = [CPTColor cyanColor];
            break;

        case 6:
            color = [CPTColor orangeColor];
            break;

        case 7:
            color = [CPTColor magentaColor];
            break;

        default:
            break;
    }

    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];

    return [CPTFill fillWithGradient:fillGradient];
}

-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"Bar %lu", (unsigned long)(index + 1)];
}

@end
