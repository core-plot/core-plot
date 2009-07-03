
#import "_CPFillColor.h"
#import "CPColor.h"

@interface _CPFillColor()

@property (nonatomic, readwrite, copy) CPColor *fillColor;

@end

@implementation _CPFillColor

@synthesize fillColor;

#pragma mark -
#pragma mark init/dealloc

-(id)initWithColor:(CPColor *)aColor 
{
	if (self = [super init]) {
        self.fillColor = aColor;
	}
	return self;
}

-(void)dealloc
{
    self.fillColor = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, self.fillColor.cgColor);
	CGContextFillRect(theContext, theRect);
	CGContextRestoreGState(theContext);
}

-(void)fillPathInContext:(CGContextRef)theContext
{
	CGContextSaveGState(theContext);
	CGContextSetFillColorWithColor(theContext, self.fillColor.cgColor);
	CGContextFillPath(theContext);
	CGContextRestoreGState(theContext);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillColor *copy = [(_CPFillColor *)[[self class] allocWithZone:zone] initWithColor:[self.fillColor copyWithZone:zone]];
	
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
	[coder encodeObject:self.fillColor forKey:@"fillColor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( self = [super init] ) {
		fillColor = [[coder decodeObjectForKey:@"fillColor"] retain];
	}
    return self;
}

@end
