#import "CPTFill.h"
#import <Foundation/Foundation.h>

@class CPTImage;

@interface _CPTFillImage : CPTFill<NSCopying, NSCoding> {
	@private
	CPTImage *fillImage;
}

/// @name Initialization
/// @{
-(id)initWithImage:(CPTImage *)anImage;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
