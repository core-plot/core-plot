
#import "CPXYGraphPerformanceTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPPlotArea.h"
#import "CPPlotSymbol.h"
#import "CPFill.h"
#import "CPColor.h"
#import "GTMTestTimer.h"
#import "CPPlatformSpecificFunctions.h"

@implementation CPXYGraphPerformanceTests
@synthesize graph;

- (void)setUp
{
    self.graph = [[[CPXYGraph alloc] init] autorelease];
    
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	self.graph.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
	grayColor = CGColorCreateGenericGray(0.2, 0.3);
	self.graph.plotArea.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
    self.nRecords = 100;
}

- (void)tearDown
{
    self.graph = nil;
}

- (void)addScatterPlot
{
    self.graph.bounds = CGRectMake(0., 0., 400., 200.);
    
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace*)[[self graph] defaultPlotSpace];
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) 
                                                   length:CPDecimalFromInt(self.nRecords)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.1) 
                                                   length:CPDecimalFromFloat(2.2)];
    
    CPScatterPlot *scatterPlot = [[[CPScatterPlot alloc] init] autorelease];
    scatterPlot.identifier = @"Scatter Plot";
	scatterPlot.dataLineStyle.lineWidth = 1.0;
    scatterPlot.dataSource = self;
    
    // Add plot symbols
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(5.0, 5.0);
    scatterPlot.plotSymbol = greenCirclePlotSymbol;
	CGColorRelease(greenColor);
    
    [[self graph] addPlot:scatterPlot];
}

- (void)testRenderScatterStressTest
{
	self.nRecords = 1e6;
	[self buildData];
	[self addScatterPlot];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderStressTest", @"Should render a sine wave with green symbols.");
}
@end
