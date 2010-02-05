
#import "CPScatterPlotTests.h"


@interface CPScatterPlot (Testing)

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotRange:(CPPlotRange *)aPlotRange;
-(void)setXValues:(NSArray *)newValues;

@end


@implementation CPScatterPlotTests

@synthesize plot;
@synthesize plotRange;

-(void)setUp 
{
    self.plot = [[CPScatterPlot new] autorelease];
    self.plotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(1)];
}

-(void)tearDown
{
	self.plot = nil;
    self.plotRange = nil;
}

-(void)testCalculatePointsToDrawAllInRange
{
	BOOL drawFlags[5];
	double inRangeValues[5] = {0.1, 0.2, 0.15, 0.6, 0.9};
	NSMutableArray *values = [NSMutableArray array];
    for ( NSInteger i = 0; i < 5; ++i ) [values addObject:[NSNumber numberWithDouble:inRangeValues[i]]];
	[self.plot setXValues:values];
    [self.plot calculatePointsToDraw:drawFlags forPlotRange:self.plotRange];
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
    [self.plot calculatePointsToDraw:drawFlags forPlotRange:self.plotRange];
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
    [self.plot calculatePointsToDraw:drawFlags forPlotRange:self.plotRange];
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
    [self.plot calculatePointsToDraw:drawFlags forPlotRange:self.plotRange];
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
    [self.plot calculatePointsToDraw:drawFlags forPlotRange:self.plotRange];
    NSUInteger count = 0, expected = 4;
    for ( NSInteger i = 0; i < 5; ++i ) {
    	if ( drawFlags[i] ) ++count;
    }
    STAssertEquals(count, expected, @"Test that correct points included when some are in range, others out, crossing range.");
}
    
@end
