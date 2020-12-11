#import <TargetConditionals.h>

#if TARGET_OS_OSX

#import "CPTImage.h"

@implementation CPTImage(CPTPlatformSpecificImageExtensions)

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a CPTImage instance with the provided platform-native image.
 *
 *  @param anImage The platform-native image.
 *  @return A CPTImage instance initialized with the provided image.
 **/
-(nonnull instancetype)initWithNativeImage:(nullable CPTNativeImage *)anImage
{
    if ((self = [self init])) {
        self.nativeImage = anImage;
    }

    return self;
}

/** @brief Initializes a CPTImage instance with the contents of a PNG file.
 *
 *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
 *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
 *  is not available, the named image file will be loaded.
 *
 *  @param path The file system path of the file.
 *  @return A CPTImage instance initialized with the contents of the PNG file.
 **/
-(nonnull instancetype)initForPNGFile:(nonnull NSString *)path
{
    CGFloat imageScale = CPTFloat(1.0);

    // Try to load @2x file if the system supports hi-dpi display
    NSImage *newNativeImage = [[NSImage alloc] init];
    NSImageRep *imageRep    = nil;

    for ( NSScreen *screen in [NSScreen screens] ) {
        imageScale = MAX(imageScale, screen.backingScaleFactor);
    }

    while ( imageScale > CPTFloat(1.0)) {
        NSMutableString *hiDpiPath = [path mutableCopy];
        NSUInteger replaceCount    = [hiDpiPath replaceOccurrencesOfString:@".png"
                                                                withString:[NSString stringWithFormat:@"@%dx.png", (int)imageScale]
                                                                   options:NSCaseInsensitiveSearch | NSBackwardsSearch | NSAnchoredSearch
                                                                     range:NSMakeRange(hiDpiPath.length - 4, 4)];
        if ( replaceCount == 1 ) {
            imageRep = [NSImageRep imageRepWithContentsOfFile:hiDpiPath];
            if ( imageRep ) {
                [newNativeImage addRepresentation:imageRep];
            }
        }
        imageScale -= CPTFloat(1.0);
    }

    imageRep = [NSImageRep imageRepWithContentsOfFile:path];
    if ( imageRep ) {
        [newNativeImage addRepresentation:imageRep];
    }

    return [self initWithNativeImage:newNativeImage];
}

@end

#else

#import "CPTImage.h"

#import "CPTUtilities.h"

@implementation CPTImage(CPTPlatformSpecificImageExtensions)

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a CPTImage instance with the provided platform-native image.
 *
 *  @param anImage The platform-native image.
 *  @return A CPTImage instance initialized with the provided image.
 **/
-(nonnull instancetype)initWithNativeImage:(nullable CPTNativeImage *)anImage
{
    if ((self = [self initWithCGImage:NULL scale:anImage.scale])) {
        self.nativeImage = anImage;

        UIEdgeInsets insets = anImage.capInsets;
        self.edgeInsets = CPTEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
    }

    return self;
}

/** @brief Initializes a CPTImage instance with the contents of a PNG file.
 *
 *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
 *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
 *  is not available, the named image file will be loaded.
 *
 *  @param path The file system path of the file.
 *  @return A CPTImage instance initialized with the contents of the PNG file.
 **/
-(nonnull instancetype)initForPNGFile:(nonnull NSString *)path
{
    CGFloat imageScale = CPTFloat(1.0);

    // Try to load @2x file if the system supports hi-dpi display
    CGDataProviderRef dataProvider = NULL;
    CGImageRef cgImage             = NULL;

    for ( UIScreen *screen in [UIScreen screens] ) {
        imageScale = MAX(imageScale, screen.scale);
    }

    if ( imageScale > CPTFloat(1.0)) {
        NSMutableString *hiDpiPath = [path mutableCopy];
        NSUInteger replaceCount    = [hiDpiPath replaceOccurrencesOfString:@".png"
                                                                withString:[NSString stringWithFormat:@"@%dx.png", (int)imageScale]
                                                                   options:NSCaseInsensitiveSearch | NSBackwardsSearch | NSAnchoredSearch
                                                                     range:NSMakeRange(hiDpiPath.length - 4, 4)];
        if ( replaceCount == 1 ) {
            dataProvider = CGDataProviderCreateWithFilename([hiDpiPath cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        if ( !dataProvider ) {
            imageScale = CPTFloat(1.0);
        }
    }

    // if hi-dpi display or @2x image not available, load the 1x image at the original path
    if ( !dataProvider ) {
        dataProvider = CGDataProviderCreateWithFilename([path cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    if ( dataProvider ) {
        cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, YES, kCGRenderingIntentDefault);
    }

    if ( cgImage ) {
        self = [self initWithCGImage:cgImage scale:imageScale];
    }
    else {
        self = nil;
    }
    CGImageRelease(cgImage);
    CGDataProviderRelease(dataProvider);
    return self;
}

@end

#endif
