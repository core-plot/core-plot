
#import <Foundation/Foundation.h>
#import "CPTFill.h"


@interface _CPTFillColor : CPTFill <NSCopying, NSCoding> {
	@private
	CPTColor *fillColor;
}

/// @name Initialization
/// @{
-(id)initWithColor:(CPTColor *)aCcolor;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
