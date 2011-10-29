#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTFillTests.h"
#import "CPTGradient.h"
#import "CPTImage.h"
#import "_CPTFillColor.h"
#import "_CPTFillGradient.h"
#import "_CPTFillImage.h"

@interface _CPTFillColor()

@property (nonatomic, readwrite, copy) CPTColor *fillColor;

@end

#pragma mark -

@interface _CPTFillGradient()

@property (nonatomic, readwrite, copy) CPTGradient *fillGradient;

@end

#pragma mark -

@interface _CPTFillImage()

@property (nonatomic, readwrite, copy) CPTImage *fillImage;

@end

#pragma mark -

@implementation CPTFillTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTripColor
{
	_CPTFillColor *fill = (_CPTFillColor *)[CPTFill fillWithColor:[CPTColor redColor]];

	_CPTFillColor *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

	STAssertEqualObjects(fill.fillColor, newFill.fillColor, @"Fill with color not equal");
}

-(void)testKeyedArchivingRoundTripGradient
{
	_CPTFillGradient *fill = (_CPTFillGradient *)[CPTFill fillWithGradient:[CPTGradient rainbowGradient]];

	_CPTFillGradient *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

	STAssertEqualObjects(fill.fillGradient, newFill.fillGradient, @"Fill with gradient not equal");
}

-(void)testKeyedArchivingRoundTripImage
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgImage		   = CGImageCreate(100, 100, 8, 32, 400, colorSpace, kCGBitmapAlphaInfoMask, NULL, NULL, YES, kCGRenderingIntentDefault);

	CPTImage *image = [CPTImage imageWithCGImage:cgImage];

	image.tiled					= YES;
	image.tileAnchoredToContext = YES;

	CGColorSpaceRelease(colorSpace);
	CGImageRelease(cgImage);

	_CPTFillImage *fill = (_CPTFillImage *)[CPTFill fillWithImage:image];

	_CPTFillImage *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

	STAssertEqualObjects(fill.fillImage, newFill.fillImage, @"Fill with image not equal");
}

@end
