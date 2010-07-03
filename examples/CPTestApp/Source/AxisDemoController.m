#import "AxisDemoController.h"

@implementation AxisDemoController

-(void)awakeFromNib
{
	// Background
	CPBorderedLayer *background = [[(CPBorderedLayer *)[CPBorderedLayer alloc] initWithFrame:NSRectToCGRect(hostView.bounds)] autorelease];
	background.fill = [CPFill fillWithColor:[CPColor blueColor]];
	background.paddingTop = 20.0;
	background.paddingBottom = 20.0;
	background.paddingLeft = 20.0;
	background.paddingRight = 20.0;
    hostView.hostedLayer = background;
	
    // Create graph
	CPXYGraph *graph = [[(CPXYGraph *)[CPXYGraph alloc] initWithFrame:background.bounds] autorelease];
	graph.fill = [CPFill fillWithColor:[CPColor darkGrayColor]];
	graph.cornerRadius = 20.0;
	[background addSublayer:graph];
	
	// Plot area
	graph.plotAreaFrame.fill = [CPFill fillWithColor:[CPColor lightGrayColor]];
	graph.plotAreaFrame.paddingTop = 20.0;
	graph.plotAreaFrame.paddingBottom = 50.0;
	graph.plotAreaFrame.paddingLeft = 50.0;
	graph.plotAreaFrame.paddingRight = 20.0;
	graph.plotAreaFrame.cornerRadius = 10.0;
	
	graph.plotAreaFrame.axisSet.borderLineStyle = [CPLineStyle lineStyle];

	graph.plotAreaFrame.plotArea.fill = [CPFill fillWithColor:[CPColor whiteColor]];
	
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(10.0)];
	
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
	x.separateLayers = NO;
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
	x.titleOffset = 25.0;
	
	// Label y with an automatic label policy.
	axisLineStyle.lineColor = [CPColor greenColor];
	
    CPXYAxis *y = axisSet.yAxis;
	y.separateLayers = YES;
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
	y.titleOffset = 30.0;
}

@end
