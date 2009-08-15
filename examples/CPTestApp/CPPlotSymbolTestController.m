#import "CPPlotSymbolTestController.h"

@implementation CPPlotSymbolTestController

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
	
	// Remove axes
    graph.axisSet = nil;
	
	// Background
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	graph.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
	// Plot area
	grayColor = CGColorCreateGenericGray(0.2, 0.3);
	graph.plotArea.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(11.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(14.0)];
    
    // Create a series of plots that uses the data source method
	for (NSUInteger i = CPPlotSymbolTypeNone; i <= CPPlotSymbolTypeCustom; i++) {
		CPScatterPlot *dataSourceLinePlot = [[(CPScatterPlot *)[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
		dataSourceLinePlot.identifier = [NSString stringWithFormat:@"%lu", (unsigned long)i];
		dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
		dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
		dataSourceLinePlot.dataSource = self;
		
		[graph addPlot:dataSourceLinePlot];
	}
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return 10;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSDecimalNumber *num;
	
	switch (fieldEnum) {
		case CPScatterPlotFieldX:
			num = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ud", index]];
			break;
		case CPScatterPlotFieldY:
			num = [NSDecimalNumber decimalNumberWithString:(NSString *)plot.identifier];
			break;
		default:
			num = [NSDecimalNumber zero];
	};
    return num;
}

-(CPPlotSymbol *)symbolForScatterPlot:(CPScatterPlot *)plot recordIndex:(NSUInteger)index
{
	CPGradient *gradientFill = [CPGradient rainbowGradient];
	gradientFill.gradientType = CPGradientTypeRadial;
	gradientFill.angle = 90;
	
	CPPlotSymbol *symbol = [[[CPPlotSymbol alloc] init] autorelease];
	symbol.symbolType = [(NSString *)plot.identifier intValue];
	symbol.fill = [CPFill fillWithGradient:gradientFill];
	
	if (index > 0) {
		symbol.size = CGSizeMake(index * 4, index * 4);
	}
	
	if (symbol.symbolType == CPPlotSymbolTypeCustom) {
		// Creating the custom path.
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, 0., 0.);
		
		CGPathAddEllipseInRect(path, NULL, CGRectMake(0., 0., 10., 10.));
		CGPathAddEllipseInRect(path, NULL, CGRectMake(1.5, 4., 3., 3.));
		CGPathAddEllipseInRect(path, NULL, CGRectMake(5.5, 4., 3., 3.));
		CGPathMoveToPoint(path, NULL, 5., 2.);
		CGPathAddArc(path, NULL, 5., 3.3, 2.8, 0., pi, TRUE);
		CGPathCloseSubpath(path);
		
		symbol.customSymbolPath = path;
		symbol.usesEvenOddClipRule = YES;
		CGPathRelease(path);
	}
	
	return symbol;
}

@end
