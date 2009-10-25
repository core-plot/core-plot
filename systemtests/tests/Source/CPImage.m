#import "CPImage.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
// iPhone-specific image library as equivalent to ImageIO?
#else
//#import <ImageIO/ImageIO.h>
#endif


/** @brief Wrapper around CGImageRef.
 * 
 *  A wrapper class around CGImageRef.
 *
 * @todo More documentation needed 
 **/

@implementation CPImage

/** @property image 
 * @brief The CGImageRef to wrap around.
 **/
@synthesize image;

/** @property tiled
 * @brief Draw as a tiled image?
 *
 * If YES, the image is drawn repeatedly to fill the current clip region.
 * Otherwise, the image is drawn one time only in the provided rectangle.
 * The default value is NO.
 **/
@synthesize tiled;

#pragma mark -
#pragma mark Initialization

/** @brief Initializes a CPImage instance with the provided CGImageRef.
 *
 *	This is the designated initializer.
 *
 *  @param anImage The image to wrap.
 *  @return A CPImage instance initialized with the provided CGImageRef.
 **/
-(id)initWithCGImage:(CGImageRef)anImage
{
	if ( self = [super init] ) {
 		CGImageRetain(anImage);
    	image = anImage;
        tiled = NO;
    }
    return self;
}

-(id)init
{
	return [self initWithCGImage:NULL];
}

/** @brief Initializes a CPImage instance with the contents of a PNG file.
 *  @param path The file system path of the file.
 *  @return A CPImage instance initialized with the contents of the PNG file.
 **/
-(id)initForPNGFile:(NSString *)path 
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path cStringUsingEncoding:NSUTF8StringEncoding]);
    CGImageRef cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, YES, kCGRenderingIntentDefault);
    if ( cgImage ) {
        self = [self initWithCGImage:cgImage];
    }
    else {
        [self release];
        self = nil;
    }
    CGImageRelease(cgImage);
    CGDataProviderRelease(dataProvider);
    return self;
}

-(void)dealloc
{
	CGImageRelease(image);
	[super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
    CPImage *copy = [[[self class] allocWithZone:zone] init];
	
	copy->image = CGImageCreateCopy(self.image);
	copy->tiled = self->tiled;
	
    return copy;
}

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPImage instance initialized with the provided CGImageRef.
 *  @param anImage The image to wrap.
 *  @return A new CPImage instance initialized with the provided CGImageRef.
 **/
+(CPImage *)imageWithCGImage:(CGImageRef)anImage
{
	return [[[self alloc] initWithCGImage:anImage] autorelease];
}

/** @brief Creates and returns a new CPImage instance initialized with the contents of a PNG file.
 *  @param path The file system path of the file.
 *  @return A new CPImage instance initialized with the contents of the PNG file.
 **/
+(CPImage *)imageForPNGFile:(NSString *)path
{
	return [[[self alloc] initForPNGFile:path] autorelease];
}

#pragma mark -
#pragma mark Accessors

-(void)setImage:(CGImageRef)anImage
{
	if (anImage != image) {
		CGImageRetain(anImage);
		CGImageRelease(image);
		image = anImage;
	}
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the image into the given graphics context.
 *
 *  If the tiled property is TRUE, the image is repeatedly drawn to fill the clipping region, otherwise the image is
 *  scaled to fit in rect.
 *  
 *  @param rect The rectangle to draw into.
 *  @param context The graphics context to draw into.
 **/
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context
{
	if (self.image) {
		if (self.tiled) {
			CGContextDrawTiledImage(context, rect, self.image);
		} else {
			CGContextDrawImage(context, rect, self.image);
		}
	}
}

@end
