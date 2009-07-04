
#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPGradient;

@interface _CPFillGradient : CPFill <NSCopying, NSCoding> {
	CPGradient *fillGradient;
}

// Init
-(id)initWithGradient:(CPGradient *)aGradient;

// Drawing
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;

@end
