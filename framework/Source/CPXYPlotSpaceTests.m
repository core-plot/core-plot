
#import "CPXYPlotSpaceTests.h"
#import "CPLayer.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPXYPlotSpace (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPXYPlotSpace (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];
    
    [inCoder encodeObject:self.xRange forKey:@"xRange"];
    [inCoder encodeObject:self.yRange forKey:@"yRange"];
}

@end

@implementation CPXYPlotSpaceTests

@synthesize layer;
@synthesize plotSpace;

- (void)setUp 
{
    self.layer = [[(CPLayer *)[CPLayer alloc] initWithFrame:CGRectMake(0., 0., 100., 50.)] autorelease];
    self.plotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
}

- (void)tearDown
{
	self.layer = nil;
    self.plotSpace = nil;
}

- (void)testViewPointForPlotPoint
{
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke1", @"");
    
    NSDecimal plotPoint[2];
	plotPoint[CPCoordinateX] = CPDecimalFromString(@"5.0");
	plotPoint[CPCoordinateY] = CPDecimalFromString(@"5.0");
    
    CGPoint viewPoint = [[self plotSpace] viewPointInLayer:self.layer forPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25., (CGFloat)0.01, @"");
    
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(5.)];
    
    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke2", @"");
    
    viewPoint = [[self plotSpace] viewPointInLayer:self.layer forPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50., (CGFloat)0.01, @"");
}

- (void)testPlotPointForViewPoint 
{
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testPlotPointForViewPoint", @"");
    
    NSDecimal plotPoint[2];
    CGPoint viewPoint = CGPointMake(50., 25.);
    
	[[self plotSpace] plotPoint:plotPoint forViewPoint:viewPoint inLayer:self.layer];
	
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateX], CPDecimalFromString(@"5.0")), @"");
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateY], CPDecimalFromString(@"5.0")), @"");
}

@end
