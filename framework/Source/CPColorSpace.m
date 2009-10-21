
#import "CPColorSpace.h"

///	@cond
@interface CPColorSpace ()

@property (nonatomic, readwrite, assign) CGColorSpaceRef cgColorSpace;

@end
///	@endcond

/** @brief Wrapper around CGColorSpaceRef
 *
 *  A wrapper class around CGColorSpaceRef
 *
 * @todo More documentation needed 
 **/

@implementation CPColorSpace

/** @property cgColorSpace. 
 *  @brief The CGColorSpace to wrap around 
 **/
@synthesize cgColorSpace;

#pragma mark -
#pragma mark Class methods

/** @brief Returns a shared instance of CPColorSpace initialized with the standard RGB space
 *
 * For the iPhone this is CGColorSpaceCreateDeviceRGB(), for Mac OS X CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB).
 *
 *  @return A shared CPColorSpace object initialized with the standard RGB colorspace.
 **/
+(CPColorSpace *)genericRGBSpace;
{ 
	static CPColorSpace *space = nil;
	if (nil == space) { 
        CGColorSpaceRef cgSpace = NULL; 
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		cgSpace = CGColorSpaceCreateDeviceRGB();
#else
		cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
#endif
        space = [[CPColorSpace alloc] initWithCGColorSpace:cgSpace];
	} 
	return space; 
} 

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated colorspace object with the specified color space.
 *  This is the designated initializer.
 *
 *	@param colorSpace The color space.
 *  @return The initialized CPColorSpace object.
 **/
-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace {
    if ( self = [super init] ) {
        CGColorSpaceRetain(colorSpace);
        cgColorSpace = colorSpace;
    }
    return self;
}

-(void)dealloc {
    CGColorSpaceRelease(cgColorSpace);
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setCGColorSpace:(CGColorSpaceRef)newSpace {
    if ( newSpace != cgColorSpace ) {
        CGColorSpaceRelease(cgColorSpace);
        CGColorSpaceRetain(newSpace);
        cgColorSpace = newSpace;
    }
}

@end
