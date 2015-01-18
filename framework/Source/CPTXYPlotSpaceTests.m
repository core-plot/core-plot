#import "CPTXYPlotSpaceTests.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

@interface CPTXYPlotSpace(testingAdditions)

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;

@end

#pragma mark -

@implementation CPTXYPlotSpaceTests

@synthesize graph;

-(void)setUp
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:CPTRectMake(0.0, 0.0, 100.0, 50.0)];

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
#pragma mark View point for plot point (linear)

-(void)testViewPointForPlotPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];

    NSDecimal plotPoint[2];
    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble(5.0);
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble(5.0);

    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@5.0];

    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(50.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];

    double plotPoint[2];
    plotPoint[CPTCoordinateX] = 5.0;
    plotPoint[CPTCoordinateY] = 5.0;

    CGPoint viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@5.0];

    viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(50.0), CPTFloat(0.01), @"");
}

#pragma mark -
#pragma mark View point for plot point (log)

-(void)testViewPointForPlotPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];

    NSDecimal plotPoint[2];
    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble( sqrt(10.0) );
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble( sqrt(10.0) );

    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                    length:@90.0];

    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, -CPTFloat(25.0), CPTFloat(0.01), @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];

    double plotPoint[2];
    plotPoint[CPTCoordinateX] = sqrt(10.0);
    plotPoint[CPTCoordinateY] = sqrt(10.0);

    CGPoint viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, CPTFloat(25.0), CPTFloat(0.01), @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                    length:@90.0];

    viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];

    XCTAssertEqualWithAccuracy(viewPoint.x, CPTFloat(50.0), CPTFloat(0.01), @"");
    XCTAssertEqualWithAccuracy(viewPoint.y, -CPTFloat(25.0), CPTFloat(0.01), @"");
}

#pragma mark -
#pragma mark Plot point for view point (linear)

-(void)testPlotPointForViewPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    XCTAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateX], CPTDecimalFromDouble(5.0) ), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    XCTAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateY], CPTDecimalFromDouble(5.0) ), @"%@", errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];

    double plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace doublePrecisionPlotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    XCTAssertEqual(plotPoint[CPTCoordinateX], 5.0, @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    XCTAssertEqual(plotPoint[CPTCoordinateY], 5.0, @"%@", errMessage);
}

#pragma mark -
#pragma mark Plot point for view point (log)

-(void)testPlotPointForViewPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    XCTAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateX], CPTDecimalFromDouble( sqrt(10.0) ) ), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    XCTAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateY], CPTDecimalFromDouble( sqrt(10.0) ) ), @"%@", errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@1.0
                                                    length:@9.0];

    double plotPoint[2];
    CGPoint viewPoint = CPTPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace doublePrecisionPlotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    XCTAssertEqual(plotPoint[CPTCoordinateX], sqrt(10.0), @"%@", errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    XCTAssertEqual(plotPoint[CPTCoordinateY], sqrt(10.0), @"%@", errMessage);
}

#pragma mark -
#pragma mark Constrain ranges

-(void)testConstrainNilRanges
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    XCTAssertEqualObjects([plotSpace constrainRange:plotSpace.xRange toGlobalRange:nil], plotSpace.xRange, @"Constrain to nil global range should return original range.");
    XCTAssertNil([plotSpace constrainRange:nil toGlobalRange:plotSpace.xRange], @"Constrain nil range should return nil.");
}

-(void)testConstrainRanges1
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@2.0
                                                               length:@5.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = existingRange;

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges2
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                               length:@10.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@5.0];
    CPTPlotRange *expectedRange = globalRange;

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges3
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@(-1.0)
                                                               length:@8.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                               length:@8.0];

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

-(void)testConstrainRanges4
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:@3.0
                                                               length:@8.0];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                             length:@10.0];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:@2.0
                                                               length:@8.0];

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    XCTAssertTrue([constrainedRange isEqualToRange:expectedRange], @"%@", errMessage);
}

#pragma mark -
#pragma mark Scaling

-(void)testScaleByAboutPoint1
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.allowsUserInteraction = YES;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                    length:@(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [plotSpace scaleBy:0.5 aboutPoint:CGPointMake( CGRectGetMidX(myBounds), CGRectGetMidY(myBounds) )];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:@(-5.0)
                                                                length:@20.0];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:@15.0
                                                                length:@(-20.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, expectedRangeX];
    XCTAssertTrue([plotSpace.xRange isEqualToRange:expectedRangeX], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, expectedRangeY];
    XCTAssertTrue([plotSpace.yRange isEqualToRange:expectedRangeY], @"%@", errMessage);
}

-(void)testScaleByAboutPoint2
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.allowsUserInteraction = YES;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:@10.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                    length:@(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [plotSpace scaleBy:2.0 aboutPoint:CGPointMake( CGRectGetMidX(myBounds), CGRectGetMidY(myBounds) )];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:@2.5
                                                                length:@5.0];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:@7.5
                                                                length:@(-5.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, expectedRangeX];
    XCTAssertTrue([plotSpace.xRange isEqualToRange:expectedRangeX], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, expectedRangeY];
    XCTAssertTrue([plotSpace.yRange isEqualToRange:expectedRangeY], @"%@", errMessage);
}

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                          length:@10.0];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:@10.0
                                                          length:@(-10.0)];

    CPTXYPlotSpace *newPlotSpace = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:plotSpace]];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, newPlotSpace.xRange];
    XCTAssertTrue([plotSpace.xRange isEqualToRange:newPlotSpace.xRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, newPlotSpace.yRange];
    XCTAssertTrue([plotSpace.yRange isEqualToRange:newPlotSpace.yRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"globalXRange was %@, expected %@", plotSpace.globalXRange, newPlotSpace.globalXRange];
    XCTAssertTrue([plotSpace.globalXRange isEqualToRange:newPlotSpace.globalXRange], @"%@", errMessage);

    errMessage = [NSString stringWithFormat:@"globalYRange was %@, expected %@", plotSpace.globalYRange, newPlotSpace.globalYRange];
    XCTAssertTrue([plotSpace.globalYRange isEqualToRange:newPlotSpace.globalYRange], @"%@", errMessage);

    XCTAssertEqual(plotSpace.xScaleType, newPlotSpace.xScaleType, @"xScaleType not equal");
    XCTAssertEqual(plotSpace.yScaleType, newPlotSpace.yScaleType, @"yScaleType not equal");
}

@end
