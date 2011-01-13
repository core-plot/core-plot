
#import "Controller.h"
#import <CorePlot/CorePlot.h>


@implementation Controller

-(void)dealloc 
{
	[plotData release];
    [graph release];
    [areaFill release];
    [barLineStyle release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // If you make sure your dates are calculated at noon, you shouldn't have to 
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"12:00 Oct 29, 2009"];
    NSTimeInterval oneDay = 24 * 60 * 60;

    // Create graph from theme
    graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	[graph applyTheme:theme];
	hostView.hostedLayer = graph;
    
    // Title
    CPMutableTextStyle *textStyle = [CPMutableTextStyle textStyle];
	textStyle.color = [CPColor whiteColor];
    textStyle.fontSize = 18.0f;
    textStyle.fontName = @"Helvetica";
    graph.title = @"Click to Toggle Range Plot Style";
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, -20.0f);
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = oneDay*0.5f;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(xLow) length:CPDecimalFromFloat(oneDay*5.0f)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *timeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;

    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPDecimalFromFloat(oneDay);
            
    // Create a plot that uses the data source method
	CPRangePlot *dataSourceLinePlot = [[[CPRangePlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";

	// Add line style
	CPMutableLineStyle *lineStyle = [CPMutableLineStyle lineStyle];
	lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPColor greenColor];
    barLineStyle = [lineStyle retain];
    dataSourceLinePlot.barLineStyle = barLineStyle;
    
    // Bar properties
	dataSourceLinePlot.barWidth = 10.0f;
	dataSourceLinePlot.gapWidth = 20.0f;
	dataSourceLinePlot.gapHeight = 20.0f;
    dataSourceLinePlot.dataSource = self;
    
    // Add plot
    [graph addPlot:dataSourceLinePlot];
    graph.defaultPlotSpace.delegate = self;
    
    // Store area fill for use later
    CPColor *transparentGreen = [[CPColor greenColor] colorWithAlphaComponent:0.2];
    areaFill = [[CPFill alloc] initWithColor:(id)transparentGreen];
    	
    // Add some data
	NSMutableArray *newData = [NSMutableArray array];
	NSUInteger i;
	for ( i = 0; i < 5; i++ ) {
		NSTimeInterval x = oneDay*(i+1.0);
		float y = 3.0f*rand()/(float)RAND_MAX + 1.2f;
		float rHigh = rand()/(float)RAND_MAX * 0.5f + 0.25f;
		float rLow = rand()/(float)RAND_MAX * 0.5f + 0.25f;
		float rLeft = (rand()/(float)RAND_MAX * 0.125f + 0.125f) * oneDay;
		float rRight = (rand()/(float)RAND_MAX * 0.125f + 0.125f)  * oneDay;
		
		[newData addObject:
			 [NSDictionary dictionaryWithObjectsAndKeys:
			 [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPRangePlotFieldX], 
			 [NSDecimalNumber numberWithFloat:y], [NSNumber numberWithInt:CPRangePlotFieldY], 
			 [NSDecimalNumber numberWithFloat:rHigh], [NSNumber numberWithInt:CPRangePlotFieldHigh], 
			 [NSDecimalNumber numberWithFloat:rLow], [NSNumber numberWithInt:CPRangePlotFieldLow], 
			 [NSDecimalNumber numberWithFloat:rLeft], [NSNumber numberWithInt:CPRangePlotFieldLeft], 
			 [NSDecimalNumber numberWithFloat:rRight], [NSNumber numberWithInt:CPRangePlotFieldRight], 
			nil]];
	}
	plotData = newData;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return plotData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
    return num;
}

- (BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point {
    CPRangePlot *rangePlot = (CPRangePlot *)[graph plotWithIdentifier:@"Date Plot"];
    rangePlot.areaFill = ( rangePlot.areaFill ? nil : areaFill );
    rangePlot.barLineStyle = ( rangePlot.barLineStyle ? nil : barLineStyle );
    
    return NO;
} 

@end
