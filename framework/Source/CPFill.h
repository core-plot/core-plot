
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

@class CPGradient;
@class CPImage;
@class CPColor;

@interface CPFill : NSObject <NSCopying, NSCoding> {

}

// Init
+(CPFill *)fillWithColor:(CPColor *)aColor;
+(CPFill *)fillWithGradient:(CPGradient *)aGradient;
+(CPFill *)fillWithImage:(CPImage *)anImage;

-(id)initWithColor:(CPColor *)aColor;
-(id)initWithGradient:(CPGradient *)aGradient;
-(id)initWithImage:(CPImage *)anImage;

// Drawing
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;

@end
