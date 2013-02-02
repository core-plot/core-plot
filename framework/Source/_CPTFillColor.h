#import "CPTFill.h"

@interface _CPTFillColor : CPTFill<NSCopying, NSCoding> {
    @private
    CPTColor *fillColor;
}

/// @name Initialization
/// @{
-(id)initWithColor:(CPTColor *)aColor;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
