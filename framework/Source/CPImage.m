#import "CPImage.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
// iPhone-specific image library as equivalent to ImageIO?
#else
//#import <ImageIO/ImageIO.h>
#endif


/**	@brief Wrapper around CGImageRef.
 *
 *	A wrapper class around CGImageRef.
 *
 *	@todo More documentation needed 
 **/

@implementation CPImage

/**	@property image 
 *	@brief The CGImageRef to wrap around.
 **/
@synthesize image;

/**	@property tiled
 *	@brief Draw as a tiled image?
 *
 *	If YES, the image is drawn repeatedly to fill the current clip region.
 *	Otherwise, the image is drawn one time only in the provided rectangle.
 *	The default value is NO.
 **/
@synthesize tiled;

/**	@property tileAnchoredToContext
 *	@brief Anchor the tiled image to the context origin?
 *
 *	If YES, the origin of the tiled image is anchored to the origin of the drawing context.
 *	If NO, the origin of the tiled image is set to the orgin of rectangle passed to
 *	<code>drawInRect:inContext:</code>.
 *	The default value is YES.
 *	If <code>tiled</code> is NO, this property has no effect.
 **/
@synthesize tileAnchoredToContext;

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
		tileAnchoredToContext = YES;
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

-(void)finalize
{
	CGImageRelease(image);
	[super finalize];
}

-(id)copyWithZone:(NSZone *)zone
{
    CPImage *copy = [[[self class] allocWithZone:zone] init];
	
	copy->image = CGImageCreateCopy(self.image);
	copy->tiled = self->tiled;
	copy->tileAnchoredToContext = self->tileAnchoredToContext;
	
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

-(void)setImage:(CGImageRef)newImage
{
	if ( newImage != image ) {
		CGImageRetain(newImage);
		CGImageRelease(image);
		image = newImage;
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
	CGImageRef theImage = self.image;
	if ( theImage ) {
		if ( self.isTiled ) {
			CGContextSaveGState(context);
			CGContextClipToRect(context, *(CGRect *)&rect);
			if ( !self.tileAnchoredToContext ) {
				CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
			}
			CGRect imageBounds = CGRectMake(0.0, 0.0, (CGFloat)CGImageGetWidth(theImage), (CGFloat)CGImageGetHeight(theImage));
			CGContextDrawTiledImage(context, imageBounds, theImage);
			CGContextRestoreGState(context);
		} else {
			CGContextDrawImage(context, rect, theImage);
		}
	}
}

@end
