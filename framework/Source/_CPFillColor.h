//
//  CPFillColor.h
//  CorePlot
//

#import <Foundation/Foundation.h>
#import "CPFill.h"


@interface _CPFillColor : CPFill <NSCopying> {
	CGColorRef fillColor;
}

-(id)initWithColor:(CGColorRef)aCcolor;
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
