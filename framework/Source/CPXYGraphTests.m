
#import "CPXYGraphTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPFillStyle.h"
#import "CPPlotSymbol.h"

#import "GTMTestTimer.h"

@interface CPXYGraph (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPXYGraph (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];

}

@end

@interface CPXYGraphTests ()
- (void)addScatterPlot;
@end

@implementation CPXYGraphTests
@synthesize graph;

- (void)setUp
{
    self.graph = [[[CPXYGraph alloc] initWithXScaleType:CPScaleTypeLinear
                                             yScaleType:CPScaleTypeLinear]
                  autorelease];
    
    self.nRecords = 100;
}

- (void)tearDown
{
    self.graph = nil;
}

- (void)addScatterPlot {
    self.graph.bounds = CGRectMake(0., 0., 400., 200.);
    
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace*)[[self graph] defaultPlotSpace];
    
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
	greenCirclePlotSymbol.fillColor = greenColor;
    greenCirclePlotSymbol.size = CGSizeMake(1.0, 1.0);
    scatterPlot.defaultPlotSymbol = greenCirclePlotSymbol;
	CGColorRelease(greenColor);
    
    [[self graph] addPlot:scatterPlot];
}

- (void)testRenderScatterWithSymbol
{
    self.nRecords = 1e4;
    [self buildData];
    [self addScatterPlot];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderScatterWithSymbol", @"Should render a sine wave with green symbols.");
}

//- (void)testRenderStressTest {
//    self.nRecords = 1e6;
//    [self buildData];
//    [self addScatterPlot];
//    
//    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderStressTest", @"Should render a sine wave with green symbols.");
//}

@end
