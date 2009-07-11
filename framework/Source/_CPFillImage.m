
#import "_CPFillImage.h"
#import "CPImage.h"

@interface _CPFillImage()

@property (nonatomic, readwrite, copy) CPImage *fillImage;

@end

/** @brief Draws CPImage area fills.
 *
 *	Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPFillImage

/** @property fillImage
 *  @brief The fill image.
 **/
@synthesize fillImage;

#pragma mark -
#pragma mark init/dealloc

/** @brief Initializes a newly allocated _CPFillImage object with the provided image.
 *  @param anImage The image.
 *  @return The initialized _CPFillImage object.
 **/
-(id)initWithImage:(CPImage *)anImage 
{
	if (self = [super init]) 
	{
		// initialization
		self.fillImage = anImage;
	}
	return self;
}

-(void)dealloc
{
	self.fillImage = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the image into the given graphics context inside the provided rectangle.
 *  @param theRect The rectangle to draw into.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[self.fillImage drawInRect:theRect inContext:theContext];
}

/** @brief Draws the image into the given graphics context clipped to the current drawing path.
 *  @param theContext The graphics context to draw into.
 **/
-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	
	CGRect bounds = CGContextGetPathBoundingBox(theContext);
	CGContextClip(theContext);
	[self.fillImage drawInRect:bounds inContext:theContext];
	
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillImage *copy = [(_CPFillImage *)[[self class] allocWithZone:zone] initWithImage:[self.fillImage copyWithZone:zone]];
	
	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fillImage forKey:@"fillImage"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( self = [super init] ) {
		fillImage = [[coder decodeObjectForKey:@"fillImage"] retain];
	}
    return self;
}

@end
