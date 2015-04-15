#import "CPTColorSpace.h"

#import "NSCoderExtensions.h"

/** @brief An immutable color space.
 *
 *  An immutable object wrapper class around @ref CGColorSpaceRef.
 **/

@implementation CPTColorSpace

/** @property CGColorSpaceRef cgColorSpace
 *  @brief The @ref CGColorSpaceRef to wrap around.
 **/
@synthesize cgColorSpace;

#pragma mark -
#pragma mark Class methods

/** @brief Returns a shared instance of CPTColorSpace initialized with the standard RGB space.
 *
 *  The standard RGB space is created by the
 *  @if MacOnly @ref CGColorSpaceCreateWithName ( @ref kCGColorSpaceGenericRGB ) function. @endif
 *  @if iOSOnly @ref CGColorSpaceCreateDeviceRGB() function. @endif
 *
 *  @return A shared CPTColorSpace object initialized with the standard RGB colorspace.
 **/
+(instancetype)genericRGBSpace
{
    static CPTColorSpace *space      = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        CGColorSpaceRef cgSpace = NULL;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        cgSpace = CGColorSpaceCreateDeviceRGB();
#else
        cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
#endif
        space = [[CPTColorSpace alloc] initWithCGColorSpace:cgSpace];
        CGColorSpaceRelease(cgSpace);
    });

    return space;
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated colorspace object with the specified color space.
 *  This is the designated initializer.
 *
 *  @param colorSpace The color space.
 *  @return The initialized CPTColorSpace object.
 **/
-(instancetype)initWithCGColorSpace:(CGColorSpaceRef)colorSpace
{
    if ( (self = [super init]) ) {
        CGColorSpaceRetain(colorSpace);
        cgColorSpace = colorSpace;
    }
    return self;
}

/// @cond

-(void)dealloc
{
    CGColorSpaceRelease(cgColorSpace);
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeCGColorSpace:self.cgColorSpace forKey:@"CPTColorSpace.cgColorSpace"];
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param coder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        cgColorSpace = [coder newCGColorSpaceDecodeForKey:@"CPTColorSpace.cgColorSpace"];
    }
    return self;
}

@end
