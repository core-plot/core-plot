
#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPImage;

@interface _CPFillImage : CPFill <NSCopying, NSCoding> {
	CPImage *fillImage;
}

// Init
-(id)initWithImage:(CPImage *)anImage;

// Drawing
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;

@end
