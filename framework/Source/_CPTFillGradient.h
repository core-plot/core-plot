
#import <Foundation/Foundation.h>
#import "CPTFill.h"

@class CPTGradient;

@interface _CPTFillGradient : CPTFill <NSCopying, NSCoding> {
	@private
	CPTGradient *fillGradient;
}

/// @name Initialization
/// @{
-(id)initWithGradient:(CPTGradient *)aGradient;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
