
#import <Foundation/Foundation.h>
#import "CPFill.h"


@interface _CPFillColor : CPFill <NSCopying, NSCoding> {
	CPColor *fillColor;
}

// Init
-(id)initWithColor:(CPColor *)aCcolor;

// Drawing
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;

@end
