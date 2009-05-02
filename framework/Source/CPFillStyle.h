
#import <Foundation/Foundation.h>

@class CPGradient;

@interface CPFillStyle : NSObject <NSCopying> {
    CPGradient *gradient;
    CGColorRef color;
    CGImageRef image;
    BOOL tileImageInX, tileImageInY;
}

@property (copy) CPGradient *gradient;
@property (assign) CGColorRef color;
@property (assign) CGImageRef image;
@property (assign) BOOL tileImageInX, tileImageInY;

+(CPFillStyle *)fillStyle;
+(CPFillStyle *)fillStyleWithGradient:(CPGradient *)gradient;
+(CPFillStyle *)fillStyleWithColor:(CGColorRef)color;
+(CPFillStyle *)fillStyleWithImage:(CGImageRef)image tileInX:(BOOL)repeatsX tileInY:(BOOL)repeatsY;

-(id)initWithGradient:(CPGradient *)gradient;
-(id)initWithColor:(CGColorRef)color;
-(id)initWithImage:(CGImageRef)image tileInX:(BOOL)repeatsX tileInY:(BOOL)repeatsY;

-(id)copyWithZone:(NSZone *)zone;

-(void)drawInRect:(CGRect)rect context:(CGContextRef)theContext;

@end
