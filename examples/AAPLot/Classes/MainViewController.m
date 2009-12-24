
#import "MainViewController.h"
#import "APYahooDataPuller.h"
#import "APFinancialData.h"

@interface MainViewController()

@property(nonatomic, retain) CPXYGraph *graph;
@property(nonatomic, retain) APYahooDataPuller *datapuller;

@end

@implementation MainViewController

@synthesize graph;
@synthesize datapuller;
@synthesize layerHost;

-(void)dealloc
{
    [datapuller release];
    [graph release];
    [layerHost release];
    datapuller = nil;
    graph = nil;
    layerHost = nil;    
    [super dealloc];
}

-(void)setView:(UIView *)aView;
{
    [super setView:aView];
    if (nil == aView)
    {
        self.graph = nil;
        self.layerHost = nil;
    }
}

-(void)viewDidLoad 
{    
	graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPStocksTheme];
	[graph applyTheme:theme];
	graph.frame = self.view.bounds;
	[self.layerHost.layer addSublayer:graph];
    
    // Line plot with gradient fill
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle = nil;
    dataSourceLinePlot.dataSource = self;
	[graph addPlot:dataSourceLinePlot];
	
	CPColor *areaColor = [CPColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
    areaGradient.angle = -90.0f;
	CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"320.0");
    
    // Candlestick plot
    CPLineStyle *whiteLineStyle = [CPLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPColor whiteColor];
    whiteLineStyle.lineWidth = 1.0f;
    CPTradingRangePlot *ohlcPlot = [[[CPTradingRangePlot alloc] initWithFrame:graph.bounds] autorelease];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle = whiteLineStyle;
    ohlcPlot.stickLength = 2.0f;
    ohlcPlot.dataSource = self;
    ohlcPlot.plotStyle = CPTradingRangePlotStyleOHLC;
    [graph addPlot:ohlcPlot];
    
    // Data puller
    APYahooDataPuller *dp = [[APYahooDataPuller alloc] init];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
        
    [super viewDidLoad];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return self.datapuller.financialData.count;;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        if (fieldEnum == CPScatterPlotFieldX) {
            num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
        }
        else if (fieldEnum == CPScatterPlotFieldY) {
            NSArray *financialData = self.datapuller.financialData;
            
            NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
            num = [fData objectForKey:@"close"];
            NSAssert(nil != num, @"grrr");
        }
    }
    else {
        NSArray *financialData = self.datapuller.financialData;
        NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
        switch ( fieldEnum ) {
            case CPTradingRangePlotFieldX:
                num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
                break;
            case CPTradingRangePlotFieldClose:
            	num = [fData objectForKey:@"close"];
                break;
            case CPTradingRangePlotFieldHigh:
            	num = [fData objectForKey:@"high"];
                break;            
            case CPTradingRangePlotFieldLow:
            	num = [fData objectForKey:@"low"];
                break;
            case CPTradingRangePlotFieldOpen:
            	num = [fData objectForKey:@"open"];
                break;
        }
    }
    return num;
}


-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
    
    NSDecimalNumber *high = [datapuller overallHigh];
    NSDecimalNumber *low = [datapuller overallLow];
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
    NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromInt([datapuller.financialData count])];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    	
    axisSet.xAxis.majorIntervalLength = CPDecimalFromString(@"10.0");
    axisSet.xAxis.constantCoordinateValue = CPDecimalAdd([[datapuller overallLow] decimalValue], CPDecimalFromString(@"5"));
    axisSet.xAxis.minorTicksPerInterval = 1;
    
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"50.0");
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.constantCoordinateValue = CPDecimalFromString(@"3.0");
    [graph reloadData];
}

-(APYahooDataPuller *)datapuller
{    
    return datapuller; 
}

-(void)setDatapuller:(APYahooDataPuller *)aDatapuller
{    
    if (datapuller != aDatapuller) {
        [aDatapuller retain];
        [datapuller release];
        datapuller = aDatapuller;
    }
}

@end

