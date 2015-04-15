#import "CPTFill.h"

@class CPTImage;

@interface _CPTFillImage : CPTFill<NSCopying, NSCoding>

/// @name Initialization
/// @{
-(instancetype)initWithImage:(CPTImage *)anImage NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
