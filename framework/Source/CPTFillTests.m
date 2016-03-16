#import "CPTFillTests.h"

#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTImage.h"
#import "_CPTFillColor.h"
#import "_CPTFillGradient.h"
#import "_CPTFillImage.h"

@interface _CPTFillColor()

@property (nonatomic, readwrite, copy, nonnull) CPTColor *fillColor;

@end

#pragma mark -

@interface _CPTFillGradient()

@property (nonatomic, readwrite, copy, nonnull) CPTGradient *fillGradient;

@end

#pragma mark -

@interface _CPTFillImage()

@property (nonatomic, readwrite, copy, nonnull) CPTImage *fillImage;

@end

#pragma mark -

@implementation CPTFillTests

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTripColor
{
    _CPTFillColor *fill = (_CPTFillColor *)[CPTFill fillWithColor:[CPTColor redColor]];

    _CPTFillColor *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

    XCTAssertEqualObjects(fill.fillColor, newFill.fillColor, @"Fill with color not equal");
}

-(void)testKeyedArchivingRoundTripGradient
{
    _CPTFillGradient *fill = (_CPTFillGradient *)[CPTFill fillWithGradient:[CPTGradient rainbowGradient]];

    _CPTFillGradient *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

    XCTAssertEqualObjects(fill.fillGradient, newFill.fillGradient, @"Fill with gradient not equal");
}

-(void)testKeyedArchivingRoundTripImage
{
    const size_t width  = 100;
    const size_t height = 100;

    size_t bytesPerRow = (4 * width + 15) & ~15ul;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
#else
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
#endif
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef cgImage   = CGBitmapContextCreateImage(context);

    CPTImage *image = [CPTImage imageWithCGImage:cgImage];

    image.tiled                 = YES;
    image.tileAnchoredToContext = YES;

    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);

    _CPTFillImage *fill = (_CPTFillImage *)[CPTFill fillWithImage:image];

    _CPTFillImage *newFill = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:fill]];

    XCTAssertEqualObjects(fill.fillImage, newFill.fillImage, @"Fill with image not equal");
}

@end
