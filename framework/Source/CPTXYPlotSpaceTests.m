#import "CPTPlotRange.h"
#import "CPTUtilities.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"
#import "CPTXYPlotSpaceTests.h"

@interface CPTXYPlotSpace(testingAdditions)

-(CPTPlotRange *)constrainRange:(CPTPlotRange *)existingRange toGlobalRange:(CPTPlotRange *)globalRange;

@end

#pragma mark -

@implementation CPTXYPlotSpaceTests

@synthesize graph;

-(void)setUp
{
    self.graph = [[(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 50.0)] autorelease];

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

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];

    NSDecimal plotPoint[2];
    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble(5.0);
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble(5.0);

    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25.0, (CGFloat)0.01, @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(5.0)];

    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50.0, (CGFloat)0.01, @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];

    double plotPoint[2];
    plotPoint[CPTCoordinateX] = 5.0;
    plotPoint[CPTCoordinateY] = 5.0;

    CGPoint viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25.0, (CGFloat)0.01, @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(5.0)];

    viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50.0, (CGFloat)0.01, @"");
}

#pragma mark -
#pragma mark View point for plot point (log)

-(void)testViewPointForPlotPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];

    NSDecimal plotPoint[2];
    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble( sqrt(10.0) );
    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble( sqrt(10.0) );

    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25.0, (CGFloat)0.01, @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0)
                                                    length:CPTDecimalFromDouble(90.0)];

    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, -CPTFloat(25.0), (CGFloat)0.01, @"");
}

-(void)testViewPointForDoublePrecisionPlotPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];

    double plotPoint[2];
    plotPoint[CPTCoordinateX] = sqrt(10.0);
    plotPoint[CPTCoordinateY] = sqrt(10.0);

    CGPoint viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25.0, (CGFloat)0.01, @"");

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0)
                                                    length:CPTDecimalFromDouble(90.0)];

    viewPoint = [plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];

    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, -CPTFloat(25.0), (CGFloat)0.01, @"");
}

#pragma mark -
#pragma mark Plot point for view point (linear)

-(void)testPlotPointForViewPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CGPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace plotPoint:plotPoint forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    STAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateX], CPTDecimalFromDouble(5.0) ), errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    STAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateY], CPTDecimalFromDouble(5.0) ), errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLinear
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];

    double plotPoint[2];
    CGPoint viewPoint = CGPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace doublePrecisionPlotPoint:plotPoint forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    STAssertEquals(plotPoint[CPTCoordinateX], 5.0, errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    STAssertEquals(plotPoint[CPTCoordinateY], 5.0, errMessage);
}

#pragma mark -
#pragma mark Plot point for view point (log)

-(void)testPlotPointForViewPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];

    NSDecimal plotPoint[2];
    CGPoint viewPoint = CGPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace plotPoint:plotPoint forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %@", NSDecimalString(&plotPoint[CPTCoordinateX], nil)];
    STAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateX], CPTDecimalFromDouble( sqrt(10.0) ) ), errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %@", NSDecimalString(&plotPoint[CPTCoordinateY], nil)];
    STAssertTrue(CPTDecimalEquals( plotPoint[CPTCoordinateY], CPTDecimalFromDouble( sqrt(10.0) ) ), errMessage);
}

-(void)testDoublePrecisionPlotPointForViewPointLog
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLog;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0)
                                                    length:CPTDecimalFromDouble(9.0)];

    double plotPoint[2];
    CGPoint viewPoint = CGPointMake(50.0, 25.0);
    NSString *errMessage;

    [plotSpace doublePrecisionPlotPoint:plotPoint forPlotAreaViewPoint:viewPoint];

    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateX] was %g", plotPoint[CPTCoordinateX]];
    STAssertEquals(plotPoint[CPTCoordinateX], sqrt(10.0), errMessage);
    errMessage = [NSString stringWithFormat:@"plotPoint[CPTCoordinateY] was %g", plotPoint[CPTCoordinateY]];
    STAssertEquals(plotPoint[CPTCoordinateY], sqrt(10.0), errMessage);
}

#pragma mark -
#pragma mark Constrain ranges

-(void)testConstrainNilRanges
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    STAssertEqualObjects([plotSpace constrainRange:plotSpace.xRange toGlobalRange:nil], plotSpace.xRange, @"Constrain to nil global range should return original range.");
    STAssertNil([plotSpace constrainRange:nil toGlobalRange:plotSpace.xRange], @"Constrain nil range should return nil.");
}

-(void)testConstrainRanges1
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.0)
                                                               length:CPTDecimalFromDouble(5.0)];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                             length:CPTDecimalFromDouble(10.0)];
    CPTPlotRange *expectedRange = existingRange;

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges2
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                               length:CPTDecimalFromDouble(10.0)];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                             length:CPTDecimalFromDouble(5.0)];
    CPTPlotRange *expectedRange = globalRange;

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges3
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-1.0)
                                                               length:CPTDecimalFromDouble(8.0)];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                             length:CPTDecimalFromDouble(10.0)];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                               length:CPTDecimalFromDouble(8.0)];

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges4
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    CPTPlotRange *existingRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(3.0)
                                                               length:CPTDecimalFromDouble(8.0)];
    CPTPlotRange *globalRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                             length:CPTDecimalFromDouble(10.0)];
    CPTPlotRange *expectedRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.0)
                                                               length:CPTDecimalFromDouble(8.0)];

    CPTPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
    NSString *errMessage           = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange];

    STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

#pragma mark -
#pragma mark Scaling

-(void)testScaleByAboutPoint1
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.allowsUserInteraction = YES;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0)
                                                    length:CPTDecimalFromDouble(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [plotSpace scaleBy:0.5 aboutPoint:CGPointMake( CGRectGetMidX(myBounds), CGRectGetMidY(myBounds) )];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-5.0)
                                                                length:CPTDecimalFromDouble(20.0)];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(15.0)
                                                                length:CPTDecimalFromDouble(-20.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, expectedRangeX];
    STAssertTrue([plotSpace.xRange isEqualToRange:expectedRangeX], errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, expectedRangeY];
    STAssertTrue([plotSpace.yRange isEqualToRange:expectedRangeY], errMessage);
}

-(void)testScaleByAboutPoint2
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.allowsUserInteraction = YES;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                    length:CPTDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0)
                                                    length:CPTDecimalFromDouble(-10.0)];

    CGRect myBounds = self.graph.bounds;

    [plotSpace scaleBy:2.0 aboutPoint:CGPointMake( CGRectGetMidX(myBounds), CGRectGetMidY(myBounds) )];

    CPTPlotRange *expectedRangeX = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.5)
                                                                length:CPTDecimalFromDouble(5.0)];
    CPTPlotRange *expectedRangeY = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(7.5)
                                                                length:CPTDecimalFromDouble(-5.0)];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, expectedRangeX];
    STAssertTrue([plotSpace.xRange isEqualToRange:expectedRangeX], errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, expectedRangeY];
    STAssertTrue([plotSpace.yRange isEqualToRange:expectedRangeY], errMessage);
}

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
                                                          length:CPTDecimalFromDouble(10.0)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(10.0)
                                                          length:CPTDecimalFromDouble(-10.0)];

    CPTXYPlotSpace *newPlotSpace = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:plotSpace]];

    NSString *errMessage = [NSString stringWithFormat:@"xRange was %@, expected %@", plotSpace.xRange, newPlotSpace.xRange];
    STAssertTrue([plotSpace.xRange isEqualToRange:newPlotSpace.xRange], errMessage);

    errMessage = [NSString stringWithFormat:@"yRange was %@, expected %@", plotSpace.yRange, newPlotSpace.yRange];
    STAssertTrue([plotSpace.yRange isEqualToRange:newPlotSpace.yRange], errMessage);

    errMessage = [NSString stringWithFormat:@"globalXRange was %@, expected %@", plotSpace.globalXRange, newPlotSpace.globalXRange];
    STAssertTrue([plotSpace.globalXRange isEqualToRange:newPlotSpace.globalXRange], errMessage);

    errMessage = [NSString stringWithFormat:@"globalYRange was %@, expected %@", plotSpace.globalYRange, newPlotSpace.globalYRange];
    STAssertTrue([plotSpace.globalYRange isEqualToRange:newPlotSpace.globalYRange], errMessage);

    STAssertEquals(plotSpace.xScaleType, newPlotSpace.xScaleType, @"xScaleType not equal");
    STAssertEquals(plotSpace.yScaleType, newPlotSpace.yScaleType, @"yScaleType not equal");
}

@end
