
#import "CPScatterPlotTests.h"


@interface CPScatterPlot (Testing)

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)aPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)setXValues:(NSArray *)newValues;
-(void)setYValues:(NSArray *)newValues;

@end


@implementation CPScatterPlotTests

@synthesize plot;
@synthesize plotSpace;

-(void)setUp 
{
	double values[5] = {0.5, 0.5, 0.5, 0.5, 0.5};
    self.plot = [[CPScatterPlot new] autorelease];
	NSMutableArray *yValues = [NSMutableArray array];
	for ( NSInteger i = 0; i < 5; ++i ) [yValues addObject:[NSNumber numberWithDouble:values[i]]];
	[self.plot setYValues:yValues];

    CPPlotRange *xPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(0) length:CPDecimalFromInteger(1)];
	CPPlotRange *yPlotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(0) length:CPDecimalFromInteger(1)];
	self.plotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
	self.plotSpace.xRange = xPlotRange;
	self.plotSpace.yRange = yPlotRange;
}

-(void)tearDown
{
	self.plot = nil;
    self.plotSpace = nil;
}

-(void)testCalculatePointsToDrawAllInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {0.1, 0.2, 0.15, 0.6, 0.9};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
    for ( NSInteger i = 0; i < 5; ++i ) {
        STAssertTrue(drawFlags[i], @"Test that in range points are drawn.");
    }
}

-(void)testCalculatePointsToDrawNoneInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {-0.1, -0.2, -0.15, -0.6, -0.9};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
    for ( NSInteger i = 0; i < 5; ++i ) {
        STAssertFalse(drawFlags[i], @"Test that out of range points are not drawn.");
    }
}

-(void)testCalculatePointsToDrawNoneInRangeDifferentRegions
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {-0.1, 2, -0.15, 3, -0.9};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
    for ( NSInteger i = 0; i < 5; ++i ) {
        STAssertTrue(drawFlags[i], @"Test that out of range points in different regions get included.");
    }
}

-(void)testCalculatePointsToDrawSomeInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {-0.1, 0.1, 0.2, 1.2, 1.5};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
    NSUInteger count = 0, expected = 4;
    for ( NSInteger i = 0; i < 5; ++i ) {
    	if ( drawFlags[i] ) ++count;
    }
    STAssertEquals(count, expected, @"Test that correct points included when some are in range, others out.");
}

-(void)testCalculatePointsToDrawSomeInRangeCrossing
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {-0.1, 1.1, 0.9, -0.1, -0.2};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
    NSUInteger count = 0, expected = 4;
    for ( NSInteger i = 0; i < 5; ++i ) {
    	if ( drawFlags[i] ) ++count;
    }
    STAssertEquals(count, expected, @"Test that correct points included when some are in range, others out, crossing range.");
}
    
@end
