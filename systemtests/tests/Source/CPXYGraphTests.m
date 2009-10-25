
#import "CPXYGraphTests.h"
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
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"

@interface CPXYGraph (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPXYGraph (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];

}

@end


@implementation CPXYGraphTests
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
    [self addScatterPlotUsingSymbols:NO];
}


- (void)addScatterPlotUsingSymbols:(BOOL)useSymbols
{
    self.graph.bounds = CGRectMake(0., 0., 400., 200.);
    
    CPScatterPlot *scatterPlot = [[[CPScatterPlot alloc] init] autorelease];
    scatterPlot.identifier = @"Scatter Plot";
	scatterPlot.dataLineStyle.lineWidth = 1.0;
    scatterPlot.dataSource = self;
    
    [self addPlot:scatterPlot];
    
    // Add plot symbols
    if(useSymbols) {
        CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
        CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
        greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:greenColor]];
        greenCirclePlotSymbol.size = CGSizeMake(5.0, 5.0);
        greenCirclePlotSymbol.lineStyle.lineWidth = 0.1;
        scatterPlot.plotSymbol = greenCirclePlotSymbol;
        CGColorRelease(greenColor);
    }
    
    CPXYPlotSpace *plotSpace;
    if([[self.graph allPlotSpaces] count] == 0) {
        plotSpace = (CPXYPlotSpace*)[[self graph] newPlotSpace];
        [[self graph] addPlotSpace:plotSpace];
        [plotSpace release];
    } else {
        plotSpace = (CPXYPlotSpace*)[[self graph] defaultPlotSpace];
    }
    
    _GTMDevAssert(plotSpace != nil, @"");
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) 
                                                   length:CPDecimalFromInt(self.nRecords)];
    plotSpace.yRange = [self yRange];
    _GTMDevLog(@"%@", [self yRange]);
    
    [[self graph] addPlot:scatterPlot toPlotSpace:plotSpace];
}

- (void)addXYAxisSet
{
    CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.constantCoordinateValue = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 2;
    
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = CPDecimalFromString(@"2");
}

/**
 This is really an integration test. This test verifies that a complete graph (with one scatter plot and plot symbols) renders correctly.
 */
- (void)testRenderScatterWithSymbol
{
    self.nRecords = 1e2;
    [self buildData];
    [self addScatterPlotUsingSymbols:YES];
    
    [self addXYAxisSet];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderScatterWithSymbol", @"Should render a sine wave with green symbols.");
}

- (void)testRenderMultipleScatter
{
    self.nRecords = 1e2;
    [self buildData];
    [self addScatterPlot];
    [self addScatterPlot];
    [self addScatterPlot];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderMultipleScatter", @"Should render 3 offset sine waves with no symbols.");
}

@end
