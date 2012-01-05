#import "_CPTFillImage.h"

#import "CPTImage.h"

///	@cond
@interface _CPTFillImage()

@property (nonatomic, readwrite, copy) CPTImage *fillImage;

@end

///	@endcond

/** @brief Draws CPTImage area fills.
 *
 *	Drawing methods are provided to fill rectangular areas and arbitrary drawing paths.
 **/

@implementation _CPTFillImage

/** @property fillImage
 *  @brief The fill image.
 **/
@synthesize fillImage;

#pragma mark -
#pragma mark init/dealloc

/** @brief Initializes a newly allocated _CPTFillImage object with the provided image.
 *  @param anImage The image.
 *  @return The initialized _CPTFillImage object.
 **/
-(id)initWithImage:(CPTImage *)anImage
{
	if ( (self = [super init]) ) {
		fillImage = [anImage retain];
	}
	return self;
}

-(void)dealloc
{
	[fillImage release];
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
	_CPTFillImage *copy = [[[self class] allocWithZone:zone] init];

	copy->fillImage = [self->fillImage copyWithZone:zone];

	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPTFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fillImage forKey:@"_CPTFillImage.fillImage"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		fillImage = [[coder decodeObjectForKey:@"_CPTFillImage.fillImage"] retain];
	}
	return self;
}

@end
