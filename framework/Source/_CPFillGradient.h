
#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPGradient;

@interface _CPFillGradient : CPFill <NSCopying, NSCoding> {
	@private
	CPGradient *fillGradient;
}

/// @name Initialization
/// @{
-(id)initWithGradient:(CPGradient *)aGradient;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
