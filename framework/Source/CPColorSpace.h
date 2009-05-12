
#import <Foundation/Foundation.h>


@interface CPColorSpace : NSObject {
    CGColorSpaceRef cgColorSpace;
}

@property (nonatomic, readonly, assign) CGColorSpaceRef cgColorSpace;

+(CPColorSpace *)genericRGBSpace;

-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;

@end
