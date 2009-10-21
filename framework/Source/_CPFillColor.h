
#import <Foundation/Foundation.h>
#import "CPFill.h"


@interface _CPFillColor : CPFill <NSCopying, NSCoding> {
	@private
	CPColor *fillColor;
}

/// @name Initialization
/// @{
-(id)initWithColor:(CPColor *)aCcolor;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
