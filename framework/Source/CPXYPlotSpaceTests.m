
#import "CPXYPlotSpaceTests.h"
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

@synthesize plotSpace;

- (void)setUp 
{
    self.plotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
}

- (void)tearDown
{
    self.plotSpace = nil;
}

- (void)testViewPointForPlotPoint
{
    self.plotSpace.bounds = CGRectMake(0., 0., 100., 50.);
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
//    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke1", @"");
    
    NSDecimalNumber *plotPoint[2];
	plotPoint[CPCoordinateX] = [NSDecimalNumber decimalNumberWithString:@"5.0"];
	plotPoint[CPCoordinateY] = [NSDecimalNumber decimalNumberWithString:@"5.0"];
    
    CGPoint viewPoint = [[self plotSpace] viewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25., (CGFloat)0.01, @"");
    
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(5.)];
    
//    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke2", @"");
    
    viewPoint = [[self plotSpace] viewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50., (CGFloat)0.01, @"");
}

- (void)testPlotPointForViewPoint 
{
    self.plotSpace.bounds = CGRectMake(0., 0., 100., 50.);
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
//    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testPlotPointForViewPoint", @"");
    
    NSDecimalNumber *plotPoint[2];
    CGPoint viewPoint = CGPointMake(50., 25.);
    
	[[self plotSpace] plotPoint:plotPoint forViewPoint:viewPoint];
  
    STAssertEqualObjects(plotPoint[CPCoordinateX], [NSDecimalNumber decimalNumberWithString:@"5.0"], @"");
    STAssertEqualObjects(plotPoint[CPCoordinateY], [NSDecimalNumber decimalNumberWithString:@"5.0"], @"");
}

@end
