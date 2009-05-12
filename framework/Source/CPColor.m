
#import "CPColor.h"
#import "CPColorSpace.h"


@implementation CPColor

@synthesize cgColor;

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

+(CPColor *)colorWithCGColor:(CGColorRef)newCGColor 
{
    return [[[CPColor alloc] initWithCGColor:newCGColor] autorelease];
}

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
