
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CPImage : NSObject <NSCopying> {
    @private
	CGImageRef image;
	BOOL tiled;
	BOOL tileAnchoredToContext;
}

@property (assign) CGImageRef image;
@property (assign, getter=isTiled) BOOL tiled;
@property (assign) BOOL	tileAnchoredToContext;

/// @name Factory Methods
/// @{
+(CPImage *)imageWithCGImage:(CGImageRef)anImage;
+(CPImage *)imageForPNGFile:(NSString *)path;
///	@}

/// @name Initialization
/// @{
-(id)initWithCGImage:(CGImageRef)anImage;
-(id)initForPNGFile:(NSString *)path;
///	@}

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;
///	@}

@end
