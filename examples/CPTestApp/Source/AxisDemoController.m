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
	    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(11.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(11.0)];
	
    // Line styles
    CPLineStyle *axisLineStyle = [CPLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;
    
    CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPColor redColor];
    
    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPColor blueColor];
	
    // Axes
    // Label x axis with a fixed interval policy
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.minorTicksPerInterval = 4;
	x.tickDirection = CPSignNone;
	x.axisLineStyle = axisLineStyle;
	x.majorTickLength = 9.0;
	x.majorTickLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
	x.minorTickLength = 6.0;
    x.minorGridLineStyle = minorGridLineStyle;
	x.title = @"X Axis";
	x.axisTitleOffset = 30.0f;
	
	// Label y with an automatic label policy. 
    // Rotate the labels by 45 degrees, just to show it can be done.
	axisLineStyle.lineColor = [CPColor greenColor];
	
    CPXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 9;
	y.tickDirection = CPSignNone;
	y.axisLineStyle = axisLineStyle;
	y.majorTickLength = 9.0;
	y.majorTickLineStyle = axisLineStyle;
    y.majorGridLineStyle = majorGridLineStyle;
	y.minorTickLength = 6.0;
    y.minorGridLineStyle = minorGridLineStyle;
	y.title = @"Y Axis";
	y.axisTitleOffset = 30.0f;
}

@end
