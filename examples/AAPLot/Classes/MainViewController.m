
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
	CPTheme *theme = [CPTheme themeNamed:@"Dark Gradients"];
	graph = [theme newGraph];
	graph.frame = self.view.bounds;
	graph.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerHeightSizable;
	[self.view.layer addSublayer:graph];
    [super viewDidLoad];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        APYahooDataPuller *dp = [[APYahooDataPuller alloc] init];
        [dp setDelegate:self];
        [self setDatapuller:dp];
        [dp release];
    }
    return self;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return self.datapuller.financialData.count;;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    if (fieldEnum == CPScatterPlotFieldX) 
    {
        num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
    }
    else if (fieldEnum == CPScatterPlotFieldY)
    {
        NSArray *financialData = self.datapuller.financialData;
        
        APFinancialData *fData = (APFinancialData *)[financialData objectAtIndex:[financialData count] - index - 1];
        num = [fData close];
    }
    return num;
}


-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromInt([datapuller.financialData count])];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(120.0) length:CPDecimalFromFloat(30.0)];

    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    	
    axisSet.xAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    axisSet.xAxis.constantCoordinateValue = [NSDecimalNumber zero];
    axisSet.xAxis.minorTicksPerInterval = 1;
    
    axisSet.yAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"50.0"];
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.constantCoordinateValue = [NSDecimalNumber zero];
	
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol plusPlotSymbol];
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    dataSourceLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
	
    [dataSourceLinePlot reloadData];
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

