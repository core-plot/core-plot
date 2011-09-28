#import "SelectionDemoController.h"

static NSString * const MAIN_PLOT = @"Scatter Plot";
static NSString * const SELECTION_PLOT = @"Selection Plot";

@interface SelectionDemoController()

-(void)setupGraph;
-(void)setupAxes;
-(void)setupScatterPlots;
-(void)initializeData;

@property (nonatomic, readwrite, retain) NSMutableArray *dataForPlot;
@property (nonatomic, readwrite) NSUInteger selectedIndex;

@end

#pragma mark -

@implementation SelectionDemoController

@synthesize dataForPlot;
@synthesize selectedIndex;

-(void)dealloc 
{
    [graph release];
	[dataForPlot release];
    [super dealloc];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

	selectedIndex = NSUIntegerMax;
	
	[self initializeData];
	[self setupGraph];
    [self setupAxes];
    [self setupScatterPlots];
}

#pragma mark -
#pragma mark Graph Setup Methods

-(void)setupGraph
{
    // Create graph and apply a dark theme
    graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [graph applyTheme:theme];
	hostView.hostedGraph = graph;
    
    // Graph title
    graph.title = @"This is the Graph Title";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 18.0;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0, 10.0);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	
    // Graph padding
    graph.paddingLeft = 20.0;
    graph.paddingTop = 20.0;
    graph.paddingRight = 20.0;
    graph.paddingBottom = 20.0;    
}

-(void)setupAxes
{
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
#ifdef REMOVE_SELECTION_ON_CLICK
    plotSpace.delegate = self;
#endif
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];    
    
    // Axes
    // Label x axis with a fixed interval policy
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.minorTicksPerInterval = 4;
    x.preferredNumberOfMajorTicks = 8;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
	x.title = @"X Axis";
	x.titleOffset = 30.0;
    
	// Label y with an automatic label policy. 
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval = 4;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelOffset = 10.0;
	y.title = @"Y Axis";
	y.titleOffset = 30.0;
}

-(void)setupScatterPlots
{
    // Create a plot that uses the data source method
	CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = MAIN_PLOT;
	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Set plot delegate, to know when symbols have been touched
	// We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self; 
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;
    
    // Create a plot for the selection marker
	CPTScatterPlot *selectionPlot = [[[CPTScatterPlot alloc] init] autorelease];
    selectionPlot.identifier = SELECTION_PLOT;
	selectionPlot.cachePrecision = CPTPlotCachePrecisionDouble;
    
    lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth = 3.0;
    lineStyle.lineColor = [CPTColor redColor];
    selectionPlot.dataLineStyle = lineStyle;
    
    selectionPlot.dataSource = self;
    [graph addPlot:selectionPlot];
    
    // Auto scale the plot space to fit the plot data
    // Compress ranges so we can scroll
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:[NSArray arrayWithObject:dataSourceLinePlot]];
    CPTPlotRange *xRange = plotSpace.xRange;
    [xRange expandRangeByFactor:CPTDecimalFromDouble(0.75)];
    plotSpace.xRange = xRange;
    CPTPlotRange *yRange = plotSpace.yRange;
    [yRange expandRangeByFactor:CPTDecimalFromDouble(0.75)];
    plotSpace.yRange = yRange;
    
    CPTPlotRange *globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0) length:CPTDecimalFromDouble(10.0)];
    plotSpace.globalXRange = globalXRange;
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-5.0) length:CPTDecimalFromDouble(10.0)];
    plotSpace.globalYRange = globalYRange;
}

-(void)initializeData
{
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	for ( NSUInteger i = 0; i < 100; i++ ) {
		id x = [NSNumber numberWithDouble:i * 0.05];
		id y = [NSNumber numberWithDouble:10.0 * rand()/(double)RAND_MAX - 5.0];
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.dataForPlot = contentArray;
}

#pragma mark -
#pragma mark Plot datasource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	NSUInteger count = 0;
	
    if ( [(NSString *)plot.identifier isEqualToString:MAIN_PLOT] ) {
		count = [self.dataForPlot count];
	}
    else if ( [(NSString *)plot.identifier isEqualToString:SELECTION_PLOT] ) {
		if ( self.selectedIndex < NSUIntegerMax ) {
			count = 5;
		}
	}
	
	return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
	
    if ( [(NSString *)plot.identifier isEqualToString:MAIN_PLOT] ) {
		NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
        num = [[self.dataForPlot objectAtIndex:index] valueForKey:key];
    }
    else if ( [(NSString *)plot.identifier isEqualToString:SELECTION_PLOT] ) {
		CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
		
		switch ( fieldEnum ) {
			case CPTScatterPlotFieldX:
				switch ( index ) {
					case 0:
						num = [NSDecimalNumber decimalNumberWithDecimal:thePlotSpace.globalXRange.minLimit];
						break;
					case 1:
						num = [NSDecimalNumber decimalNumberWithDecimal:thePlotSpace.globalXRange.maxLimit];
						break;
					case 2:
					case 3:
					case 4:
						num = [[self.dataForPlot objectAtIndex:self.selectedIndex] valueForKey:@"x"];
						break;
					default:
						break;
				}
				break;
			case CPTScatterPlotFieldY:
				switch ( index ) {
					case 0:
					case 1:
					case 2:
						num = [[self.dataForPlot objectAtIndex:self.selectedIndex] valueForKey:@"y"];
						break;
					case 3:
						num = [NSDecimalNumber decimalNumberWithDecimal:thePlotSpace.globalYRange.maxLimit];
						break;
					case 4:
						num = [NSDecimalNumber decimalNumberWithDecimal:thePlotSpace.globalYRange.minLimit];
						break;
					default:
						break;
				}
				break;
			default:
				break;
		}
	}
	
	return num;
}

-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index
{
	static CPTPlotSymbol *redDot = nil;
	
	CPTPlotSymbol *symbol = (id)[NSNull null];
	
	if ( [(NSString *)plot.identifier isEqualToString:SELECTION_PLOT] && (index == 2) ) {
		if ( !redDot ) {
			redDot = [[CPTPlotSymbol alloc] init];
			redDot.symbolType = CPTPlotSymbolTypeEllipse;
			redDot.size = CGSizeMake(10.0, 10.0);
			redDot.fill = [CPTFill fillWithColor:[CPTColor redColor]];
		}
		symbol = redDot;
	}
	
	return symbol;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
	self.selectedIndex = index;
}

#pragma mark -
#pragma mark Plot space delegate methods

#ifdef REMOVE_SELECTION_ON_CLICK
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point
{
	self.selectedIndex = NSUIntegerMax;
	return YES;
}
#endif

#pragma mark -
#pragma mark Accesors

-(void)setSelectedIndex:(NSUInteger)newIndex
{
	if ( selectedIndex != newIndex ) {
		selectedIndex = newIndex;
		[[graph plotWithIdentifier:SELECTION_PLOT] reloadData];
	}
}

@end
