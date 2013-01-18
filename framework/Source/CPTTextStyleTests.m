#import "CPTColor.h"
#import "CPTDefinitions.h"
#import "CPTTextStyle.h"
#import "CPTTextStyleTests.h"

@implementation CPTTextStyleTests

-(void)testDefaults
{
    CPTTextStyle *textStyle = [CPTTextStyle textStyle];

    STAssertEqualObjects(@"Helvetica", textStyle.fontName, @"Default font name is not Helvetica");
    STAssertEquals(CPTFloat(12.0), textStyle.fontSize, @"Default font size is not 12.0");
    STAssertEqualObjects([CPTColor blackColor], textStyle.color, @"Default color is not [CPTColor blackColor]");
}

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    CPTTextStyle *textStyle = [CPTTextStyle textStyle];

    CPTTextStyle *newTextStyle = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:textStyle]];

    STAssertEqualObjects(newTextStyle.fontName, textStyle.fontName, @"Font names not equal");
    STAssertEquals(newTextStyle.fontSize, textStyle.fontSize, @"Font sizes not equal");
    STAssertEqualObjects(newTextStyle.color, textStyle.color, @"Font colors not equal");
    STAssertEquals(newTextStyle.textAlignment, textStyle.textAlignment, @"Text alignments not equal");
}

@end
