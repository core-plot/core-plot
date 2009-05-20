
#import "CPCartesianPlotSpaceTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPCartesianPlotSpace (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPCartesianPlotSpace (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];
    
    [inCoder encodeObject:self.xRange forKey:@"xRange"];
    [inCoder encodeObject:self.yRange forKey:@"yRange"];
}

@end

@implementation CPCartesianPlotSpaceTests

@synthesize plotSpace;

- (void)setUp 
{
    self.plotSpace = [[[CPCartesianPlotSpace alloc] init] autorelease];
}

- (void)tearDown
{
    self.plotSpace = nil;
}

- (void)testViewPointForPlotPointRaisesForBadDimensions
{
    STAssertThrowsSpecificNamed([[self plotSpace] viewPointForPlotPoint:[NSArray array]],
                                NSException, CPDataException, @"Did not raise for 0D.");
    NSArray *plotPoint3D = [NSArray arrayWithObjects:
                            [NSNull null], 
                            [NSNull null], 
                            [NSNull null], 
                            nil];
    
    STAssertThrowsSpecificNamed([[self plotSpace] viewPointForPlotPoint:plotPoint3D],
                                NSException, CPDataException, @"Did not raise for 3D.");
}

- (void)testViewPointForPlotPoint
{
    self.plotSpace.bounds = CGRectMake(0., 0., 100., 50.);
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    
//    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke1", @"");
    
    NSArray *plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.],
                          [NSNumber numberWithFloat:5.],
                          nil];
    
    CGPoint viewPoint = [[self plotSpace] viewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50., (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25., (CGFloat)0.01, @"");
    
    
    
    self.plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(10.)];
    self.plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.) 
                                                        length:CPDecimalFromFloat(5.)];
    
//    GTMAssertObjectStateEqualToStateNamed(self.plotSpace, @"CPCartesianPlotSpaceTests-testViewPointForPlotPointSmoke2", @"");
    
    plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.],
                          [NSNumber numberWithFloat:5.],
                          nil];
    
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
    
    CGPoint viewPoint = CGPointMake(50., 25.);
    
    NSArray *plotPoint = [[self plotSpace] plotPointForViewPoint:viewPoint];
    
    STAssertEquals(plotPoint.count, (NSUInteger)2, @"wrong n-dim");
    
    STAssertEqualObjects([plotPoint objectAtIndex:0], [NSDecimalNumber decimalNumberWithString:@"5.0"], @"");
    STAssertEqualObjects([plotPoint objectAtIndex:1], [NSDecimalNumber decimalNumberWithString:@"5.0"], @"");
}

@end
