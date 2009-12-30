
#import "CPXYPlotSpaceTests.h"
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"


@implementation CPXYPlotSpaceTests

@synthesize graph;

-(void)setUp 
{
    self.graph = [[(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectMake(0., 0., 100., 50.)] autorelease];
}

-(void)tearDown
{
	self.graph = nil;
}

-(void)testViewPointForPlotPoint
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
    NSDecimal plotPoint[2];
	plotPoint[CPCoordinateX] = CPDecimalFromString(@"5.0");
	plotPoint[CPCoordinateY] = CPDecimalFromString(@"5.0");
    
    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25., (CGFloat)0.01, @"");
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(5.)];
    
    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50., (CGFloat)0.01, @"");
}

-(void)testPlotPointForViewPoint 
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
        
    NSDecimal plotPoint[2];
    CGPoint viewPoint = CGPointMake(50., 25.);
    
	[plotSpace plotPoint:plotPoint forPlotAreaViewPoint:viewPoint];
	
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateX], CPDecimalFromString(@"5.0")), @"");
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateY], CPDecimalFromString(@"5.0")), @"");
}

@end
