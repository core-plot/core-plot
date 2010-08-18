#import "CPPlotRangeTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPPlotRangeTests()

-(void)checkRangeWithLocation:(double)loc length:(double)len;

@end

#pragma mark -

@implementation CPPlotRangeTests

@synthesize plotRange;

-(void)setUp 
{
    self.plotRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(1.0) length:CPDecimalFromDouble(2.0)];
}

-(void)tearDown
{
	self.plotRange = nil;
}

#pragma mark -
#pragma mark Checking Ranges

-(void)testContains
{
	STAssertFalse([self.plotRange contains:CPDecimalFromDouble(0.999)], @"Test contains:0.999");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(1.0)], @"Test contains:1.0");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(2.0)], @"Test contains:2.0");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(3.0)], @"Test contains:3.0");
	STAssertFalse([self.plotRange contains:CPDecimalFromDouble(3.001)], @"Test contains:3.001");
}

-(void)testContainsNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	STAssertFalse([self.plotRange contains:CPDecimalFromDouble(-1.001)], @"Test contains:-1.001");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(-1.0)], @"Test contains:-1.0");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(0.0)], @"Test contains:0.0");
	STAssertTrue([self.plotRange contains:CPDecimalFromDouble(1.0)], @"Test contains:1.0");
	STAssertFalse([self.plotRange contains:CPDecimalFromDouble(1.001)], @"Test contains:1.001");
}

-(void)testContainsDouble
{
	STAssertFalse([self.plotRange containsDouble:0.999], @"Test contains:0.999");
	STAssertTrue([self.plotRange containsDouble:1.0], @"Test contains:1.0");
	STAssertTrue([self.plotRange containsDouble:2.0], @"Test contains:2.0");
	STAssertTrue([self.plotRange containsDouble:3.0], @"Test contains:3.0");
	STAssertFalse([self.plotRange containsDouble:3.001], @"Test contains:3.001");
}

-(void)testContainsDoubleNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	STAssertFalse([self.plotRange containsDouble:-1.001], @"Test contains:-1.001");
	STAssertTrue([self.plotRange containsDouble:-1.0], @"Test contains:-1.0");
	STAssertTrue([self.plotRange containsDouble:0.0], @"Test contains:0.0");
	STAssertTrue([self.plotRange containsDouble:1.0], @"Test contains:1.0");
	STAssertFalse([self.plotRange containsDouble:1.001], @"Test contains:1.001");
}

#pragma mark -
#pragma mark Union

-(void)testUnionRange
{
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:0.0 length:4.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:-1.0 length:5.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:-1.0 length:8.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-4.0 length:11.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-5.0 length:12.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-5.0 length:12.0];
}

-(void)testUnionRangeNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:4.0 length:-5.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:4.0 length:-5.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:7.0 length:-8.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:7.0 length:-11.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:7.0 length:-12.0];
	
	[self.plotRange unionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:7.0 length:-12.0];
}

#pragma mark -
#pragma mark Intersection

-(void)testIntersectRange
{
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:1.0 length:2.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:1.0 length:1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:1.0 length:0.0];
}

-(void)testIntersectRange2
{
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(4.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:1.0 length:2.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(2.0) length:CPDecimalFromDouble(-1.0)]];
	[self checkRangeWithLocation:1.0 length:1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:1.0 length:0.0];
}

-(void)testIntersectRangeNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:1.0 length:-1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:1.0 length:-1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:1.0 length:0.0];
}

-(void)testIntersectRangeNegative2
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:0.0 length:-1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(2.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:0.0 length:-1.0];
	
	[self.plotRange intersectionPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:0.0 length:0.0];
}

#pragma mark -
#pragma mark Shifting Ranges

-(void)testShiftLocation
{
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:1.0 length:2.0];

	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:0.0 length:2.0];

	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:5.0 length:2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:0.0 length:2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-1.0 length:2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:1.0 length:2.0];
}

-(void)testShiftLocationNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);

	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:1.0 length:-2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:0.0 length:-2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:5.0 length:-2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:0.0 length:-2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-1.0 length:-2.0];
	
	[self.plotRange shiftLocationToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:1.0 length:-2.0];
}

-(void)testShiftEnd
{
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:1.0 length:2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:-2.0 length:2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:3.0 length:2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-2.0 length:2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-3.0 length:2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:-1.0 length:2.0];
}

-(void)testShiftEndNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(4.0)]];
	[self checkRangeWithLocation:2.0 length:-2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(1.0)]];
	[self checkRangeWithLocation:2.0 length:-2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(2.0)]];
	[self checkRangeWithLocation:7.0 length:-2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:2.0 length:-2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:1.0 length:-2.0];
	
	[self.plotRange shiftEndToFitInRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(5.0) length:CPDecimalFromDouble(-4.0)]];
	[self checkRangeWithLocation:3.0 length:-2.0];
}

#pragma mark -
#pragma mark Expand Range

-(void)testExpandRangeHalf
{
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(0.5)];
	[self checkRangeWithLocation:1.5 length:1.0];
}

-(void)testExpandRangeSame
{
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(1.0)];
	[self checkRangeWithLocation:1.0 length:2.0];
}

-(void)testExpandRangeDouble
{
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(2.0)];
	[self checkRangeWithLocation:0.0 length:4.0];
}

-(void)testExpandRangeHalfNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(0.5)];
	[self checkRangeWithLocation:0.5 length:-1.0];
}

-(void)testExpandRangeSameNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(1.0)];
	[self checkRangeWithLocation:1.0 length:-2.0];
}

-(void)testExpandRangeDoubleNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	[self.plotRange expandRangeByFactor:CPDecimalFromDouble(2.0)];
	[self checkRangeWithLocation:2.0 length:-4.0];
}

#pragma mark -
#pragma mark Comparing Ranges

-(void)testCompareToDecimal
{
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(0.999)], CPPlotRangeComparisonResultNumberBelowRange, @"Test compareTo:0.999");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(1.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:1.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(2.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:2.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(3.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:3.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(3.001)], CPPlotRangeComparisonResultNumberAboveRange, @"Test compareTo:3.001");
}

-(void)testCompareToDecimalNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(-1.001)], CPPlotRangeComparisonResultNumberBelowRange, @"Test compareTo:-1.001");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(-1.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:-1.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(0.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:0.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(1.0)], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:1.0");
	STAssertEquals([self.plotRange compareToDecimal:CPDecimalFromDouble(1.001)], CPPlotRangeComparisonResultNumberAboveRange, @"Test compareTo:1.001");
}

-(void)testCompareToDouble
{
	STAssertEquals([self.plotRange compareToDouble:0.999], CPPlotRangeComparisonResultNumberBelowRange, @"Test compareTo:0.999");
	STAssertEquals([self.plotRange compareToDouble:1.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:1.0");
	STAssertEquals([self.plotRange compareToDouble:2.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:2.0");
	STAssertEquals([self.plotRange compareToDouble:3.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:3.0");
	STAssertEquals([self.plotRange compareToDouble:3.001], CPPlotRangeComparisonResultNumberAboveRange, @"Test compareTo:3.001");
}

-(void)testCompareToDoubleNegative
{
	self.plotRange.length = CPDecimalFromDouble(-2.0);
	
	STAssertEquals([self.plotRange compareToDouble:-1.001], CPPlotRangeComparisonResultNumberBelowRange, @"Test compareTo:-1.001");
	STAssertEquals([self.plotRange compareToDouble:-1.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:-1.0");
	STAssertEquals([self.plotRange compareToDouble:0.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:0.0");
	STAssertEquals([self.plotRange compareToDouble:1.0], CPPlotRangeComparisonResultNumberInRange, @"Test compareTo:1.0");
	STAssertEquals([self.plotRange compareToDouble:1.001], CPPlotRangeComparisonResultNumberAboveRange, @"Test compareTo:1.001");
}

#pragma mark -
#pragma mark Private Methods

-(void)checkRangeWithLocation:(double)loc length:(double)len
{
	NSDecimal newLocation = self.plotRange.location;
	STAssertTrue(CPDecimalEquals(newLocation, CPDecimalFromDouble(loc)), [NSString stringWithFormat:@"expected location = %g, was %@", loc, NSDecimalString(&newLocation, nil)]);
	NSDecimal newLength = self.plotRange.length;
	STAssertTrue(CPDecimalEquals(newLength, CPDecimalFromDouble(len)), [NSString stringWithFormat:@"expected length = %g, was %@", len, NSDecimalString(&newLength, nil)]);
}

@end
