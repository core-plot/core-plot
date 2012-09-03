#import "CPTLineStyle.h"
#import "CPTLineStyleTests.h"

@implementation CPTLineStyleTests

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTLineStyle *lineStyle = [CPTLineStyle lineStyle];

    CPTLineStyle *newLineStyle = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:lineStyle]];

    STAssertEquals(newLineStyle.lineCap, lineStyle.lineCap, @"Line cap not equal");
    STAssertEquals(newLineStyle.lineJoin, lineStyle.lineJoin, @"Line join not equal");
    STAssertEquals(newLineStyle.miterLimit, lineStyle.miterLimit, @"Miter limit not equal");
    STAssertEquals(newLineStyle.lineWidth, lineStyle.lineWidth, @"Line width not equal");
    STAssertEqualObjects(newLineStyle.dashPattern, lineStyle.dashPattern, @"Dash pattern not equal");
    STAssertEquals(newLineStyle.patternPhase, lineStyle.patternPhase, @"Pattern phase not equal");
    STAssertEqualObjects(newLineStyle.lineColor, lineStyle.lineColor, @"Line colors not equal");
}

@end
