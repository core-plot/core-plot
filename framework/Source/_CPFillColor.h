
#import <Foundation/Foundation.h>
#import "CPFill.h"


@interface _CPFillColor : CPFill <NSCopying> {
	CPColor *fillColor;
}

-(id)initWithColor:(CPColor *)aCcolor;
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
