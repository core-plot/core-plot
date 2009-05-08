//
//  CPFillImage.h
//  CorePlot
//

#import <Foundation/Foundation.h>
#import "CPFill.h"


@interface CPFillImage : CPFill <NSCopying> {
	CGImageRef fillImage;
}

-(id)initWithImage:(CGImageRef)anImage;
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
