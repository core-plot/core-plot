
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

-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;

@end
