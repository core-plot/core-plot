//
//  CPImage.m
//  CorePlot
//

#import <ImageIO/ImageIO.h>
#import "CPImage.h"

@implementation CPImage

@synthesize image;
@synthesize tiled;

#pragma mark -
#pragma mark Initialization

-(id)init
{
	if ( self = [super init] ) {
		self.image = NULL;
        self.tiled = FALSE;
	}
	return self;
}

-(void)dealloc
{
	self.image = NULL;
	[super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
    CPImage *copy = [[[self class] allocWithZone:zone] init];
	
	CGImageRef imageCopy = CGImageCreateCopy(self.image);
	copy.image = imageCopy;
	CGImageRelease(imageCopy);
	copy.tiled = self.tiled;
	
    return copy;
}

#pragma mark -
#pragma mark Factory Methods

+(CPImage *)imageWithCGImage:(CGImageRef)anImage
{
	CPImage *theImage = [[[self class] alloc] init];
	theImage.image = anImage;
	return [theImage autorelease];
}

#pragma mark -
#pragma mark Accessors

-(void)setImage(CGImageRef)anImage
{
	if (anImage != image) {
		CGImageRetain(anImage);
		CGImageRelease(image);
		image = anImage;
	}
}

#pragma mark -
#pragma mark Drawing

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
