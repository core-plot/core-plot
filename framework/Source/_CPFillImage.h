
#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPImage;

@interface _CPFillImage : CPFill <NSCopying> {
	CPImage *fillImage;
}

-(id)initWithImage:(CPImage *)anImage;

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
