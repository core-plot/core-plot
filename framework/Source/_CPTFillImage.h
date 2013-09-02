#import "CPTFill.h"

@class CPTImage;

@interface _CPTFillImage : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithImage:(CPTImage *)anImage;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
