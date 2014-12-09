#import "CPTFill.h"

@interface _CPTFillColor : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithColor:(CPTColor *)aColor NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
