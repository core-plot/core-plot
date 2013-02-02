#import "CPTFill.h"

@class CPTImage;

@interface _CPTFillImage : CPTFill<NSCopying, NSCoding> {
    @private
    CPTImage *fillImage;
}

/// @name Initialization
/// @{
-(id)initWithImage:(CPTImage *)anImage;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
