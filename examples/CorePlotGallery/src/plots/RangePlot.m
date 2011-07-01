//
//  RangePlot.m
//  CorePlotGallery
//

#import "RangePlot.h"

static const NSTimeInterval oneDay = 24 * 60 * 60;

@implementation RangePlot

+ (void)load
{
    [super registerPlotItem:self];
}

- (id)init
{
	if ( (self = [super init]) ) {
		graph = nil;
		plotData = nil;
        title = @"Range Plot";
	}
	
    return self;
}

- (void)generateData
{
    if ( !plotData ) {
		NSMutableArray *newData = [NSMutableArray array];
		for ( NSUInteger i = 0; i < 5; i++ ) {
			NSTimeInterval x = oneDay*(i+1.0);
			float y = 3.0f*rand()/(float)RAND_MAX + 1.2f;
			float rHigh = rand()/(float)RAND_MAX * 0.5f + 0.25f;
			float rLow = rand()/(float)RAND_MAX * 0.5f + 0.25f;
			float rLeft = (rand()/(float)RAND_MAX * 0.125f + 0.125f) * oneDay;
			float rRight = (rand()/(float)RAND_MAX * 0.125f + 0.125f)  * oneDay;
			
			[newData addObject:
			 [NSDictionary dictionaryWithObjectsAndKeys:
			  [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPTRangePlotFieldX], 
			  [NSDecimalNumber numberWithFloat:y], [NSNumber numberWithInt:CPTRangePlotFieldY], 
			  [NSDecimalNumber numberWithFloat:rHigh], [NSNumber numberWithInt:CPTRangePlotFieldHigh], 
			  [NSDecimalNumber numberWithFloat:rLow], [NSNumber numberWithInt:CPTRangePlotFieldLow], 
			  [NSDecimalNumber numberWithFloat:rLeft], [NSNumber numberWithInt:CPTRangePlotFieldLeft], 
			  [NSDecimalNumber numberWithFloat:rRight], [NSNumber numberWithInt:CPTRangePlotFieldRight], 
			  nil]];
		}
		
		plotData = [newData retain];
    }
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
	// If you make sure your dates are calculated at noon, you shouldn't have to 
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];
	
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
	[graph release];
    graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
	
    // Instructions
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor whiteColor];
	textStyle.fontSize = 14.0;
	textStyle.fontName = @"Helvetica";
	
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Touch to Toggle Range Plot Style" style:textStyle];
#else
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Click to Toggle Range Plot Style" style:textStyle];
#endif
	CPTLayerAnnotation *instructionsAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:graph.plotAreaFrame.plotArea];
	instructionsAnnotation.contentLayer = textLayer;
	instructionsAnnotation.rectAnchor = CPTRectAnchorBottom;
	instructionsAnnotation.contentAnchorPoint = CGPointMake(0.5, 0.0);
	instructionsAnnotation.displacement = CGPointMake(0.0, 10.0);
	[graph.plotAreaFrame.plotArea addAnnotation:instructionsAnnotation];
	[instructionsAnnotation release];
	
	// Setup fill and bar style
    CPTColor *transparentGreen = [[CPTColor greenColor] colorWithAlphaComponent:0.2];
	areaFill = [(CPTFill *)[CPTFill alloc] initWithColor:transparentGreen];
	
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor greenColor];
    barLineStyle = [lineStyle retain];

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = oneDay * 0.5;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xLow) length:CPTDecimalFromDouble(oneDay * 5.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.5) length:CPTDecimalFromDouble(3.5)];
    
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPTDecimalFromDouble(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(2);
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
	
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(oneDay);
	
    // Create a plot that uses the data source method
	CPTRangePlot *rangePlot = [[[CPTRangePlot alloc] init] autorelease];
    rangePlot.identifier = @"Range Plot";
    rangePlot.barLineStyle = barLineStyle;
    rangePlot.dataSource = self;
    
    // Bar properties
	rangePlot.barWidth = 10.0;
	rangePlot.gapWidth = 20.0;
	rangePlot.gapHeight = 20.0;
    
    // Add plot
    [graph addPlot:rangePlot];
    graph.defaultPlotSpace.delegate = self;

	// Add legend
	graph.legend = [CPTLegend legendWithGraph:graph];
	graph.legend.textStyle = x.titleTextStyle;
	graph.legend.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
	graph.legend.borderLineStyle = x.axisLineStyle;
	graph.legend.cornerRadius = 5.0;
	graph.legend.swatchSize = CGSizeMake(25.0, 25.0);
	graph.legend.swatchCornerRadius = 3.0;
	graph.legendAnchor = CPTRectAnchorBottom;
	graph.legendDisplacement = CGPointMake(0.0, 12.0);
}

- (void)dealloc
{
	[graph release];
    [plotData release];
    [areaFill release];
    [barLineStyle release];
    [super dealloc];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point
{
    CPTRangePlot *rangePlot = (CPTRangePlot *)[graph plotWithIdentifier:@"Range Plot"];
    rangePlot.areaFill = ( rangePlot.areaFill ? nil : areaFill );
	//    rangePlot.barLineStyle = ( rangePlot.barLineStyle ? nil : barLineStyle );
    
    return NO;
} 

@end
