#import "CPColor.h"
#import "CPColorSpace.h"
#import "CPPlatformSpecificFunctions.h"

@implementation CPColor

@synthesize cgColor;

#pragma mark -
#pragma mark Factory Methods

+(CPColor *)clearColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef clear = NULL;
        CGFloat values[4] = {1.0, 1.0, 1.0, 0.0}; 
		clear = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values); 
        color = [[CPColor alloc] initWithCGColor:clear];
        CGColorRelease(clear);
    }
	return color; 
} 

+(CPColor *)whiteColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef white = NULL;
        CGFloat values[4] = {1.0, 1.0, 1.0, 1.0}; 
		white = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);  
        color = [[CPColor alloc] initWithCGColor:white];
        CGColorRelease(white);
    }
	return color; 
} 

+(CPColor *)blackColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef black = NULL;
        CGFloat values[4] = {0.0, 0.0, 0.0, 1.0}; 
		black = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:black];
        CGColorRelease(black);
    }
	return color; 
} 

+(CPColor *)redColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef red = NULL;
        CGFloat values[4] = {1.0, 0.0, 0.0, 1.0}; 
		red = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:red];
        CGColorRelease(red);
    }
	return color; 
} 

+(CPColor *)greenColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef green = NULL;
        CGFloat values[4] = {0.0, 1.0, 0.0, 1.0}; 
		green = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:green];
        CGColorRelease(green);
    }
	return color; 
}

+(CPColor *)blueColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef blue = NULL;
        CGFloat values[4] = {0.0, 0.0, 1.0, 1.0}; 
		blue = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:blue];
        CGColorRelease(blue);
    }
	return color; 
}

+(CPColor *)darkGrayColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef darkGray = NULL;
        CGFloat values[4] = {0.4, 0.4, 0.4, 1.0}; 
		darkGray = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:darkGray];
        CGColorRelease(darkGray);
    }
	return color; 
}

+(CPColor *)lightGrayColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef lightGray = NULL;
        CGFloat values[4] = {0.7, 0.7, 0.7, 1.0}; 
		lightGray = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
        color = [[CPColor alloc] initWithCGColor:lightGray];
        CGColorRelease(lightGray);
    }
	return color; 
}

+(CPColor *)colorWithCGColor:(CGColorRef)newCGColor 
{
    return [[[CPColor alloc] initWithCGColor:newCGColor] autorelease];
}

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)initWithCGColor:(CGColorRef)newCGColor
{
    if ( self = [super init] ) {            
        CGColorRetain(newCGColor);
        cgColor = newCGColor;
    }
    return self;
}

-(void)dealloc 
{
    CGColorRelease(cgColor);
    [super dealloc];
}

#pragma mark -
#pragma mark Creating colors from other colors

-(CPColor *)colorWithAlphaComponent:(CGFloat)alpha
{
    CGColorRef newCGColor = CGColorCreateCopyWithAlpha(self.cgColor, alpha);
    CPColor *newColor = [CPColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    return newColor;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	const CGFloat *colorComponents = CGColorGetComponents(self.cgColor);
	
	[coder encodeDouble:colorComponents[0] forKey:@"redComponent"];
	[coder encodeDouble:colorComponents[1] forKey:@"greenComponent"];
	[coder encodeDouble:colorComponents[2] forKey:@"blueComponent"];
	[coder encodeDouble:colorComponents[3] forKey:@"alphaComponent"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ([[super class] conformsToProtocol:@protocol(NSCoding)]) {
        self = [(id <NSCoding>)super initWithCoder:coder];
    } else {
        self = [super init];
    }
    
    if (self) {
		CGFloat colorComponents[4];
		colorComponents[0] = [coder decodeDoubleForKey:@"redComponent"];
		colorComponents[1] = [coder decodeDoubleForKey:@"greenComponent"];
		colorComponents[2] = [coder decodeDoubleForKey:@"blueComponent"];
		colorComponents[3] = [coder decodeDoubleForKey:@"alphaComponent"];
		cgColor = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, colorComponents);
	}
    return self;
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
    CGColorRef cgColorCopy = NULL;
    if ( cgColor ) cgColorCopy = CGColorCreateCopy(cgColor);
    CPColor *colorCopy = [[[self class] allocWithZone:zone] initWithCGColor:cgColorCopy];
    CGColorRelease(cgColorCopy);
    return colorCopy;
}

@end
