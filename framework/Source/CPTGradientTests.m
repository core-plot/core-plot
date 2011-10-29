#import "CPTGradient.h"
#import "CPTGradientTests.h"

@implementation CPTGradientTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTrip
{
	CPTGradient *gradient = [CPTGradient rainbowGradient];

	CPTGradient *newGradient = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:gradient]];

	STAssertEqualObjects(gradient, newGradient, @"Gradients not equal");
}

@end
