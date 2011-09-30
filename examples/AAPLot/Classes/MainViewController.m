#import "APFinancialData.h"
#import "APYahooDataPuller.h"
#import "MainViewController.h"

@interface MainViewController()

@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) APYahooDataPuller *datapuller;

@end

@implementation MainViewController

@synthesize graph;
@synthesize datapuller;
@synthesize graphHost;

-(void)dealloc
{
	[datapuller release];
	[graph release];
	[graphHost release];
	datapuller = nil;
	graph	   = nil;
	graphHost  = nil;
	[super dealloc];
}

-(void)setView:(UIView *)aView;
{
	[super setView:aView];
	if ( nil == aView ) {
		self.graph	   = nil;
		self.graphHost = nil;
	}
}

-(void)viewDidLoad
{
	graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];
	[graph applyTheme:theme];
	graph.frame						  = self.view.bounds;
	graph.paddingRight				  = 50.0f;
	graph.paddingLeft				  = 50.0f;
	graph.plotAreaFrame.masksToBorder = NO;
	graph.plotAreaFrame.cornerRadius  = 0.0f;
	CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor			= [CPTColor whiteColor];
	borderLineStyle.lineWidth			= 2.0f;
	graph.plotAreaFrame.borderLineStyle = borderLineStyle;
	self.graphHost.hostedGraph			= graph;

	// Axes
	CPTXYAxisSet *xyAxisSet		   = (id)graph.axisSet;
	CPTXYAxis *xAxis			   = xyAxisSet.xAxis;
	CPTMutableLineStyle *lineStyle = [xAxis.axisLineStyle mutableCopy];
	lineStyle.lineCap	= kCGLineCapButt;
	xAxis.axisLineStyle = lineStyle;
	[lineStyle release];
	xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;

	CPTXYAxis *yAxis = xyAxisSet.yAxis;
	yAxis.axisLineStyle = nil;

	// Line plot with gradient fill
	CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
	dataSourceLinePlot.identifier	 = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle = nil;
	dataSourceLinePlot.dataSource	 = self;
	[graph addPlot:dataSourceLinePlot];

	CPTColor *areaColor		  = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
	CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
	areaGradient.angle = -90.0f;
	CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
	dataSourceLinePlot.areaFill		 = areaGradientFill;
	dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble( 200.0 );

	areaColor						  = [CPTColor colorWithComponentRed:0.0 green:1.0 blue:0.0 alpha:0.6];
	areaGradient					  = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
	areaGradient.angle				  = -90.0f;
	areaGradientFill				  = [CPTFill fillWithGradient:areaGradient];
	dataSourceLinePlot.areaFill2	  = areaGradientFill;
	dataSourceLinePlot.areaBaseValue2 = CPTDecimalFromDouble( 400.0 );

	// OHLC plot
	CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
	whiteLineStyle.lineColor = [CPTColor whiteColor];
	whiteLineStyle.lineWidth = 1.0f;
	CPTTradingRangePlot *ohlcPlot = [[[CPTTradingRangePlot alloc] initWithFrame:graph.bounds] autorelease];
	ohlcPlot.identifier = @"OHLC";
	ohlcPlot.lineStyle	= whiteLineStyle;
	CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color	= [CPTColor whiteColor];
	whiteTextStyle.fontSize = 8.0;
	ohlcPlot.labelTextStyle = whiteTextStyle;
	ohlcPlot.labelOffset	= 5.0;
	ohlcPlot.stickLength	= 2.0f;
	ohlcPlot.dataSource		= self;
	ohlcPlot.plotStyle		= CPTTradingRangePlotStyleOHLC;
	[graph addPlot:ohlcPlot];

	// Add plot space for horizontal bar charts
	CPTXYPlotSpace *volumePlotSpace = [[CPTXYPlotSpace alloc] init];
	volumePlotSpace.identifier = @"Volume Plot Space";
	[graph addPlotSpace:volumePlotSpace];
	[volumePlotSpace release];

	CPTBarPlot *volumePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blackColor] horizontalBars:NO];
	volumePlot.dataSource = self;

	lineStyle			 = [volumePlot.lineStyle mutableCopy];
	lineStyle.lineColor	 = [CPTColor whiteColor];
	volumePlot.lineStyle = lineStyle;
	[lineStyle release];

	volumePlot.fill		  = nil;
	volumePlot.barWidth	  = CPTDecimalFromFloat( 1.0f );
	volumePlot.identifier = @"Volume Plot";
	[graph addPlot:volumePlot toPlotSpace:volumePlotSpace];

	// Data puller
	NSDate *start		  = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0 * 12.0]; // 12 weeks ago
	NSDate *end			  = [NSDate date];
	APYahooDataPuller *dp = [[APYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" targetStartDate:start targetEndDate:end];
	[self setDatapuller:dp];
	[dp setDelegate:self];
	[dp release];

	[super viewDidLoad];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
	}
	return self;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return self.datapuller.financialData.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSDecimalNumber *num = [NSDecimalNumber zero];

	if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
		if ( fieldEnum == CPTScatterPlotFieldX ) {
			num = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:index + 1];
		}
		else if ( fieldEnum == CPTScatterPlotFieldY ) {
			NSArray *financialData = self.datapuller.financialData;

			NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
			num = [fData objectForKey:@"close"];
			NSAssert( nil != num, @"grrr" );
		}
	}
	else if ( [plot.identifier isEqual:@"Volume Plot"] ) {
		if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
			num = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:index + 1];
		}
		else if ( fieldEnum == CPTBarPlotFieldBarTip ) {
			NSArray *financialData = self.datapuller.financialData;

			NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
			num = [fData objectForKey:@"volume"];
			NSAssert( nil != num, @"grrr" );
		}
	}
	else {
		NSArray *financialData = self.datapuller.financialData;
		NSDictionary *fData	   = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
		switch ( fieldEnum ) {
			case CPTTradingRangePlotFieldX:
				num = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:index + 1];
				break;

			case CPTTradingRangePlotFieldClose:
				num = [fData objectForKey:@"close"];
				break;

			case CPTTradingRangePlotFieldHigh:
				num = [fData objectForKey:@"high"];
				break;

			case CPTTradingRangePlotFieldLow:
				num = [fData objectForKey:@"low"];
				break;

			case CPTTradingRangePlotFieldOpen:
				num = [fData objectForKey:@"open"];
				break;
		}
	}
	return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
	if ( ![(NSString *)plot.identifier isEqualToString:@"OHLC"] ) {
		return (id)[NSNull null]; // Don't show any label
	}
	else if ( index % 5 ) {
		return (id)[NSNull null];
	}
	else {
		return nil; // Use default label style
	}
}

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;
{
	CPTXYPlotSpace *plotSpace		= (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
	CPTXYPlotSpace *volumePlotSpace = (CPTXYPlotSpace *)[self.graph plotSpaceWithIdentifier:@"Volume Plot Space"];

	NSDecimalNumber *high	= [datapuller overallHigh];
	NSDecimalNumber *low	= [datapuller overallLow];
	NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
	NSLog( @"high = %@, low = %@, length = %@", high, low, length );
	NSDecimalNumber *pricePlotSpaceDisplacementPercent = [NSDecimalNumber decimalNumberWithMantissa:33
																						   exponent:-2
																						 isNegative:NO];

	NSDecimalNumber *lengthDisplacementValue = [length decimalNumberByMultiplyingBy:pricePlotSpaceDisplacementPercent];
	NSDecimalNumber *lowDisplayLocation		 = [low decimalNumberBySubtracting:lengthDisplacementValue];
	NSDecimalNumber *lengthDisplayLocation	 = [length decimalNumberByAdding:lengthDisplacementValue];

	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 1.0f ) length:CPTDecimalFromInteger( [datapuller.financialData count] )];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[lowDisplayLocation decimalValue] length:[lengthDisplayLocation decimalValue]];
	// Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

	NSDecimalNumber *overallVolumeHigh = [datapuller overallVolumeHigh];
	NSDecimalNumber *overallVolumeLow  = [datapuller overallVolumeLow];
	NSDecimalNumber *volumeLength	   = [overallVolumeHigh decimalNumberBySubtracting:overallVolumeLow];

	// make the length aka height for y 3 times more so that we get a 1/3 area covered by volume
	NSDecimalNumber *volumePlotSpaceDisplacementPercent = [NSDecimalNumber decimalNumberWithMantissa:3
																							exponent:0
																						  isNegative:NO];

	NSDecimalNumber *volumeLengthDisplacementValue = [volumeLength decimalNumberByMultiplyingBy:volumePlotSpaceDisplacementPercent];
	NSDecimalNumber *volumeLowDisplayLocation	   = overallVolumeLow;
	NSDecimalNumber *volumeLengthDisplayLocation   = [volumeLength decimalNumberByAdding:volumeLengthDisplacementValue];

	volumePlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 1.0 ) length:CPTDecimalFromInteger( [datapuller.financialData count] )];
	volumePlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue] length:[volumeLengthDisplayLocation decimalValue]];

	axisSet.xAxis.orthogonalCoordinateDecimal = [low decimalValue];

	axisSet.yAxis.majorIntervalLength		  = CPTDecimalFromString( @"50.0" );
	axisSet.yAxis.minorTicksPerInterval		  = 4;
	axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString( @"1.0" );
	NSArray *exclusionRanges = [NSArray arrayWithObjects:
								[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:[low decimalValue]],
								nil];

	axisSet.yAxis.labelExclusionRanges = exclusionRanges;

	[graph reloadData];
}

-(APYahooDataPuller *)datapuller
{
	return datapuller;
}

-(void)setDatapuller:(APYahooDataPuller *)aDatapuller
{
	if ( datapuller != aDatapuller ) {
		[aDatapuller retain];
		[datapuller release];
		datapuller = aDatapuller;
	}
}

@end
