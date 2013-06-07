#import "CPTPlatformSpecificDefines.h"

@interface CPTImage : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, copy) CPTNativeImage *nativeImage;
@property (nonatomic, readwrite, assign) CGImageRef image;
@property (nonatomic, readwrite, assign) CGFloat scale;
@property (nonatomic, readwrite, assign, getter = isTiled) BOOL tiled;
@property (nonatomic, readwrite, assign) BOOL tileAnchoredToContext;

/// @name Factory Methods
/// @{
+(CPTImage *)imageNamed:(NSString *)name;

+(CPTImage *)imageWithNativeImage:(CPTNativeImage *)anImage;
+(CPTImage *)imageWithContentsOfFile:(NSString *)path;
+(CPTImage *)imageWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale;
+(CPTImage *)imageWithCGImage:(CGImageRef)anImage;
+(CPTImage *)imageForPNGFile:(NSString *)path;
/// @}

/// @name Initialization
/// @{
-(id)initWithNativeImage:(CPTNativeImage *)anImage;
-(id)initWithContentsOfFile:(NSString *)path;
-(id)initWithCGImage:(CGImageRef)anImage scale:(CGFloat)newScale;
-(id)initWithCGImage:(CGImageRef)anImage;
-(id)initForPNGFile:(NSString *)path;
/// @}

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;
/// @}

@end
