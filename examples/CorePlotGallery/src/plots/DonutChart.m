#import "DonutChart.h"

static NSString *const innerChartName = @"Inner";
static NSString *const outerChartName = @"Outer";

@interface DonutChart()

@property (nonatomic, readwrite, strong, nonnull) CPTNumberArray *plotData;

@end

@implementation DonutChart

@synthesize plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        self.title   = @"Donut Chart";
        self.section = kPieCharts;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        self.plotData = @[@20.0, @30.0, @60.0];
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
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;

    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];

    CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
    whiteShadow.shadowOffset     = CGSizeMake(2.0, -4.0);
    whiteShadow.shadowBlurRadius = 4.0;
    whiteShadow.shadowColor      = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Add pie chart
    const CGFloat outerRadius = MIN(CPTFloat(0.7) * (hostingView.frame.size.height - CPTFloat(2.0) * graph.paddingLeft) / CPTFloat(2.0),
                                    CPTFloat(0.7) * (hostingView.frame.size.width - CPTFloat(2.0) * graph.paddingTop) / CPTFloat(2.0));
    const CGFloat innerRadius = outerRadius / CPTFloat(2.0);

    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = outerRadius;
    piePlot.pieInnerRadius  = innerRadius + CPTFloat(5.0);
    piePlot.identifier      = outerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = CPTFloat(animated ? M_PI_2 : M_PI_4);
    piePlot.endAngle        = CPTFloat(animated ? M_PI_2 : 3.0 * M_PI_4);
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.delegate        = self;
    [graph addPlot:piePlot];

    if ( animated ) {
        [CPTAnimation animate:piePlot
                     property:@"startAngle"
                         from:CPTFloat(M_PI_2)
                           to:CPTFloat(M_PI_4)
                     duration:0.25];
        [CPTAnimation animate:piePlot
                     property:@"endAngle"
                         from:CPTFloat(M_PI_2)
                           to:CPTFloat(3.0 * M_PI_4)
                     duration:0.25];
    }

    // Add another pie chart
    piePlot                 = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = (animated ? CPTFloat(0.0) : (innerRadius - CPTFloat(5.0)));
    piePlot.identifier      = innerChartName;
    piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle      = CPTFloat(M_PI_4);
    piePlot.sliceDirection  = CPTPieDirectionClockwise;
    piePlot.shadow          = whiteShadow;
    piePlot.delegate        = self;
    [graph addPlot:piePlot];

    if ( animated ) {
        [CPTAnimation animate:piePlot
                     property:@"pieRadius"
                         from:0.0
                           to:innerRadius - CPTFloat(5.0)
                     duration:0.5
                    withDelay:0.25
               animationCurve:CPTAnimationCurveBounceOut
                     delegate:self];
    }
}

-(void)pieChart:(nonnull CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"%@ slice was selected at index %lu. Value = %@", plot.identifier, (unsigned long)index, self.plotData[index]);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = self.plotData[index];
    }
    else {
        return @(index);
    }

    return num;
}

-(nullable CPTLayer *)dataLabelForPlot:(nonnull CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken      = 0;

    CPTTextLayer *newLayer = nil;

    if ( [(NSString *) plot.identifier isEqualToString:outerChartName] ) {
        dispatch_once(&onceToken, ^{
            whiteText          = [[CPTMutableTextStyle alloc] init];
            whiteText.color    = [CPTColor whiteColor];
            whiteText.fontSize = self.titleSize * CPTFloat(0.5);
        });

        newLayer                 = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0f", self.plotData[index].doubleValue] style:whiteText];
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

-(CGFloat)radialOffsetForPieChart:(nonnull CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGFloat result = 0.0;

    if ( [(NSString *) pieChart.identifier isEqualToString:outerChartName] ) {
        result = (index == 0 ? 15.0 : 0.0);
    }
    return result;
}

#pragma mark -
#pragma mark Animation Delegate

-(void)animationDidStart:(nonnull id)operation
{
    NSLog(@"animationDidStart: %@", operation);
}

-(void)animationDidFinish:(nonnull CPTAnimationOperation *)operation
{
    NSLog(@"animationDidFinish: %@", operation);
}

-(void)animationCancelled:(nonnull CPTAnimationOperation *)operation
{
    NSLog(@"animationCancelled: %@", operation);
}

-(void)animationWillUpdate:(nonnull CPTAnimationOperation *)operation
{
    NSLog(@"animationWillUpdate:");
}

-(void)animationDidUpdate:(nonnull CPTAnimationOperation *)operation
{
    NSLog(@"animationDidUpdate:");
}

@end
