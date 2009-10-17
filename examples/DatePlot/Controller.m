
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
    
    NSDate *refDate = [NSDate dateWithNaturalLanguageString:@"0:00 Jan 1, 2007"];
    NSTimeInterval oneDay = 24 * 60 * 60;

    // Create graph from theme
    graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	[graph applyTheme:theme];
	hostView.hostedLayer = graph;
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(xLow) length:CPDecimalFromFloat(oneDay*5.0f)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromFloat(oneDay);
    x.constantCoordinateValue = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *timeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.axisLabelFormatter = timeFormatter;

    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = CPDecimalFromFloat(oneDay);
            
    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    	
    // Add some data
	NSMutableArray *newData = [NSMutableArray array];
	NSUInteger i;
	for ( i = 0; i < 5; i++ ) {
		NSTimeInterval x = oneDay*i;
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
