#import "CPColor.h"
#import "CPTextStyle.h"
#import "CPTextStyleTests.h"
#import <QuartzCore/QuartzCore.h>

@implementation CPTextStyleTests

-(void)testDefaults 
{
	
	CPTextStyle *textStyle= [CPTextStyle textStyle];
	
	STAssertEqualObjects(@"Helvetica", textStyle.fontName, @"Default font name is not Helvetica");
	STAssertEquals((CGFloat)12.0, textStyle.fontSize, @"Default font size is not 12.0");
	STAssertEqualObjects([CPColor blackColor], textStyle.color, @"Default color is not [CPColor blackColor]");
}

@end
