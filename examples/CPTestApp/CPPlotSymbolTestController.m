#import "CPPlotSymbolTestController.h"

@implementation CPPlotSymbolTestController

-(void)dealloc 
{
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib {
    // Create graph
    graph = [[CPXYGraph alloc] init];
	graph.frame = NSRectToCGRect(hostView.bounds);
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	graph.fill = [CPFill fillWithColor:grayColor];
	CGColorRelease(grayColor);

	grayColor = CGColorCreateGenericGray(0.2, 0.3);
	graph.plotArea.fill = [CPFill fillWithColor:grayColor];
	CGColorRelease(grayColor);

    [hostView setLayer:graph];
	[hostView setWantsLayer:YES];
    
    // Setup plot space
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(11.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(13.0)];
    
	CPGradient *gradientFill = [CPGradient rainbowGradient];
	gradientFill.gradientType = CPRadialGradientType;
	gradientFill.angle = 90;
	
    // Create a series of plots that uses the data source method
	for (NSUInteger i = CPPlotSymbolTypeNone; i <= CPPlotSymbolTypeSnow; i++) {
		CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
		dataSourceLinePlot.identifier = [NSString stringWithFormat:@"%lu", (unsigned long)i];
		dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
		CGColorRef redColor = CPNewCGColorFromNSColor([NSColor redColor]);
		dataSourceLinePlot.dataLineStyle.lineColor = redColor;
		CGColorRelease(redColor);
		dataSourceLinePlot.dataSource = self;
		
		// add plot symbols
		CPPlotSymbol *symbol = [[[CPPlotSymbol alloc] init] autorelease];
		symbol.symbolType = i;
		symbol.fill = [CPFill fillWithGradient:gradientFill];
		
		dataSourceLinePlot.defaultPlotSymbol = symbol;

		for (NSUInteger j = 1; j < [self numberOfRecords]; j++) {
			symbol = [[symbol copy] autorelease];
			symbol.size = CGSizeMake(j * 4, j * 4);
			[dataSourceLinePlot setPlotSymbol:symbol atIndex:j];
		}
		
		[graph addPlot:dataSourceLinePlot];
	}
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return 10;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
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

@end
