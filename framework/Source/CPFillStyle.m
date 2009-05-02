
#import "CPFillStyle.h"
#import "CPGradient.h"

@implementation CPFillStyle

@synthesize gradient;
@synthesize color;
@synthesize image;
@synthesize tileImageInX;
@synthesize tileImageInY;

#pragma mark -
#pragma mark Factory methods
+(CPFillStyle *)fillStyle {
    return [[[CPFillStyle alloc] init] autorelease];
}

+(CPFillStyle *)fillStyleWithGradient:(CPGradient *)gradient {
    return [[[CPFillStyle alloc] initWithGradient:gradient] autorelease];
}

+(CPFillStyle *)fillStyleWithColor:(CGColorRef)aColor {
    return [[(CPFillStyle *)[CPFillStyle alloc] initWithColor:aColor] autorelease];
}

+(CPFillStyle *)fillStyleWithImage:(CGImageRef)image tileInX:(BOOL)repeatsX tileInY:(BOOL)repeatsY {
    return [[[CPFillStyle alloc] initWithImage:image tileInX:repeatsX tileInY:repeatsY] autorelease];
}

#pragma mark -
#pragma mark Initialization
-(id)init { 
    return [self initWithColor:CGColorGetConstantColor(kCGColorBlack)];
}

-(id)initWithGradient:(CPGradient *)aGradient {
    if ( self = [super init] ) {
        self.gradient = aGradient;
    }
    return self;
}

-(id)initWithColor:(CGColorRef)aColor {
    if ( self = [super init] ) {
        self.color = aColor;
    }
    return self;
}

-(id)initWithImage:(CGImageRef)anImage tileInX:(BOOL)repeatsX tileInY:(BOOL)repeatsY {
    if ( self = [super init] ) {
        self.image = anImage;
        self.tileImageInX = repeatsX;
        self.tileImageInY = repeatsY;
    }
    return self;
}

#pragma mark -
#pragma mark Deallocation
-(void)dealloc {
    self.gradient = nil;
    self.color = NULL;
    self.image = NULL;
    [super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
    CPFillStyle *fillStyle = [[[self class] allocWithZone:zone] init];
 	
	fillStyle.gradient = self.gradient;
    
	CGColorRef colorCopy = CGColorCreateCopy(self.color);
    fillStyle.color = colorCopy;
	CGColorRelease(colorCopy);
    
    CGImageRef imageCopy = CGImageCreateCopy(self.image);
    fillStyle.image = imageCopy;
	CGImageRelease(imageCopy);
    
    fillStyle.tileImageInX = self.tileImageInX;
    fillStyle.tileImageInY = self.tileImageInY;
    
    return fillStyle;
}

#pragma mark -
#pragma mark Drawing
-(void)drawInRect:(CGRect)rect context:(CGContextRef)context
{
    if ( self.gradient ) {
        [self.gradient fillRect:rect inContext:context];
    }
    else if ( self.image ) {
        // TBW
    }   
    else if ( self.color ) {
        CGContextSaveGState(context);
        CGContextClipToRect (context, *(CGRect *)&rect);
        CGContextSetFillColorWithColor(context, self.color);
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
}

#pragma mark -
#pragma mark Accessors
-(void)setColor:(CGColorRef)aColor
{
	if ( aColor != color ) {
		CGColorRetain(aColor);
		CGColorRelease(color);
		color = aColor;
	}
    if ( color ) {
        self.image = NULL;
        self.gradient = nil;
    }
}

-(void)setImage:(CGImageRef)anImage
{
	if ( anImage != image ) {
		CGImageRetain(anImage);
		CGImageRelease(image);
		image = anImage;
	}
    if ( image ) {
        self.color = NULL;
        self.gradient = nil;
    }
}

-(void)setGradient:(CPGradient *)aGradient
{
	if ( aGradient != gradient ) {
		[aGradient retain];
        [gradient release];
		gradient = aGradient;
	}
    if ( gradient ) {
        self.color = NULL;
        self.image = NULL;
    }
}

@end
