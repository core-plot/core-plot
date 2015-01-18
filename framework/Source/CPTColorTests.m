#import "CPTColorTests.h"

#import "CPTColor.h"

@implementation CPTColorTests

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTColor *color = [CPTColor redColor];

    CPTColor *newColor = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:color]];

    XCTAssertEqualObjects(color, newColor, @"Colors not equal");
}

@end
