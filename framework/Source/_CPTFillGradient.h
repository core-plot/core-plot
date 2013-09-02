#import "CPTFill.h"

@class CPTGradient;

@interface _CPTFillGradient : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithGradient:(CPTGradient *)aGradient;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
