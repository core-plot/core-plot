#import "CPTColorSpace.h"

#import "NSCoderExtensions.h"

///	@cond
@interface CPTColorSpace()

@property (nonatomic, readwrite, assign) CGColorSpaceRef cgColorSpace;

@end

///	@endcond

#pragma mark -

/** @brief An immutable color space.
 *
 *  An immutable object wrapper class around CGColorSpaceRef.
 **/

@implementation CPTColorSpace

/** @property cgColorSpace.
 *  @brief The CGColorSpaceRef to wrap around
 **/
@synthesize cgColorSpace;

#pragma mark -
#pragma mark Class methods

/** @brief Returns a shared instance of CPTColorSpace initialized with the standard RGB space
 *
 *	For the iPhone this is <code>CGColorSpaceCreateDeviceRGB()</code>;
 *	for Mac OS X it is <code>CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)</code>.
 *
 *	@return A shared CPTColorSpace object initialized with the standard RGB colorspace.
 **/
+(CPTColorSpace *)genericRGBSpace;
{
	static CPTColorSpace *space = nil;
	if ( nil == space ) {
		CGColorSpaceRef cgSpace = NULL;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		cgSpace = CGColorSpaceCreateDeviceRGB();
#else
		cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
#endif
		space = [[CPTColorSpace alloc] initWithCGColorSpace:cgSpace];
		CGColorSpaceRelease(cgSpace);
	}
	return space;
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated colorspace object with the specified color space.
 *  This is the designated initializer.
 *
 *	@param colorSpace The color space.
 *  @return The initialized CPTColorSpace object.
 **/
-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace
{
	if ( (self = [super init]) ) {
		CGColorSpaceRetain(colorSpace);
		cgColorSpace = colorSpace;
	}
	return self;
}

-(void)dealloc
{
	CGColorSpaceRelease(cgColorSpace);
	[super dealloc];
}

-(void)finalize
{
	CGColorSpaceRelease(cgColorSpace);
	[super finalize];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeCGColorSpace:self.cgColorSpace forKey:@"CPTColorSpace.cgColorSpace"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		cgColorSpace = [coder newCGColorSpaceDecodeForKey:@"CPTColorSpace.cgColorSpace"];
	}
	return self;
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setCGColorSpace:(CGColorSpaceRef)newSpace
{
	if ( newSpace != cgColorSpace ) {
		CGColorSpaceRelease(cgColorSpace);
		CGColorSpaceRetain(newSpace);
		cgColorSpace = newSpace;
	}
}

///	@endcond

@end
