#import "DonutChart.h"

NSString *const innerChartName = @"Inner";
NSString *const outerChartName = @"Outer";

@implementation DonutChart

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Donut Chart";
        self.section = kPieCharts;
    }

    return self;
}

-(void)dealloc
{
    [plotData release];
    [super dealloc];
}

-(void)generateData
{
    if ( plotData == nil ) {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    @20.0,
                    @30.0,
                    @60.0,
                    nil];
    }
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

    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;

    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];

    CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
    whiteShadow.shadowOffset     = CGSizeMake(2.0, -4.0);
    whiteShadow.shadowBlurRadius = 4.0;
    whiteShadow.shadowColor      = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Add pie chart
    const CGFloat outerRadius = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                                    0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    const CGFloat innerRadius = outerRadius / 2.0;

    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = outerRadius;
    piePlot.pieInnerRadius  = innerRadius + 5.0;
    piePlot.identifier      = outerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = animated ? M_PI_2 : M_PI_4;
    piePlot.endAngle        = animated ? M_PI_2 : 3.0 * M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.delegate        = self;
    [graph addPlot:piePlot];

    if ( animated ) {
        [CPTAnimation animate:piePlot
                     property:@"startAngle"
                         from:M_PI_2
                           to:M_PI_4
                     duration:0.25];
        [CPTAnimation animate:piePlot
                     property:@"endAngle"
                         from:M_PI_2
                           to:3.0 * M_PI_4
                     duration:0.25];
    }

    [piePlot release];

    // Add another pie chart
    piePlot                 = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = animated ? 0.0 : (innerRadius - 5.0);
    piePlot.identifier      = innerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.delegate        = self;
    [graph addPlot:piePlot];

    if ( animated ) {
        [CPTAnimation animate:piePlot
                     property:@"pieRadius"
                         from:0.0
                           to:innerRadius - 5.0
                     duration:0.5
                    withDelay:0.25
               animationCurve:CPTAnimationCurveBounceOut
                     delegate:nil];
    }

    [piePlot release];
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"%@ slice was selected at index %lu. Value = %@", plot.identifier, (unsigned long)index, plotData[index]);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = plotData[index];
    }
    else {
        return @(index);
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;

    CPTTextLayer *newLayer = nil;

    if ( [(NSString *)plot.identifier isEqualToString : outerChartName] ) {
        if ( !whiteText ) {
            whiteText       = [[CPTMutableTextStyle alloc] init];
            whiteText.color = [CPTColor whiteColor];
        }

        newLayer                 = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0f", [plotData[index] floatValue]] style:whiteText] autorelease];
        newLayer.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
        newLayer.cornerRadius    = 5.0;
        newLayer.paddingLeft     = 3.0;
        newLayer.paddingTop      = 3.0;
        newLayer.paddingRight    = 3.0;
        newLayer.paddingBottom   = 3.0;
        newLayer.borderLineStyle = [CPTLineStyle lineStyle];
    }

    return newLayer;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGFloat result = 0.0;

    if ( [(NSString *)pieChart.identifier isEqualToString : outerChartName] ) {
        result = (index == 0 ? 15.0 : 0.0);
    }
    return result;
}

@end
