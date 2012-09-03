#import "CPTFill.h"
#import <Foundation/Foundation.h>

@interface _CPTFillColor : CPTFill<NSCopying, NSCoding> {
    @private
    CPTColor *fillColor;
}

/// @name Initialization
/// @{
-(id)initWithColor:(CPTColor *)aCcolor;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
