
#import "CPLineStyle.h"
#import "CPLayer.h"
#import "CPColor.h"


@implementation CPLineStyle

@synthesize lineCap, lineJoin, miterLimit, lineWidth, patternPhase, lineColor;

#pragma mark -
#pragma mark init/dealloc

+(CPLineStyle*)lineStyle
{
    return [[[self alloc] init] autorelease];
}

-(id)init
{
	if ( self = [super init] ) {
		self.lineCap = kCGLineCapButt;
		self.lineJoin = kCGLineJoinMiter;
		self.miterLimit = 10.f;
		self.lineWidth = 1.f;
		self.patternPhase = CGSizeMake(0.f, 0.f);
		self.lineColor = [CPColor blackColor];
	}
	return self;
}

-(void)dealloc
{
    self.lineColor = nil;
	[super dealloc];
}

-(void)setLineStyleInContext:(CGContextRef)theContext
{
	CGContextSetLineCap(theContext, lineCap);
	CGContextSetLineJoin(theContext, lineJoin);
	CGContextSetMiterLimit(theContext, miterLimit);
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetPatternPhase(theContext, patternPhase);
	CGContextSetStrokeColorWithColor(theContext, lineColor.cgColor);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
    CPLineStyle *styleCopy = [[[self class] allocWithZone:zone] init];
 	
	styleCopy.lineCap = self.lineCap;
	styleCopy.lineJoin = self.lineJoin;
	styleCopy.miterLimit = self.miterLimit;
	styleCopy.lineWidth = self.lineWidth;
	styleCopy.patternPhase = self.patternPhase;
    CPColor *colorCopy = [self.lineColor copy];
    styleCopy.lineColor = colorCopy;
    [colorCopy release];
    
    return styleCopy;
}

@end
