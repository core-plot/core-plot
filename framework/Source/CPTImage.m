#import "CPTImage.h"

#import "CPTDefinitions.h"
#import "NSCoderExtensions.h"

/// @cond
// for MacOS 10.6 SDK compatibility
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
@interface NSScreen(CPTExtensions)

@property (readonly) CGFloat backingScaleFactor;

@end
#endif
#endif

@interface CPTImage()

@property (nonatomic, readwrite, assign) CGFloat lastDrawnScale;

@end

/// @endcond

#pragma mark -

/** @brief A bitmap image.
 *
 *  If initialized from a file or
 *  @if MacOnly NSImage, @endif
 *  @if iOSOnly UIImage, @endif
 *  and an @2x version of the image file is available, the image will be rendered correctly on
 *  Retina and non-Retina displays.
 **/

@implementation CPTImage

/** @property CPTNativeImage *nativeImage
 *  @brief A platform-native representation of the image.
 **/
@synthesize nativeImage;

/** @property CGImageRef image
 *  @brief The image drawn into a @ref CGImageRef.
 **/
@synthesize image;

/** @property CGFloat scale
 *  @brief The image scale. Must be greater than zero.
 **/
@synthesize scale;

/** @property CGFloat lastDrawnScale
 *  The scale factor used the last time the image was rendered into @ref image.
 **/
@synthesize lastDrawnScale;

/** @property BOOL tiled
 *  @brief Draw as a tiled image?
 *
 *  If @YES, the image is drawn repeatedly to fill the current clip region.
 *  Otherwise, the image is drawn one time only in the provided rectangle.
 *  The default value is @NO.
 **/
@synthesize tiled;

/** @property BOOL tileAnchoredToContext
 *  @brief Anchor the tiled image to the context origin?
 *
 *  If @YES, the origin of the tiled image is anchored to the origin of the drawing context.
 *  If @NO, the origin of the tiled image is set to the origin of the rectangle passed to
 *  @link CPTImage::drawInRect:inContext: -drawInRect:inContext: @endlink.
 *  The default value is @YES.
 *  If @ref tiled is @NO, this property has no effect.
 **/
@synthesize tileAnchoredToContext;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a CPTImage instance with the provided platform-native image.
 *
 *  @param anImage The platform-native image.
 *  @return A CPTImage instance initialized with the provided image.
 **/
-(id)initWithNativeImage:(CPTNativeImage *)anImage
{
    if ( (self = [self init]) ) {
        nativeImage = anImage;
    }
    return self;
}

/** @brief Initializes a CPTImage instance with the provided @ref CGImageRef.
 *
 *  This is the designated initializer.
 *
 *  @param anImage The image to wrap.
 *  @param newScale The image scale. Must be greater than zero.
 *  @return A CPTImage instance initialized with the provided @ref CGImageRef.
 **/
-(id)initWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale
{
    NSParameterAssert(newScale > 0.0);

    if ( (self = [super init]) ) {
        CGImageRetain(anImage);
        nativeImage           = nil;
        image                 = anImage;
        scale                 = newScale;
        lastDrawnScale        = newScale;
        tiled                 = NO;
        tileAnchoredToContext = YES;
    }
    return self;
}

/** @brief Initializes a CPTImage instance with the provided @ref CGImageRef and scale @num{1.0}.
 *  @param anImage The image to wrap.
 *  @return A CPTImage instance initialized with the provided @ref CGImageRef.
 **/
-(id)initWithCGImage:(CGImageRef)anImage
{
    return [self initWithCGImage:anImage scale:CPTFloat(1.0)];
}

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTImage object with a @NULL image.
 *  @return The initialized object.
 **/
-(id)init
{
    return [self initWithCGImage:NULL];
}

/// @}

/** @brief Initializes a CPTImage instance with the contents of a PNG file.
 *
 *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
 *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
 *  is not available, the named image file will be loaded.
 *
 *  @param path The file system path of the file.
 *  @return A CPTImage instance initialized with the contents of the PNG file.
 **/
-(id)initForPNGFile:(NSString *)path
{
    return [self initWithNativeImage:[[CPTNativeImage alloc] initWithContentsOfFile:path]];
}

/// @cond

-(void)dealloc
{
    CGImageRelease(image);
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.nativeImage forKey:@"CPTImage.nativeImage"];
    [coder encodeCGImage:self.image forKey:@"CPTImage.image"];
    [coder encodeCGFloat:self.scale forKey:@"CPTImage.scale"];
    [coder encodeCGFloat:self.lastDrawnScale forKey:@"CPTImage.lastDrawnScale"];
    [coder encodeBool:self.tiled forKey:@"CPTImage.tiled"];
    [coder encodeBool:self.tileAnchoredToContext forKey:@"CPTImage.tileAnchoredToContext"];

    // lastDrawnScale
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        nativeImage           = [[coder decodeObjectForKey:@"CPTImage.nativeImage"] copy];
        image                 = [coder newCGImageDecodeForKey:@"CPTImage.image"];
        scale                 = [coder decodeCGFloatForKey:@"CPTImage.scale"];
        lastDrawnScale        = [coder decodeCGFloatForKey:@"CPTImage.lastDrawnScale"];
        tiled                 = [coder decodeBoolForKey:@"CPTImage.tiled"];
        tileAnchoredToContext = [coder decodeBoolForKey:@"CPTImage.tileAnchoredToContext"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTImage *copy = [[[self class] allocWithZone:zone] init];

    copy->nativeImage           = [self->nativeImage copy];
    copy->image                 = CGImageCreateCopy(self->image);
    copy->scale                 = self->scale;
    copy->lastDrawnScale        = self->lastDrawnScale;
    copy->tiled                 = self->tiled;
    copy->tileAnchoredToContext = self->tileAnchoredToContext;

    return copy;
}

/// @endcond

#pragma mark -
#pragma mark Factory Methods

/** @brief Initializes a CPTImage instance with the named image.
 *
 *  @param name The name of the image to load.
 *  @return A new CPTImage instance initialized with the named image.
 **/
+(CPTImage *)imageNamed:(NSString *)name
{
    return [self imageWithNativeImage:[CPTNativeImage imageNamed:name]];
}

/** @brief Initializes a CPTImage instance with the provided platform-native image.
 *
 *  @param anImage The platform-native image.
 *  @return A new CPTImage instance initialized with the provided image.
 **/
+(CPTImage *)imageWithNativeImage:(CPTNativeImage *)anImage
{
    return [[self alloc] initWithNativeImage:anImage];
}

/** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef.
 *  @param anImage The image to wrap.
 *  @param newScale The image scale.
 *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
 **/
+(CPTImage *)imageWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale
{
    return [[self alloc] initWithCGImage:anImage scale:newScale];
}

/** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef and scale @num{1.0}.
 *  @param anImage The image to wrap.
 *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
 **/
+(CPTImage *)imageWithCGImage:(CGImageRef)anImage
{
    return [[self alloc] initWithCGImage:anImage];
}

/** @brief Creates and returns a new CPTImage instance initialized with the contents of a PNG file.
 *
 *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
 *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
 *  is not available, the named image file will be loaded.
 *
 *  @param path The file system path of the file.
 *  @return A new CPTImage instance initialized with the contents of the PNG file.
 **/
+(CPTImage *)imageForPNGFile:(NSString *)path
{
    return [[self alloc] initForPNGFile:path];
}

#pragma mark -
#pragma mark Image comparison

/// @name Comparison
/// @{

/** @brief Returns a boolean value that indicates whether the received is equal to the given object.
 *  Images are equal if they have the same @ref scale, @ref tiled, @ref tileAnchoredToContext, image size, color space, bit depth, and image data.
 *  @param object The object to be compared with the receiver.
 *  @return @YES if @par{object} is equal to the receiver, @NO otherwise.
 **/
-(BOOL)isEqual:(id)object
{
    if ( self == object ) {
        return YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        CPTImage *otherImage = (CPTImage *)object;

        BOOL equalImages = (self.scale == otherImage.scale) &&
                           (self.tiled == otherImage.tiled) &&
                           (self.tileAnchoredToContext == otherImage.tileAnchoredToContext);

        CGImageRef selfCGImage  = self.image;
        CGImageRef otherCGImage = otherImage.image;

        CGColorSpaceRef selfColorSpace  = CGImageGetColorSpace(selfCGImage);
        CGColorSpaceRef otherColorSpace = CGImageGetColorSpace(otherCGImage);

        if ( equalImages ) {
            equalImages = ( CGImageGetWidth(selfCGImage) == CGImageGetWidth(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetHeight(selfCGImage) == CGImageGetHeight(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetBitsPerComponent(selfCGImage) == CGImageGetBitsPerComponent(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetBitsPerPixel(selfCGImage) == CGImageGetBitsPerPixel(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetBytesPerRow(selfCGImage) == CGImageGetBytesPerRow(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetBitmapInfo(selfCGImage) == CGImageGetBitmapInfo(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetShouldInterpolate(selfCGImage) == CGImageGetShouldInterpolate(otherCGImage) );
        }

        if ( equalImages ) {
            equalImages = ( CGImageGetRenderingIntent(selfCGImage) == CGImageGetRenderingIntent(otherCGImage) );
        }

        // decode array
        if ( equalImages ) {
            const CGFloat *selfDecodeArray  = CGImageGetDecode(selfCGImage);
            const CGFloat *otherDecodeArray = CGImageGetDecode(otherCGImage);

            if ( selfDecodeArray && otherDecodeArray ) {
                size_t numberOfComponentsSelf  = CGColorSpaceGetNumberOfComponents(selfColorSpace) * 2;
                size_t numberOfComponentsOther = CGColorSpaceGetNumberOfComponents(otherColorSpace) * 2;

                if ( numberOfComponentsSelf == numberOfComponentsOther ) {
                    for ( size_t i = 0; i < numberOfComponentsSelf; i++ ) {
                        if ( selfDecodeArray[i] != otherDecodeArray[i] ) {
                            equalImages = NO;
                            break;
                        }
                    }
                }
                else {
                    equalImages = NO;
                }
            }
            else if ( (selfDecodeArray && !otherDecodeArray) || (!selfDecodeArray && otherDecodeArray) ) {
                equalImages = NO;
            }
        }

        // color space
        if ( equalImages ) {
            equalImages = ( CGColorSpaceGetModel(selfColorSpace) == CGColorSpaceGetModel(otherColorSpace) ) &&
                          ( CGColorSpaceGetNumberOfComponents(selfColorSpace) == CGColorSpaceGetNumberOfComponents(otherColorSpace) );
        }

        // data provider
        if ( equalImages ) {
            CGDataProviderRef selfProvider  = CGImageGetDataProvider(selfCGImage);
            CFDataRef selfProviderData      = CGDataProviderCopyData(selfProvider);
            CGDataProviderRef otherProvider = CGImageGetDataProvider(otherCGImage);
            CFDataRef otherProviderData     = CGDataProviderCopyData(otherProvider);

            if ( selfProviderData && otherProviderData ) {
                equalImages = [(__bridge NSData *) selfProviderData isEqualToData:(__bridge NSData *)otherProviderData];
            }
            else {
                equalImages = (selfProviderData == otherProviderData);
            }

            if ( selfProviderData ) {
                CFRelease(selfProviderData);
            }
            if ( otherProviderData ) {
                CFRelease(otherProviderData);
            }
        }

        return equalImages;
    }
    else {
        return NO;
    }
}

/// @}

/// @cond

-(NSUInteger)hash
{
    // Equal objects must hash the same.
    CGImageRef selfCGImage = self.image;

    return ( CGImageGetWidth(selfCGImage) * CGImageGetHeight(selfCGImage) ) +
           CGImageGetBitsPerComponent(selfCGImage) +
           CGImageGetBitsPerPixel(selfCGImage) +
           CGImageGetBytesPerRow(selfCGImage) +
           CGImageGetBitmapInfo(selfCGImage) +
           CGImageGetShouldInterpolate(selfCGImage) +
           CGImageGetRenderingIntent(selfCGImage) * (NSUInteger)self.scale;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setImage:(CGImageRef)newImage
{
    if ( newImage != image ) {
        CGImageRetain(newImage);
        CGImageRelease(image);
        image = newImage;

        nativeImage = nil;
    }
}

-(void)setNativeImage:(CPTNativeImage *)newImage
{
    if ( newImage != nativeImage ) {
        nativeImage = [newImage copy];

        CGImageRelease(image);
        image = NULL;
    }
}

-(CPTNativeImage *)nativeImage
{
    if ( !nativeImage ) {
        CGImageRef imageRef = self.image;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGFloat theScale = self.scale;

        if ( imageRef && ( theScale > CPTFloat(0.0) ) ) {
            nativeImage = [UIImage imageWithCGImage:imageRef
                                              scale:theScale
                                        orientation:UIImageOrientationUp];
        }
#else
        if ( [NSImage instancesRespondToSelector:@selector(initWithCGImage:size:)] ) {
            nativeImage = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
        }
        else {
            CGSize imageSize = CGSizeMake( CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) );

            NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                                 pixelsWide:(NSInteger)imageSize.width
                                                                                 pixelsHigh:(NSInteger)imageSize.height
                                                                              bitsPerSample:8
                                                                            samplesPerPixel:4
                                                                                   hasAlpha:YES
                                                                                   isPlanar:NO
                                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                                                bytesPerRow:(NSInteger)imageSize.width * 4
                                                                               bitsPerPixel:32];

            NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
            CGContextRef context             = (CGContextRef)[bitmapContext graphicsPort];

            CGContextDrawImage(context, CPTRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRef);

            nativeImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(imageSize)];
            [nativeImage addRepresentation:imageRep];
        }
#endif
    }

    return nativeImage;
}

-(void)setScale:(CGFloat)newScale
{
    NSParameterAssert(newScale > 0.0);

    if ( newScale != scale ) {
        scale = newScale;
    }
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/** @brief Draws the image into the given graphics context.
 *
 *  If the tiled property is @YES, the image is repeatedly drawn to fill the clipping region, otherwise the image is
 *  scaled to fit in @par{rect}.
 *
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context
{
    CPTNativeImage *theNativeImage = self.nativeImage;
    CGImageRef theImage            = self.image;

    // compute drawing scale
    CGFloat lastScale    = self.lastDrawnScale;
    CGFloat contextScale = CPTFloat(1.0);

    if ( rect.size.height != CPTFloat(0.0) ) {
        CGRect deviceRect = CGContextConvertRectToDeviceSpace(context, rect);
        contextScale = deviceRect.size.height / rect.size.height;
    }

    // generate a Core Graphics image if needed
    if ( theNativeImage && ( !theImage || (contextScale != lastScale) ) ) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        theImage = theNativeImage.CGImage;
#else
        NSRect drawingRect = NSZeroRect;
        theImage = [theNativeImage CGImageForProposedRect:&drawingRect
                                                  context:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]
                                                    hints:nil];
#endif
        self.image = theImage;
        self.scale = contextScale;
    }

    // draw the image
    if ( theImage ) {
        CGFloat imageScale = self.scale;
        CGFloat scaleRatio = contextScale / imageScale;

        CGContextSaveGState(context);

        if ( self.isTiled ) {
            CGContextClipToRect(context, rect);
            if ( !self.tileAnchoredToContext ) {
                CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
            }
            CGContextScaleCTM(context, scaleRatio, scaleRatio);

            CGRect imageBounds = CPTRectMake( 0.0, 0.0, CGImageGetWidth(theImage), CGImageGetHeight(theImage) );
            CGContextDrawTiledImage(context, imageBounds, theImage);
        }
        else {
            CGContextScaleCTM(context, scaleRatio, scaleRatio);
            CGContextDrawImage(context, rect, theImage);
        }

        CGContextRestoreGState(context);

        self.lastDrawnScale = contextScale;
    }
}

@end
