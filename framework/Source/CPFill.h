//
//  CPFill.h
//  CorePlot
//

#import <Foundation/Foundation.h>

@class CPGradient;

@interface CPFill : NSObject <NSCopying> {

}

+(CPFill *)fillWithColor:(CGColorRef)aColor;
+(CPFill *)fillWithGradient:(CPGradient *)aGradient;
+(CPFill *)fillWithImage:(CGImageRef)anImage;

-(id)initWithColor:(CGColorRef)aColor;
-(id)initWithGradient:(CPGradient *)aGradient;
-(id)initWithImage:(CGImageRef)anImage;
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
