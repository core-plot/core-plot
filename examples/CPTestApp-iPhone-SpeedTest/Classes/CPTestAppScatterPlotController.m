//
//  CPTestAppScatterPlotController.m
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CPTestAppScatterPlotController.h"
#import "TestXYTheme.h"

#define USE_DOUBLEFASTPATH true
#define USE_ONEVALUEPATH false



@implementation CPTestAppScatterPlotController


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)dealloc 
{
    [graph release] ;
    [super dealloc];
}

-(void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Create graph from a custom theme
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
    CPTheme *theme = [[TestXYTheme alloc] init] ;
    [graph applyTheme:theme];
    [theme release] ;
    
	CPGraphHostingView *hostingView = (CPGraphHostingView *)self.view;
    hostingView.hostedGraph = graph;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(NUM_POINTS)];

	// Create a blue plot area
	CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Blue Plot";
	boundLinePlot.dataLineStyle.lineWidth = 1.0f;
	boundLinePlot.dataLineStyle.lineColor = [CPColor blueColor];
    boundLinePlot.dataSource = self;
	[graph addPlot:boundLinePlot];
    
    // Create a green plot area
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Green Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.0f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot] ;
    
    NSUInteger i;
	for ( i = 0; i < NUM_POINTS; i++ ) {
		xxx[i] = i ;
		yyy1[i] = (NUM_POINTS/3)*(rand()/(float)RAND_MAX);
        yyy2[i] = (NUM_POINTS/3)*(rand()/(float)RAND_MAX) + NUM_POINTS/3;
	}
    
#define PERFORMANCE_TEST1
#ifdef PERFORMANCE_TEST1
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif

#ifdef PERFORMANCE_TEST2
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadPlots) userInfo:nil repeats:YES];
#endif
}

- (void)reloadPlots
{
	NSArray *plots = [graph allPlots] ;
    for ( CPPlot *plot in plots )
    {
    	[plot reloadData] ;
    }
}

-(void)changePlotRange 
{
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    float ylen = NUM_POINTS*(rand()/(float)RAND_MAX) ;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(NUM_POINTS)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(ylen)];
}

#pragma mark -
#pragma mark Plot Data

- (double *)valuesForPlotWithIdentifier:(id)identifier field:(NSUInteger)fieldEnum
{
    if ( fieldEnum == 0 ) return xxx ;
    else
    {
        if ( [identifier isEqualToString:@"Blue Plot"] ) return yyy1 ;
        else return yyy2 ;
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot 
{
    return NUM_POINTS ;
}

#if USE_DOUBLEFASTPATH
#if USE_ONEVALUEPATH 
- (double)doubleForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)indx 
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum] ;
    return values[indx] ;
}

#else
- (double *)doublesForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange	 
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum] ;
    return values + indexRange.location ;
}

#endif

#else
#if USE_ONEVALUEPATH 
- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)indx 
{
    NSNumber *num = nil ;
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum] ;
	if ( values ) num = [NSNumber numberWithDouble:values[indx]] ;
    return num ;
}

#else
- (NSArray *)numbersForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange	 
{
    double *values = [self valuesForPlotWithIdentifier:[plot identifier] field:fieldEnum] ;
    if ( values == NULL ) return nil ;
    
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:indexRange.length] ;
    for ( NSUInteger i=indexRange.location ; i<indexRange.location+indexRange.length ; i++ )
    {
        NSNumber *number = [[NSNumber alloc] initWithDouble:values[i]] ;
        [returnArray addObject:number] ;
        [number release] ;
    }
    return returnArray ;
}

#endif
#endif

@end
