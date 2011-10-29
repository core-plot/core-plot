#import "CPTImage.h"
#import "CPTImageTests.h"

@implementation CPTImageTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTrip
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgImage		   = CGImageCreate(100, 100, 8, 32, 400, colorSpace, kCGBitmapAlphaInfoMask, NULL, NULL, YES, kCGRenderingIntentDefault);

	CPTImage *image = [CPTImage imageWithCGImage:cgImage];

	image.tiled					= YES;
	image.tileAnchoredToContext = YES;

	CGColorSpaceRelease(colorSpace);
	CGImageRelease(cgImage);

	CPTImage *newImage = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:image]];

	STAssertEqualObjects(image, newImage, @"Images not equal");
}

@end
