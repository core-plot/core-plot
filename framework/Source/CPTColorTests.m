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
    
#if TARGET_OS_OSX
    // Workaround since @available macro is not there
    if ( [NSColor respondsToSelector:@selector(colorNamed:)] ) {

        color = [CPTColor colorWithNSColor:[NSColor systemRedColor]];
        
        newColor = [self archiveRoundTrip:color];
        
        XCTAssertEqualObjects(color, newColor, @"Colors not equal");
        
    }
#endif
}

@end
