
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CPImage : NSObject <NSCopying> {
    @private
	CGImageRef image;
	BOOL tiled;
}

@property (assign) CGImageRef image;
@property (assign, getter=isTiled) BOOL tiled;

+(CPImage *)imageWithCGImage:(CGImageRef)anImage;
+(CPImage *)imageForPNGFile:(NSString *)path;

-(id)initWithCGImage:(CGImageRef)anImage;
-(id)initForPNGFile:(NSString *)path;

-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;

@end
