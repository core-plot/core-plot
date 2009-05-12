
#import "CPColorSpace.h"

@interface CPColorSpace ()

+(CGColorSpaceRef)createGenericRGBSpace;

-(void)setCGColorSpace:(CGColorSpaceRef)newSpace;

@end


@implementation CPColorSpace

@synthesize cgColorSpace;

+(CGColorSpaceRef)createGenericRGBSpace;
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	return CGColorSpaceCreateDeviceRGB();
#else
	return CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
#endif
} 

// This caches a generic RGB colorspace for repeated use
+(CPColorSpace *)genericRGBSpace;
{ 
	static CPColorSpace *space = nil;
	if(nil == space) 
	{ 
        CGColorSpaceRef cgSpace = NULL; 
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
		cgSpace = CGColorSpaceCreateDeviceRGB();
#else
		cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
#endif
        space = [[CPColorSpace alloc] initWithCGColorSpace:cgSpace];
	} 
	return space; 
} 

-(id)initWithCGColorSpace:(CGColorSpaceRef)colorSpace {
    if ( self = [super init] ) {
        [self setCGColorSpace:colorSpace];
    }
    return self;
}

-(void)dealloc {
    [self setCGColorSpace:NULL];
    [super dealloc];
}

-(void)setCGColorSpace:(CGColorSpaceRef)newSpace {
    if ( newSpace != cgColorSpace ) {
        CGColorSpaceRelease(cgColorSpace);
        CGColorSpaceRetain(newSpace);
        cgColorSpace = newSpace;
    }
}

@end
