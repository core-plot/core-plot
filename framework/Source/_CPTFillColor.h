#import "CPTFill.h"

@interface _CPTFillColor : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithColor:(CPTColor *)aColor;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
