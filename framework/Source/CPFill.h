
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

@class CPGradient;
@class CPImage;
@class CPColor;

@interface CPFill : NSObject <NSCopying> {

}

+(CPFill *)fillWithColor:(CPColor *)aColor;
+(CPFill *)fillWithGradient:(CPGradient *)aGradient;
+(CPFill *)fillWithImage:(CPImage *)anImage;

-(id)initWithColor:(CPColor *)aColor;
-(id)initWithGradient:(CPGradient *)aGradient;
-(id)initWithImage:(CPImage *)anImage;

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
