#import "CPTColorTests.h"

#import "CPTColor.h"

@implementation CPTColorTests

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTColor *color = [CPTColor redColor];

    CPTColor *newColor = [self archiveRoundTrip:color];

    XCTAssertEqualObjects(color, newColor, @"Colors not equal");
}

@end
