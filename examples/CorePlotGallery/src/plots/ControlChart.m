#import "ControlChart.h"

NSString *const kDataLine	 = @"Data Line";
NSString *const kCenterLine	 = @"Center Line";
NSString *const kControlLine = @"Control Line";
NSString *const kWarningLine = @"Warning Line";

const NSUInteger numberOfPoints = 11;

@implementation ControlChart

+(void)load
{
	[super registerPlotItem:self];
}

-(id)init
{
	if ( (self = [super init]) ) {
		title = @"Control Chart";
	}

	return self;
}

-(void)generateData
{
	if ( plotData == nil ) {
		NSMutableArray *contentArray = [NSMutableArray array];

		double sum = 0.0;

		for ( NSUInteger i = 0; i < numberOfPoints; i++ ) {
			double y = 12.0 * rand() / (double)RAND_MAX + 5.0;
			sum += y;
			[contentArray addObject:[NSNumber numberWithDouble:y]];
		}

		plotData = [contentArray retain];

		meanValue = sum / numberOfPoints;

		sum = 0.0;
		for ( NSNumber *value in contentArray ) {
			double error = [value doubleValue] - meanValue;
			sum += error * error;
		}
		double stdDev = sqrt( ( 1.0 / (numberOfPoints - 1) ) * sum );
		standardError = stdDev / sqrt(numberOfPoints);
	}
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGRect bounds = layerHostingView.bounds;
#else
	CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

	CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:bounds] autorelease];
	[self addGraph:graph toHostingView:layerHostingView];
	[self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];

	[self setTitleDefaultsForGraph:graph withBounds:bounds];
	[self setPaddingDefaultsForGraph:graph withBounds:bounds];

	graph.plotAreaFrame.paddingTop	  = 15.0;
	graph.plotAreaFrame.paddingRight  = 15.0;
	graph.plotAreaFrame.paddingBottom = 35.0;
	graph.plotAreaFrame.paddingLeft	  = 35.0;

	// Grid line styles
	CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 0.75;
	majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];

	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	minorGridLineStyle.lineWidth = 0.25;
	minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];

	CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
	redLineStyle.lineWidth = 10.0;
	redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

	NSNumberFormatter *labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	labelFormatter.maximumFractionDigits = 0;

	// Axes
	// X axis
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
	x.labelingPolicy	 = CPTAxisLabelingPolicyAutomatic;
	x.majorGridLineStyle = majorGridLineStyle;
	x.minorGridLineStyle = minorGridLineStyle;
	x.labelFormatter	 = labelFormatter;

	x.title		  = @"X Axis";
	x.titleOffset = 30.0;

	// Y axis
	CPTXYAxis *y = axisSet.yAxis;
	y.labelingPolicy	 = CPTAxisLabelingPolicyAutomatic;
	y.majorGridLineStyle = majorGridLineStyle;
	y.minorGridLineStyle = minorGridLineStyle;
	y.labelFormatter	 = labelFormatter;

	y.title		  = @"Y Axis";
	y.titleOffset = 30.0;

	// Center line
	CPTScatterPlot *centerLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
	centerLinePlot.identifier = kCenterLine;

	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth			 = 2.0;
	lineStyle.lineColor			 = [CPTColor greenColor];
	centerLinePlot.dataLineStyle = lineStyle;

	centerLinePlot.dataSource = self;
	[graph addPlot:centerLinePlot];

	// Control lines
	CPTScatterPlot *controlLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
	controlLinePlot.identifier = kControlLine;

	lineStyle					  = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth			  = 2.0;
	lineStyle.lineColor			  = [CPTColor redColor];
	lineStyle.dashPattern		  = [NSArray arrayWithObjects:[NSNumber numberWithInteger:10], [NSNumber numberWithInteger:6], nil];
	controlLinePlot.dataLineStyle = lineStyle;

	controlLinePlot.dataSource = self;
	[graph addPlot:controlLinePlot];

	// Warning lines
	CPTScatterPlot *warningLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
	warningLinePlot.identifier = kWarningLine;

	lineStyle					  = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth			  = 1.0;
	lineStyle.lineColor			  = [CPTColor orangeColor];
	lineStyle.dashPattern		  = [NSArray arrayWithObjects:[NSNumber numberWithInteger:5], [NSNumber numberWithInteger:5], nil];
	warningLinePlot.dataLineStyle = lineStyle;

	warningLinePlot.dataSource = self;
	[graph addPlot:warningLinePlot];

	// Data line
	CPTScatterPlot *linePlot = [[[CPTScatterPlot alloc] init] autorelease];
	linePlot.identifier = kDataLine;

	lineStyle			   = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth	   = 3.0;
	linePlot.dataLineStyle = lineStyle;

	linePlot.dataSource = self;
	[graph addPlot:linePlot];

	// Add plot symbols
	CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill		 = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
	plotSymbol.lineStyle = symbolLineStyle;
	plotSymbol.size		 = CGSizeMake(10.0, 10.0);
	linePlot.plotSymbol	 = plotSymbol;

	// Auto scale the plot space to fit the plot data
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	[plotSpace scaleToFitPlots:[NSArray arrayWithObject:linePlot]];

	// Adjust visible ranges so plot symbols along the edges are not clipped
	CPTMutablePlotRange *xRange = [[plotSpace.xRange mutableCopy] autorelease];
	CPTMutablePlotRange *yRange = [[plotSpace.yRange mutableCopy] autorelease];

	x.orthogonalCoordinateDecimal = yRange.location;
	y.orthogonalCoordinateDecimal = xRange.location;

	x.visibleRange = xRange;
	y.visibleRange = yRange;

	x.gridLinesRange = yRange;
	y.gridLinesRange = xRange;

	[xRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
	[yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
	plotSpace.xRange = xRange;
	plotSpace.yRange = yRange;

	// Add legend
	graph.legend				 = [CPTLegend legendWithPlots:[NSArray arrayWithObjects:linePlot, controlLinePlot, warningLinePlot, centerLinePlot, nil]];
	graph.legend.textStyle		 = x.titleTextStyle;
	graph.legend.borderLineStyle = x.axisLineStyle;
	graph.legend.cornerRadius	 = 5.0;
	graph.legend.numberOfRows	 = 1;
	graph.legend.swatchSize		 = CGSizeMake(25.0, 25.0);
	graph.legendAnchor			 = CPTRectAnchorBottom;
	graph.legendDisplacement	 = CGPointMake(0.0, 12.0);
}

-(void)dealloc
{
	[plotData release];
	[super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	if ( plot.identifier == kDataLine ) {
		return [plotData count];
	}
	else if ( plot.identifier == kCenterLine ) {
		return 2;
	}
	else {
		return 5;
	}
}

-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	double number = NAN;

	switch ( fieldEnum ) {
		case CPTScatterPlotFieldX:
			if ( plot.identifier == kDataLine ) {
				number = (double)index;
			}
			else {
				switch ( index % 3 ) {
					case 0:
						number = 0.0;
						break;

					case 1:
						number = (double)([plotData count] - 1);
						break;

					case 2:
						number = NAN;
						break;
				}
			}

			break;

		case CPTScatterPlotFieldY:
			if ( plot.identifier == kDataLine ) {
				number = [[plotData objectAtIndex:index] doubleValue];
			}
			else if ( plot.identifier == kCenterLine ) {
				number = meanValue;
			}
			else if ( plot.identifier == kControlLine ) {
				switch ( index ) {
					case 0:
					case 1:
						number = meanValue + 3.0 * standardError;
						break;

					case 2:
						number = NAN;
						break;

					case 3:
					case 4:
						number = meanValue - 3.0 * standardError;
						break;
				}
			}
			else if ( plot.identifier == kWarningLine ) {
				switch ( index ) {
					case 0:
					case 1:
						number = meanValue + 2.0 * standardError;
						break;

					case 2:
						number = NAN;
						break;

					case 3:
					case 4:
						number = meanValue - 2.0 * standardError;
						break;
				}
			}

			break;
	}

	return number;
}

@end
