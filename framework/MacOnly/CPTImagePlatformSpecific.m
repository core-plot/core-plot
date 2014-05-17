#import "CPTImage.h"

@implementation CPTImage(CPTPlatformSpecificImageExtensions)

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a CPTImage instance with the provided platform-native image.
 *
 *  @param anImage The platform-native image.
 *  @return A CPTImage instance initialized with the provided image.
 **/
-(instancetype)initWithNativeImage:(CPTNativeImage *)anImage
{
    if ( (self = [self init]) ) {
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
-(instancetype)initForPNGFile:(NSString *)path
{
    CGFloat imageScale = CPTFloat(1.0);

    // Try to load @2x file if the system supports hi-dpi display
    NSImage *newNativeImage = nil;
    NSImageRep *imageRep    = nil;

    for ( NSScreen *screen in [NSScreen screens] ) {
        imageScale = MAX(imageScale, screen.backingScaleFactor);
    }

    if ( imageScale > CPTFloat(1.0) ) {
        NSMutableString *hiDpiPath = [path mutableCopy];
        NSUInteger replaceCount    = [hiDpiPath replaceOccurrencesOfString:@".png"
                                                                withString:@"@2x.png"
                                                                   options:NSCaseInsensitiveSearch | NSBackwardsSearch | NSAnchoredSearch
                                                                     range:NSMakeRange(hiDpiPath.length - 4, 4)];
        if ( replaceCount == 1 ) {
            imageRep = [NSImageRep imageRepWithContentsOfFile:path];
            if ( imageRep ) {
                NSSize size = imageRep.size;
                size.width   *= CPTFloat(0.5);
                size.height  *= CPTFloat(0.5);
                imageRep.size = size;
                [newNativeImage addRepresentation:imageRep];
            }
        }
    }

    imageRep = [NSImageRep imageRepWithContentsOfFile:path];
    if ( imageRep ) {
        [newNativeImage addRepresentation:imageRep];
    }

    return [self initWithNativeImage:newNativeImage];
}

@end
