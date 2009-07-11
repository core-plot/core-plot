
#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPImage;

@interface _CPFillImage : CPFill <NSCopying, NSCoding> {
	CPImage *fillImage;
}

/// @name Initialization
/// @{
-(id)initWithImage:(CPImage *)anImage;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
