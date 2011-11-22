#import "CPTColor.h"
#import "CPTColorTests.h"

@implementation CPTColorTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTrip
{
	CPTColor *color = [CPTColor redColor];

	CPTColor *newColor = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:color]];

	STAssertEqualObjects(color, newColor, @"Colors not equal");
}

@end
