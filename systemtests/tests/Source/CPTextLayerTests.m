#import "CPColor.h"
#import "CPTextLayerTests.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"
#import <QuartzCore/QuartzCore.h>

@interface CPTextLayer (UnitTesting)
-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder;
@end

@implementation CPTextLayer (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder
{
	[super gtm_unitTestEncodeState:inCoder];
	
	[inCoder encodeObject:self.text forKey:@"Text"];
	[self.textStyle encodeWithCoder:inCoder];
	[inCoder encodeRect:NSRectFromCGRect([self frame]) forKey:@"FrameRect"];
}

@end

@implementation CPTextLayerTests

-(void)testInitWithText
{
    NSString *expectedString = @"testInit-expectedString";
    
    CPTextLayer *layer = [[CPTextLayer alloc] initWithText:expectedString];
    
    GTMAssertObjectStateEqualToStateNamed(layer, @"CPTextLayerTests-testInit1", @"state following initWithText: is incorrect");
	
	[layer release];
}

-(void)testInitWithTextStyle
{
    NSString *expectedString = @"testInit-expectedString";
    CPTextStyle *expectedStyle = [[CPTextStyle alloc] init];
	
    CPTextLayer *layer = [[CPTextLayer alloc] initWithText:expectedString style:expectedStyle];
    
	[expectedStyle release];
	
    GTMAssertObjectStateEqualToStateNamed(layer, @"CPTextLayerTests-testInit2", @"state following initWithText:style: is incorrect");
	
	[layer release];
}

-(void)testDrawInContext
{
    CPTextLayer *layer = [[CPTextLayer alloc] initWithText:@"testInit-expectedString"];
    
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering1", @"Rendered image does not match");
    
    layer.text = @"testInit-expectedString2";
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering2", @"Rendered image does not match");
    
	layer.text = @"testInit-expectedString3";
	layer.textStyle.fontSize = 10.;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering3", @"Rendered image does not match");
    
	layer.textStyle.fontSize = 100.;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering4", @"Rendered image does not match");
	
	layer.textStyle.color = [CPColor redColor];
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering5", @"Rendered image does not match");
	
	layer.textStyle.fontName = @"Times-BoldItalic";
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPTextLayerTests-testRendering6", @"Rendered image does not match");
	
	[layer release];
}

@end
