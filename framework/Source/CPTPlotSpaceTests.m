#import "CPTPlotSpace.h"
#import "CPTPlotSpaceTests.h"
#import "CPTXYGraph.h"

@implementation CPTPlotSpaceTests

@synthesize graph;

-(void)setUp
{
    self.graph               = [[(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 50.0)] autorelease];
    self.graph.paddingLeft   = 0.0;
    self.graph.paddingRight  = 0.0;
    self.graph.paddingTop    = 0.0;
    self.graph.paddingBottom = 0.0;

    [self.graph layoutIfNeeded];
}

-(void)tearDown
{
    self.graph = nil;
}

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTPlotSpace *plotSpace = self.graph.defaultPlotSpace;

    plotSpace.identifier = @"test plot space";

    CPTPlotSpace *newPlotSpace = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:plotSpace]];

    STAssertEqualObjects(plotSpace.identifier, newPlotSpace.identifier, @"identifier not equal");
    STAssertEquals(plotSpace.allowsUserInteraction, newPlotSpace.allowsUserInteraction, @"allowsUserInteraction not equal");
}

@end
