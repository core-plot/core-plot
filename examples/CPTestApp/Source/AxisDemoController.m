#import "AxisDemoController.h"

@implementation AxisDemoController

-(void)dealloc 
{
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib
{
    // Create graph
    graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
    hostView.hostedLayer = graph;
	
	// Background
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	graph.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
	// Plot area
	graph.plotArea.fill = [CPFill fillWithColor:[CPColor whiteColor]];
	graph.plotArea.paddingTop = 20;
	graph.plotArea.paddingBottom = 50;
	graph.plotArea.paddingLeft = 50;
	graph.plotArea.paddingRight = 20;
	
	graph.plotArea.plottingArea.borderLineStyle = [CPLineStyle lineStyle];
//	graph.plotArea.plottingArea.fill = graph.fill;

    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(10.0)];
	
    // Line styles
    CPLineStyle *axisLineStyle = [CPLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;
	axisLineStyle.lineCap = kCGLineCapRound;
    
    CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPColor redColor];
    
    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPColor blueColor];
	
	// Text styles
	CPTextStyle *axisTitleTextStyle = [CPTextStyle textStyle];
	axisTitleTextStyle.fontName = @"Helvetica Bold";
	axisTitleTextStyle.fontSize = 14.0;
	
    // Axes
    // Label x axis with a fixed interval policy
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.minorTicksPerInterval = 4;
	x.tickDirection = CPSignNone;
	x.axisLineStyle = axisLineStyle;
	x.majorTickLength = 12.0;
	x.majorTickLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
	x.minorTickLength = 8.0;
    x.minorGridLineStyle = minorGridLineStyle;
	x.title = @"X Axis";
	x.titleTextStyle = axisTitleTextStyle;
	x.titleOffset = 25.0f;
	x.titleLocation = CPDecimalFromFloat(5.0);
	
	// Label y with an automatic label policy.
	axisLineStyle.lineColor = [CPColor greenColor];
	
    CPXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 9;
	y.tickDirection = CPSignNone;
	y.axisLineStyle = axisLineStyle;
	y.majorTickLength = 12.0;
	y.majorTickLineStyle = axisLineStyle;
    y.majorGridLineStyle = majorGridLineStyle;
	y.minorTickLength = 8.0;
    y.minorGridLineStyle = minorGridLineStyle;
	y.title = @"Y Axis";
	y.titleTextStyle = axisTitleTextStyle;
	y.titleOffset = 30.0f;
	y.titleLocation = CPDecimalFromFloat(5.0);
}

@end
