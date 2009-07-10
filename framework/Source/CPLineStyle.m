
#import "CPLineStyle.h"
#import "CPLayer.h"
#import "CPColor.h"

/** @brief Wrapper for various line drawing properties.
 *
 *	@see See the Quartz 2D and CGContext documentation for more information about each of these properties.
 **/

@implementation CPLineStyle

/** @property lineCap
 *  @brief Sets the style for the endpoints of lines drawn in a graphics context.
 **/
@synthesize lineCap;

/** @property lineJoin
 *  @brief Sets the style for the joins of connected lines in a graphics context.
 **/
@synthesize lineJoin;

/** @property miterLimit
 *  @brief Sets the miter limit for the joins of connected lines in a graphics context.
 **/
@synthesize miterLimit;

/** @property lineWidth
 *  @brief Sets the line width for a graphics context.
 **/
@synthesize lineWidth;

/** @property patternPhase
 *  @brief Sets the pattern phase of a context.
 **/
@synthesize patternPhase;

/** @property lineColor
 *  @brief Sets the current stroke color in a context.
 **/
@synthesize lineColor;

#pragma mark -
#pragma mark init/dealloc

/** @brief Creates and returns a new CPLineStyle instance.
 *  @return A new CPLineStyle instance.
 **/
+(CPLineStyle *)lineStyle
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

/** @brief Sets all of the line drawing properties in the given graphics context.
 *  @param theContext The graphics context.
 **/
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
