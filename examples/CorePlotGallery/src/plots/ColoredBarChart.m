#import "ColoredBarChart.h"

@implementation ColoredBarChart

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
    if ( plotData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 8; i++ ) {
            [contentArray addObject:@(10.0 * rand() / (double)RAND_MAX + 5.0)];
        }
        plotData = [contentArray retain];
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
    graph.plotAreaFrame.paddingLeft   += 60.0;
    graph.plotAreaFrame.paddingTop    += 25.0;
    graph.plotAreaFrame.paddingRight  += 20.0;
    graph.plotAreaFrame.paddingBottom += 20.0;
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
        x.majorIntervalLength         = CPTDecimalFromInteger(1);
        x.minorTicksPerInterval       = 0;
        x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
        x.majorGridLineStyle          = majorGridLineStyle;
        x.minorGridLineStyle          = minorGridLineStyle;
        x.axisLineStyle               = nil;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.labelFormatter              = nil;
    }

    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = CPTDecimalFromInteger(10);
        y.minorTicksPerInterval       = 9;
        y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = majorGridLineStyle;
        y.minorGridLineStyle          = minorGridLineStyle;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = 10.0;
        y.labelRotation               = M_PI_2;
        y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;

        y.title       = @"Y Axis";
        y.titleOffset = 30.0;
    }

    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[[CPTMutableLineStyle alloc] init] autorelease];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor whiteColor];

    // Create bar plot
    CPTBarPlot *barPlot = [[[CPTBarPlot alloc] init] autorelease];
    barPlot.lineStyle         = barLineStyle;
    barPlot.barWidth          = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space
    barPlot.barCornerRadius   = 4.0;
    barPlot.barsAreHorizontal = NO;
    barPlot.dataSource        = self;
    barPlot.identifier        = @"Bar Plot 1";

    [graph addPlot:barPlot];

    // Plot space
    CPTMutablePlotRange *barRange = [[[barPlot plotRangeEnclosingBars] mutableCopy] autorelease];
    [barRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];

    CPTXYPlotSpace *barPlotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    barPlotSpace.xRange = barRange;
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
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

    [graph release];
}

-(void)dealloc
{
    [plotData release];
    [super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
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
            nums = [plotData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
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
