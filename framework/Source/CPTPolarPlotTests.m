#import "CPTPolarPlotTests.h"

#import "CPTPlotRange.h"
#import "CPTPolarPlot.h"
#import "CPTPolarPlotSpace.h"

@interface CPTPolarPlot(Testing)

-(void)calculatePointsToDraw:(nonnull BOOL *)pointDrawFlags forPlotSpace:(nonnull CPTPolarPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly numberOfPoints:(NSUInteger)dataCount;
-(void)setThetaValues:(nullable CPTNumberArray *)newValues;
-(void)setRadiusValues:(nullable CPTNumberArray *)newValues;

@end

@implementation CPTPolarPlotTests

@synthesize plot;
@synthesize plotSpace;

-(void)setUp
{
    CPTNumberArray *thetaValues = @[@0.0, @90., @180.0, @270.0, @360.0];
    CPTNumberArray *radiusValues = @[@0.5, @0.5, @0.5, @0.5, @0.5];

    self.plot = [CPTPolarPlot new];
    [self.plot setradialAngleOption:CPTPolarPlotAngleDegrees];
    [self.plot setThetaValues:thetaValues];
    [self.plot setRadiusValues:radiusValues];
    self.plot.cachePrecision = CPTPlotCachePrecisionDouble;

    CPTPlotRange *xPlotRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@1.0];
    CPTPlotRange *yPlotRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@1.0];
    CPTPlotRange *zPlotRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@360.0];
    self.plotSpace        = [[CPTPolarPlotSpace alloc] init];
    self.plotSpace.xRange = xPlotRange;
    self.plotSpace.yRange = yPlotRange;
    self.plotSpace.zRange = zPlotRange;
}

-(void)tearDown
{
    self.plot      = nil;
    self.plotSpace = nil;
}

-(void)testCalculatePointsToDrawAllInRange
{
    CPTNumberArray *thetaValues = @[@0.0, @90., @180.0, @270.0, @360.0];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertTrue(drawFlags[i], @"Test that in range points are drawn (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawAllInRangeVisibleOnly
{
    CPTNumberArray *thetaValues = @[@0.0, @90., @180.0, @270.0, @360.0];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:YES numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertTrue(drawFlags[i], @"Test that in range points are drawn (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawNoneInRange
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @(-0.2), @(-0.15), @(-0.6), @(-0.9)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertFalse(drawFlags[i], @"Test that out of range points are not drawn (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawNoneInRangeVisibleOnly
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @(-0.2), @(-0.15), @(-0.6), @(-0.9)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:YES numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertFalse(drawFlags[i], @"Test that out of range points are not drawn (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawNoneInRangeDifferentRegions
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @2, @(-0.15), @3, @(-0.9)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertTrue(drawFlags[i], @"Test that out of range points in different regions get included (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawNoneInRangeDifferentRegionsVisibleOnly
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @2, @(-0.15), @3, @(-0.9)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:YES numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        XCTAssertFalse(drawFlags[i], @"Test that out of range points in different regions get included (%@).", inRangeValues[i]);
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawSomeInRange
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @0.1, @0.2, @1.2, @1.5];
    BOOL expected[5]              = { YES, YES, YES, YES, NO };

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:inRangeValues.count];
    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        if ( expected[i] ) {
            XCTAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out (%@).", inRangeValues[i]);
        }
        else {
            XCTAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out (%@).", inRangeValues[i]);
        }
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawSomeInRangeVisibleOnly
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @0.1, @0.2, @1.2, @1.5];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:YES numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        if ( [self.plotSpace.xRange compareToNumber:inRangeValues[i]] == CPTPlotRangeComparisonResultNumberInRange ) {
            XCTAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out (%@).", inRangeValues[i]);
        }
        else {
            XCTAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out (%@).", inRangeValues[i]);
        }
    }

    free(drawFlags);
}

-(void)testCalculatePointsToDrawSomeInRangeCrossing
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @1.1, @0.9, @(-0.1), @(-0.2)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);
    BOOL *expected  = malloc(sizeof(BOOL) * inRangeValues.count);

    for ( NSUInteger i = 0; i < inRangeValues.count - 1; i++ ) {
        expected[i] = YES;
    }
    expected[inRangeValues.count] = NO;

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        if ( expected[i] ) {
            XCTAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%@).", inRangeValues[i]);
        }
        else {
            XCTAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%@).", inRangeValues[i]);
        }
    }

    free(drawFlags);
    free(expected);
}

-(void)testCalculatePointsToDrawSomeInRangeCrossingVisibleOnly
{
    CPTNumberArray *inRangeValues = @[@(-0.1), @1.1, @0.9, @(-0.1), @(-0.2)];

    BOOL *drawFlags = malloc(sizeof(BOOL) * inRangeValues.count);

    CPTPolarPlotSpace *thePlotSpace = self.plotSpace;

    [self.plot setThetaValues:inRangeValues];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:YES numberOfPoints:inRangeValues.count];

    for ( NSUInteger i = 0; i < inRangeValues.count; i++ ) {
        if ( [self.plotSpace.xRange compareToNumber:inRangeValues[i]] == CPTPlotRangeComparisonResultNumberInRange ) {
            XCTAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%@).", inRangeValues[i]);
        }
        else {
            XCTAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%@).", inRangeValues[i]);
        }
    }

    free(drawFlags);
}

@end
