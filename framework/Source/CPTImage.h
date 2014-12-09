#import "CPTDefinitions.h"
#import "CPTPlatformSpecificDefines.h"

@interface CPTImage : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, copy) CPTNativeImage *nativeImage;
@property (nonatomic, readwrite, assign) CGImageRef image;
@property (nonatomic, readwrite, assign) CGFloat scale;
@property (nonatomic, readwrite, assign, getter = isTiled) BOOL tiled;
@property (nonatomic, readwrite, assign) CPTEdgeInsets edgeInsets;
@property (nonatomic, readwrite, assign) BOOL tileAnchoredToContext;
@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;

/// @name Factory Methods
/// @{
+(instancetype)imageNamed:(NSString *)name;

+(instancetype)imageWithNativeImage:(CPTNativeImage *)anImage;
+(instancetype)imageWithContentsOfFile:(NSString *)path;
+(instancetype)imageWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale;
+(instancetype)imageWithCGImage:(CGImageRef)anImage;
+(instancetype)imageForPNGFile:(NSString *)path;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithContentsOfFile:(NSString *)path;
-(instancetype)initWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCGImage:(CGImageRef)anImage;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;
/// @}

@end

#pragma mark -

/** @category CPTImage(CPTPlatformSpecificImageExtensions)
 *  @brief Platform-specific extensions to CPTImage.
 **/
@interface CPTImage(CPTPlatformSpecificImageExtensions)

/// @name Initialization
/// @{
-(instancetype)initWithNativeImage:(CPTNativeImage *)anImage;
-(instancetype)initForPNGFile:(NSString *)path;
/// @}

@end
