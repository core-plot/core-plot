#import "CPTFill.h"

@class CPTGradient;

@interface _CPTFillGradient : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithGradient:(CPTGradient *)aGradient NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
