
#import "Controller.h"
#import <CorePlot/CorePlot.h>


@implementation Controller

-(void)dealloc 
{
	[plotData release];
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // If you make sure your dates are calculated at noon, you shouldn't have to 
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"00:00 Oct 29, 2009"];
    NSTimeInterval oneDay = 24 * 60 * 60;

    // Create graph from theme
    graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	[graph applyTheme:theme];
	hostView.hostedLayer = graph;
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(xLow) length:CPDecimalFromFloat(oneDay*3.0f)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 3;
	
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *myDateFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    myDateFormatter.referenceDate = refDate;
    x.labelFormatter = myDateFormatter;

	NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    timeFormatter.timeStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *myTimeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:timeFormatter] autorelease];
    myTimeFormatter.referenceDate = refDate;
    x.minorTickLabelFormatter = myTimeFormatter;
//	x.minorTickLabelRotation = M_PI/2;
	
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.5*oneDay);
            
    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";

	CPMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    	
    // Add some data
	NSMutableArray *newData = [NSMutableArray array];
	NSUInteger i;
	for ( i = 0; i < 7; i++ ) {
		NSTimeInterval x = oneDay*i*0.5f;
		id y = [NSDecimalNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
		[newData addObject:
        	[NSDictionary dictionaryWithObjectsAndKeys:
                [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPScatterPlotFieldX], 
                y, [NSNumber numberWithInt:CPScatterPlotFieldY], 
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

@end
