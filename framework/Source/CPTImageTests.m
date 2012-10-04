#import "CPTImage.h"
#import "CPTImageTests.h"

@implementation CPTImageTests

#pragma mark -
#pragma mark NSCoding Methods

-(void)testKeyedArchivingRoundTrip
{
    const size_t width  = 100;
    const size_t height = 100;

    size_t bytesPerRow         = (4 * width + 15) & ~15ul;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context       = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef cgImage         = CGBitmapContextCreateImage(context);

    CPTImage *image = [CPTImage imageWithCGImage:cgImage];

    image.tiled                 = YES;
    image.tileAnchoredToContext = YES;

    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);

    CPTImage *newImage = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:image]];

    STAssertEqualObjects(image, newImage, @"Images not equal");
}

@end
