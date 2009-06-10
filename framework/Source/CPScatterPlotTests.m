
#import "CPScatterPlotTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotSymbol.h"

#import "GTMNSObject+BindingUnitTesting.h"


@implementation CPScatterPlotTests
@synthesize plot;

- (void)setUp
{
    
    CPXYPlotSpace *plotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
    plotSpace.bounds = CGRectMake(0., 0., 100., 100.);
    
    
    self.plot = [[[CPScatterPlot alloc] init] autorelease];
    //[plotSpace addSublayer:self.plot];
    self.plot.frame = plotSpace.bounds;
    
    self.plot.plotSpace = plotSpace;
    self.plot.identifier = @"Scatter Plot";
	
    self.plot.dataSource = self;
}


- (void)tearDown
{
    self.plot = nil;
}


- (void)setPlotRanges {
    [(CPXYPlotSpace*)[[self plot] plotSpace] setXRange:[self xRange]];
    [(CPXYPlotSpace*)[[self plot] plotSpace] setYRange:[self yRange]];
}


- (void)testRenderScatter
{
    self.nRecords = 1e2;
    [self buildData];
	[self setPlotRanges];
    
    GTMAssertObjectImageEqualToImageNamed(self.plot, @"CPScatterPlotTests-testRenderScatter", @"Should plot sine wave");
}

- (void)testBindings {
    GTMDoExposedBindingsFunctionCorrectly(self.plot, NULL);
}
   
@end
