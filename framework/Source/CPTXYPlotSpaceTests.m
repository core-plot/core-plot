#import "CPTXYPlotSpaceTests.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

@interface CPTXYPlotSpace(testingAdditions)

-(nonnull CPTPlotRange *)constrainRange:(nonnull CPTPlotRange *)existingRange toGlobalRange:(nullable CPTPlotRange *)globalRange;

@end

#pragma mark -

@implementation CPTXYPlotSpaceTests

@synthesize graph;
@dynamic plotSpace;

-(void)setUp
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:CPTRectMake(0.0, 0.0, 100.0, 50.0)];

    self.graph.paddingLeft   = 0.0;
    self.graph.paddingRight  = 0.0;
    self.graph.paddingTop    = 0.0;
    self.graph.paddingBottom = 0.0;

    [self.graph layoutIfNeeded];
}

-(CPTXYPlotSpace *)plotSpace
{
    return (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
}

-(void)tearDown
{
    self.graph = nil;
}

#pragma mark -
#pragma mark View point for plot point (linear)

-(void)testViewPointForPlotPointArrayLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    CPTNumberArray *plotPoint = @[@5.0, @5.0];

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@5.0];

    viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(50.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForPlotPointLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    NSDecimal plotPoint[2];

    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble(5.0);
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble(5.0);

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@5.0];

    viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(50.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    double plotPoint[2];

    plotPoint[CPTCoordinateX] = 5.0;
    plotPoint[CPTCoordinateY] = 5.0;

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@5.0];

    viewPoint = [self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(50.0), CPTFloat(0.01), @"");
}

#pragma mark -
#pragma mark View point for plot point (log)

-(void)testViewPointForPlotPointArrayLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    CPTNumberArray *plotPoint = @[@(sqrt(10.0)), @(sqrt(10.0))];

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                         length:@90.0];

    viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, -CPTFloat(25.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForPlotPointLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    NSDecimal plotPoint[2];

    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble(sqrt(10.0));
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble(sqrt(10.0));

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                         length:@90.0];

    viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, -CPTFloat(25.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    double plotPoint[2];

    plotPoint[CPTCoordinateX] = sqrt(10.0);
    plotPoint[CPTCoordinateY] = sqrt(10.0);

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                         length:@90.0];

    viewPoint = [self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, -CPTFloat(25.0), CPTFloat(0.01), @"");
}

#pragma mark -
#pragma mark View point for plot point (log modulus)

-(void)testViewPointForPlotPointArrayLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    NSArray *plotPoint = @[@9.0, @0.0];

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(74.95), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForPlotPointLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    NSDecimal plotPoint[2];

    plotPoint[CPTCoordinateX] = CPTDecimalFromInteger(9);
    plotPoint[CPTCoordinateY] = CPTDecimalFromInteger(0);

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(74.95), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    double plotPoint[2];

    plotPoint[CPTCoordinateX] = 9.0;
    plotPoint[CPTCoordinateY] = 0.0;

    CGPoint viewPoint = [self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(74.95), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");
}

#pragma mark -
#pragma mark Plot point for view point (linear)

-(void)testPlotPointArrayForViewPointLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    CGPoint viewPoint         = CPTPointMake(50.0, 25.0);
    CPTNumberArray *plotPoint = [self.plotSpace plotPointForPlotAreaViewPoint:viewPoint];
    NSString *errMessage;

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", plotPoint[CPTCoordinateX]];
    XCTAssertTrue(CPTDecimalEquals([plotPoint[CPTCoordinateX] decimalValue], CPTDecimalFromDouble(5.0)), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", plotPoint[CPTCoordinateY]];
    XCTAssertTrue(CPTDecimalEquals([plotPoint[CPTCoordinateY] decimalValue], CPTDecimalFromDouble(5.0)), @"%@", errMessage);
}

-(void)testPlotPointForViewPointLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [self.plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateX], CPTDecimalFromDouble(5.0)), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateY], CPTDecimalFromDouble(5.0)), @"%@", errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLinear
{
    self.plotSpace.xScaleType = CPTScaleTypeLinear;
    self.plotSpace.yScaleType = CPTScaleTypeLinear;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];

    double plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [self.plotSpace doublePrecisionPlotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    XCTAssertEqual(plotPoint[CPTCoordinateX], 5.0, @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    XCTAssertEqual(plotPoint[CPTCoordinateY], 5.0, @"%@", errMessage);
}

#pragma mark -
#pragma mark Plot point for view point (log)

-(void)testPlotPointArrayForViewPointLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    CGPoint viewPoint         = CPTPointMake(50.0, 25.0);
    CPTNumberArray *plotPoint = [self.plotSpace plotPointForPlotAreaViewPoint:viewPoint];
    NSString *errMessage;

    [self.plotSpace plotPointForPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", plotPoint[CPTCoordinateX]];
    XCTAssertEqual([plotPoint[CPTCoordinateX] doubleValue], sqrt(10.0), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", plotPoint[CPTCoordinateY]];
    XCTAssertEqual([plotPoint[CPTCoordinateY] doubleValue], sqrt(10.0), @"%@", errMessage);
}

-(void)testPlotPointForViewPointLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [self.plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateX], CPTDecimalFromDouble(sqrt(10.0))), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateY], CPTDecimalFromDouble(sqrt(10.0))), @"%@", errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLog
{
    self.plotSpace.xScaleType = CPTScaleTypeLog;
    self.plotSpace.yScaleType = CPTScaleTypeLog;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                         length:@9.0];

    double plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [self.plotSpace doublePrecisionPlotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    XCTAssertEqual(plotPoint[CPTCoordinateX], sqrt(10.0), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    XCTAssertEqual(plotPoint[CPTCoordinateY], sqrt(10.0), @"%@", errMessage);
}

#pragma mark -
#pragma mark Plot point for view point (log modulus)

-(void)testPlotPointArrayForViewPointLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    CGPoint viewPoint  = CPTPointMake(74.95, 25.0);
    NSArray *plotPoint = [self.plotSpace plotPointForPlotAreaViewPoint:viewPoint];
    NSString *errMessage;

    [self.plotSpace plotPointForPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", plotPoint[CPTCoordinateX]];
    XCTAssertEqualWithAccuracy([plotPoint[CPTCoordinateX] doubleValue], CPTInverseLogModulus(1.0), 0.01, @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", plotPoint[CPTCoordinateY]];
    XCTAssertEqual([plotPoint[CPTCoordinateY] doubleValue], 0.0, @"%@", errMessage);
}

-(void)testPlotPointForViewPointLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [self.plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateX], CPTDecimalFromInteger(0)), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    XCTAssertTrue(CPTDecimalEquals(plotPoint[CPTCoordinateY], CPTDecimalFromInteger(0)), @"%@", errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLogModulus
{
    self.plotSpace.xScaleType = CPTScaleTypeLogModulus;
    self.plotSpace.yScaleType = CPTScaleTypeLogModulus;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-100.0)
                                                         length:@200.0];

    double plotPoint[2];
    CGPoint viewPoint = CPTPointMake(74.95, 25.0);
    NSString *errMessage;

    [self.plotSpace doublePrecisionPlotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    XCTAssertEqualWithAccuracy(plotPoint[CPTCoordinateX], CPTInverseLogModulus(1.0), 0.01, @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    XCTAssertEqual(plotPoint[CPTCoordinateY], 0.0, @"%@", errMessage);
}

#pragma mark -
#pragma mark Constrain ranges

-(void)testConstrainNilRanges
{
    CPTPlotRange *xRange = self.plotSpace.xRange;

    XCTAssertEqualObjects([self.plotSpace constrainRange:xRange toGlobalRange:nil], xRange, @"Constrain to nil global range should return original range.");
}

-(void)testConstrainRanges1
{
    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@2.0
                                                               length:@5.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = existingRange;

    CPTPlotRange *constrainedRange = [self.plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges2
{
    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                               length:@10.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@5.0];
    CPTPlotRange *expectedRange = globalRange;

    CPTPlotRange *constrainedRange = [self.plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges3
{
    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@(-1.0)
                                                               length:@8.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                               length:@8.0];

    CPTPlotRange *constrainedRange = [self.plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges4
{
    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@3.0
                                                               length:@8.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:@2.0
                                                               length:@8.0];

    CPTPlotRange *constrainedRange = [self.plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

#pragma mark -
#pragma mark Scaling

-(void)testScaleByAboutPoint1
{
    self.plotSpace.allowsUserInteraction = YES;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                         length:@(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [self.plotSpace scaleBy:0.5 aboutPoint:CGPointMake(CGRectGetMidX(myBounds), CGRectGetMidY(myBounds))];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:@(-5.0)
                                                                length:@20.0];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:@15.0
                                                                length:@(-20.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", self.plotSpace.xRange, expectedRangeX];

    XCTAssertTrue([self.plotSpace.xRange isEqualToRange:expectedRangeX], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", self.plotSpace.yRange, expectedRangeY];
    XCTAssertTrue([self.plotSpace.yRange isEqualToRange:expectedRangeY], @"%@", errMessage);
}

-(void)testScaleByAboutPoint2
{
    self.plotSpace.allowsUserInteraction = YES;

    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                         length:@10.0];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                         length:@(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [self.plotSpace scaleBy:2.0 aboutPoint:CGPointMake(CGRectGetMidX(myBounds), CGRectGetMidY(myBounds))];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:@2.5
                                                                length:@5.0];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:@7.5
                                                                length:@(-5.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", self.plotSpace.xRange, expectedRangeX];

    XCTAssertTrue([self.plotSpace.xRange isEqualToRange:expectedRangeX], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", self.plotSpace.yRange, expectedRangeY];
    XCTAssertTrue([self.plotSpace.yRange isEqualToRange:expectedRangeY], @"%@", errMessage);
}

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    self.plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                               length:@10.0];
    self.plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                               length:@(-10.0)];

    CPTXYPlotSpace *oldPlotSpace = self.plotSpace;
    CPTXYPlotSpace *newPlotSpace = [self archiveRoundTrip:oldPlotSpace];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", oldPlotSpace.xRange, newPlotSpace.xRange];

    XCTAssertTrue([oldPlotSpace.xRange isEqualToRange:newPlotSpace.xRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", oldPlotSpace.yRange, newPlotSpace.yRange];
    XCTAssertTrue([oldPlotSpace.yRange isEqualToRange:newPlotSpace.yRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"globalXRange was %@, expected %@", oldPlotSpace.globalXRange, newPlotSpace.globalXRange];
    XCTAssertTrue([oldPlotSpace.globalXRange isEqualToRange:newPlotSpace.globalXRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"globalYRange was %@, expected %@", oldPlotSpace.globalYRange, newPlotSpace.globalYRange];
    XCTAssertTrue([oldPlotSpace.globalYRange isEqualToRange:newPlotSpace.globalYRange], @"%@", errMessage);

    XCTAssertEqual(oldPlotSpace.xScaleType, newPlotSpace.xScaleType, @"xScaleType not equal");
    XCTAssertEqual(oldPlotSpace.yScaleType, newPlotSpace.yScaleType, @"yScaleType not equal");
}

@end
