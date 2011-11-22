#import "CPTScatterPlotTests.h"

@interface CPTScatterPlot(Testing)

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPTXYPlotSpace *)aPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)setXValues:(NSArray *)newValues;
-(void)setYValues:(NSArray *)newValues;

@end

@implementation CPTScatterPlotTests

@synthesize plot;
@synthesize plotSpace;

-(void)setUp
{
	double values[5] = { 0.5, 0.5, 0.5, 0.5, 0.5 };

	self.plot = [[CPTScatterPlot new] autorelease];
	NSMutableArray *yValues = [NSMutableArray array];
	for ( NSInteger i = 0; i < 5; i++ ) {
		[yValues addObject:[NSNumber numberWithDouble:values[i]]];
	}
	[self.plot setYValues:yValues];

	CPTPlotRange *xPlotRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
	CPTPlotRange *yPlotRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(1)];
	self.plotSpace		  = [[[CPTXYPlotSpace alloc] init] autorelease];
	self.plotSpace.xRange = xPlotRange;
	self.plotSpace.yRange = yPlotRange;
}

-(void)tearDown
{
	self.plot	   = nil;
	self.plotSpace = nil;
}

-(void)testCalculatePointsToDrawAllInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { 0.1, 0.2, 0.15, 0.6, 0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertTrue(drawFlags[i], @"Test that in range points are drawn (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawAllInRangeVisibleOnly
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { 0.1, 0.2, 0.15, 0.6, 0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:YES];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertTrue(drawFlags[i], @"Test that in range points are drawn (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawNoneInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, -0.2, -0.15, -0.6, -0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertFalse(drawFlags[i], @"Test that out of range points are not drawn (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawNoneInRangeVisibleOnly
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, -0.2, -0.15, -0.6, -0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:YES];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertFalse(drawFlags[i], @"Test that out of range points are not drawn (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawNoneInRangeDifferentRegions
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 2, -0.15, 3, -0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertTrue(drawFlags[i], @"Test that out of range points in different regions get included (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawNoneInRangeDifferentRegionsVisibleOnly
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 2, -0.15, 3, -0.9 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:YES];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		STAssertFalse(drawFlags[i], @"Test that out of range points in different regions get included (%g).", inRangeValues[i]);
	}
}

-(void)testCalculatePointsToDrawSomeInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 0.1, 0.2, 1.2, 1.5 };
	BOOL expected[5]		= { YES, YES, YES, YES, NO };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		if ( expected[i] ) {
			STAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out (%g).", inRangeValues[i]);
		}
		else {
			STAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out (%g).", inRangeValues[i]);
		}
	}
}

-(void)testCalculatePointsToDrawSomeInRangeVisibleOnly
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 0.1, 0.2, 1.2, 1.5 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:YES];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		if ( [self.plotSpace.xRange compareToNumber:[NSNumber numberWithDouble:inRangeValues[i]]] == CPTPlotRangeComparisonResultNumberInRange ) {
			STAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out (%g).", inRangeValues[i]);
		}
		else {
			STAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out (%g).", inRangeValues[i]);
		}
	}
}

-(void)testCalculatePointsToDrawSomeInRangeCrossing
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 1.1, 0.9, -0.1, -0.2 };
	BOOL expected[5]		= { YES, YES, YES, YES, NO };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:NO];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		if ( expected[i] ) {
			STAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%g).", inRangeValues[i]);
		}
		else {
			STAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%g).", inRangeValues[i]);
		}
	}
}

-(void)testCalculatePointsToDrawSomeInRangeCrossingVisibleOnly
{
	BOOL drawFlags[5];
	double inRangeValues[5] = { -0.1, 1.1, 0.9, -0.1, -0.2 };
	NSMutableArray *values	= [NSMutableArray array];

	for ( NSUInteger i = 0; i < 5; i++ ) {
		[values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	}
	[self.plot setXValues:values];
	[self.plot calculatePointsToDraw:drawFlags forPlotSpace:self.plotSpace includeVisiblePointsOnly:YES];
	for ( NSUInteger i = 0; i < 5; i++ ) {
		if ( [self.plotSpace.xRange compareToNumber:[NSNumber numberWithDouble:inRangeValues[i]]] == CPTPlotRangeComparisonResultNumberInRange ) {
			STAssertTrue(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%g).", inRangeValues[i]);
		}
		else {
			STAssertFalse(drawFlags[i], @"Test that correct points included when some are in range, others out, crossing range (%g).", inRangeValues[i]);
		}
	}
}

@end
