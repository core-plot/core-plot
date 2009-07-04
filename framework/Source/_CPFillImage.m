
#import "_CPFillImage.h"
#import "CPImage.h"

@interface _CPFillImage()

@property (nonatomic, readwrite, copy) CPImage *fillImage;

@end

@implementation _CPFillImage

@synthesize fillImage;

#pragma mark -
#pragma mark init/dealloc

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

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	[self.fillImage drawInRect:theRect inContext:theContext];
}

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
