#import "DonutChart.h"

NSString * const innerChartName = @"Inner";
NSString * const outerChartName = @"Outer";

@implementation DonutChart

+ (void)load
{
    [super registerPlotItem:self];
}

- (id)init
{
	if ((self = [super init])) {
        title = @"Donut Chart";
    }

    return self;
}

- (void)killGraph
{
    [super killGraph];
}

- (void)dealloc
{
    [plotData release];
    [super dealloc];
}

- (void)generateData
{
    if (plotData == nil) {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:60.0],
                    nil];
    }
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.title = title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = bounds.size.height / 20.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, bounds.size.height / 18.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

    graph.plotAreaFrame.masksToBorder = NO;

    // Graph padding
    float boundsPadding = bounds.size.width / 20.0f;
    graph.paddingLeft = boundsPadding;
    graph.paddingTop = graph.titleDisplacement.y * 2;
    graph.paddingRight = boundsPadding;
    graph.paddingBottom = boundsPadding;

    graph.axisSet = nil;

	CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
	whiteLineStyle.lineColor = [CPTColor whiteColor];
	
	CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
	whiteShadow.shadowOffset = CGSizeMake(2.0, -4.0);
	whiteShadow.shadowBlurRadius = 4.0;
	whiteShadow.shadowColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                            0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
	CGFloat innerRadius = piePlot.pieRadius / 2.0;
	piePlot.pieInnerRadius = innerRadius + 5.0;
    piePlot.identifier = outerChartName;
	piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
	piePlot.shadow = whiteShadow;
    piePlot.delegate = self;
    [graph addPlot:piePlot];
    [piePlot release];
	
    // Add another pie chart
    piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = innerRadius - 5.0;
    piePlot.identifier = innerChartName;
	piePlot.borderLineStyle = whiteLineStyle;
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionClockwise;
	piePlot.shadow = whiteShadow;
    piePlot.delegate = self;
    [graph addPlot:piePlot];
    [piePlot release];
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"%@ slice was selected at index %lu. Value = %@", plot.identifier, index, [plotData objectAtIndex:index]);
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
    if (fieldEnum == CPTPieChartFieldSliceWidth) {
        num = [plotData objectAtIndex:index];
    }
    else {
        return [NSNumber numberWithInt:index];
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
	
	CPTTextLayer *newLayer = nil;
	
	if ( [(NSString *)plot.identifier isEqualToString:outerChartName] ) {
		if ( !whiteText ) {
			whiteText = [[CPTMutableTextStyle alloc] init];
			whiteText.color = [CPTColor whiteColor];
		}
		
		newLayer = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0f", [[plotData objectAtIndex:index] floatValue]] style:whiteText] autorelease];
	}
	
    return newLayer;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	CGFloat result = 0.0;
	if ( [(NSString *)pieChart.identifier isEqualToString:outerChartName] ) {
		result = ( index == 0 ? 15.0 : 0.0 );
	}
	return result;
}

@end
