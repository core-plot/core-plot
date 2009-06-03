/** \brief Wrapper around CGColorSpaceRef
 *  A wrapper class around CGColorSpaceRef
 *
 * \todo More documentation needed 
 **/

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CPColorSpace : NSObject {
    CGColorSpaceRef cgColorSpace; //!< Pointer to a CGColorSpaceRef
}

@property (nonatomic, readonly, assign) CGColorSpaceRef cgColorSpace;

+(CPColorSpace *)genericRGBSpace;

-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace;

@end
