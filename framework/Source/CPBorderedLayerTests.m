
#import "CPBorderedLayerTests.h"
#import "CPBorderedLayer.h"
#import "CPLineStyle.h"
#import "CPColor.h"
#import "CPFill.h"
#import "CPGradient.h"

@implementation CPBorderedLayerTests

- (void)testRenderingCornerRadius
{
    CPBorderedLayer *layer = [CPBorderedLayer layer];
    layer.bounds = CGRectMake(0, 0, 100, 100);

    layer.borderLineStyle = [CPLineStyle lineStyle];
    layer.borderLineStyle.lineColor = [CPColor blackColor];
    layer.borderLineStyle.lineWidth = 3.0f;
    layer.fill = [CPFill fillWithColor:[CPColor blueColor]];
    
    layer.cornerRadius = 10;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingCornerRadius-10", @"");
    
    layer.cornerRadius = 0;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingCornerRadius-0", @"");
    
    layer.cornerRadius = 1;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingCornerRadius-1", @"");
    
    layer.cornerRadius = layer.bounds.size.width;
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingCornerRadius-bounds.size.width", @"");
}

- (void)testRenderingLineStyle
{
    CPBorderedLayer *layer = [CPBorderedLayer layer];
    layer.bounds = CGRectMake(0, 0, 100, 100);
    
    layer.cornerRadius = 5;
    layer.fill = [CPFill fillWithColor:[CPColor blueColor]];
    
    CPLineStyle *lineStyle = [CPLineStyle lineStyle];
    
    lineStyle.lineColor = [CPColor redColor];
    lineStyle.lineCap = kCGLineCapButt;
    lineStyle.lineJoin = kCGLineJoinBevel;
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0f;
    layer.borderLineStyle = lineStyle;
    
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingLineStyle-1",@"");
    
    lineStyle.lineColor = [CPColor greenColor];
    lineStyle.lineCap = kCGLineCapRound;
    lineStyle.lineJoin = kCGLineJoinMiter;
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 5.0f;
    layer.borderLineStyle = lineStyle;
    
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingLineStyle-2",@"");
    
    
}

- (void)testRenderingFill
{
    CPBorderedLayer *layer = [CPBorderedLayer layer];
    layer.bounds = CGRectMake(0, 0, 100, 100);
    
    layer.borderLineStyle = [CPLineStyle lineStyle];
    layer.cornerRadius = 5.0f;
    
    layer.fill = [CPFill fillWithColor:[CPColor redColor]];
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingFill-Red", @"");
    
    layer.fill = [CPFill fillWithGradient:[CPGradient gradientWithBeginningColor:[CPColor blueColor] endingColor:[CPColor redColor]]];
    GTMAssertObjectImageEqualToImageNamed(layer, @"CPBorderedLayerTests-testRenderingFill-Blue-Red-Gradient", @"");
}
@end
