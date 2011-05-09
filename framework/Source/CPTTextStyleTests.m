#import "CPTColor.h"
#import "CPTMutableTextStyle.h"
#import "CPTTextStyleTests.h"
#import <QuartzCore/QuartzCore.h>

@implementation CPTTextStyleTests

-(void)testDefaults 
{
	
	CPTMutableTextStyle *textStyle= [CPTMutableTextStyle textStyle];
	
	STAssertEqualObjects(@"Helvetica", textStyle.fontName, @"Default font name is not Helvetica");
	STAssertEquals((CGFloat)12.0, textStyle.fontSize, @"Default font size is not 12.0");
	STAssertEqualObjects([CPTColor blackColor], textStyle.color, @"Default color is not [CPTColor blackColor]");
}

@end
