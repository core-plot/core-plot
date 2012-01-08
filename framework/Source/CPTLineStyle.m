#import "CPTLineStyle.h"

#import "CPTColor.h"
#import "CPTMutableLineStyle.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"

///	@cond
@interface CPTLineStyle()

@property (nonatomic, readwrite, assign) CGLineCap lineCap;
@property (nonatomic, readwrite, assign) CGLineJoin lineJoin;
@property (nonatomic, readwrite, assign) CGFloat miterLimit;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, retain) NSArray *dashPattern;
@property (nonatomic, readwrite, assign) CGFloat patternPhase;
@property (nonatomic, readwrite, retain) CPTColor *lineColor;

@end

///	@endcond

/** @brief Immutable wrapper for various line drawing properties.
 *
 *  Create a CPTMutableLineStyle if you want to customize properties.
 *
 *	@see See Apple's <a href="http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF105">Quartz 2D</a>
 *	and <a href="http://developer.apple.com/documentation/GraphicsImaging/Reference/CGContext/Reference/reference.html">CGContext</a>
 *	documentation for more information about each of these properties.
 **/

@implementation CPTLineStyle

/** @property lineCap
 *  @brief The style for the endpoints of lines drawn in a graphics context. Default is <code>kCGLineCapButt</code>.
 **/
@synthesize lineCap;

/** @property lineJoin
 *  @brief The style for the joins of connected lines in a graphics context. Default is <code>kCGLineJoinMiter</code>.
 **/
@synthesize lineJoin;

/** @property miterLimit
 *  @brief The miter limit for the joins of connected lines in a graphics context. Default is 10.0.
 **/
@synthesize miterLimit;

/** @property lineWidth
 *  @brief The line width for a graphics context. Default is 1.0.
 **/
@synthesize lineWidth;

/** @property dashPattern
 *  @brief The dash-and-space pattern for the line. Default is <code>nil</code>.
 **/
@synthesize dashPattern;

/** @property patternPhase
 *  @brief The starting phase of the line dash pattern. Default is 0.0.
 **/
@synthesize patternPhase;

/** @property lineColor
 *  @brief The current stroke color in a context. Default is solid black.
 **/
@synthesize lineColor;

#pragma mark -
#pragma mark init/dealloc

/** @brief Creates and returns a new CPTLineStyle instance.
 *  @return A new CPTLineStyle instance.
 **/
+(id)lineStyle
{
	return [[[self alloc] init] autorelease];
}

-(id)init
{
	if ( (self = [super init]) ) {
		lineCap		 = kCGLineCapButt;
		lineJoin	 = kCGLineJoinMiter;
		miterLimit	 = 10.0;
		lineWidth	 = 1.0;
		dashPattern	 = nil;
		patternPhase = 0.0;
		lineColor	 = [[CPTColor blackColor] retain];
	}
	return self;
}

-(void)dealloc
{
	[lineColor release];
	[dashPattern release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInteger:self.lineCap forKey:@"CPTLineStyle.lineCap"];
	[coder encodeInteger:self.lineJoin forKey:@"CPTLineStyle.lineJoin"];
	[coder encodeCGFloat:self.miterLimit forKey:@"CPTLineStyle.miterLimit"];
	[coder encodeCGFloat:self.lineWidth forKey:@"CPTLineStyle.lineWidth"];
	[coder encodeObject:self.dashPattern forKey:@"CPTLineStyle.dashPattern"];
	[coder encodeCGFloat:self.patternPhase forKey:@"CPTLineStyle.patternPhase"];
	[coder encodeObject:self.lineColor forKey:@"CPTLineStyle.lineColor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		lineCap		 = [coder decodeIntegerForKey:@"CPTLineStyle.lineCap"];
		lineJoin	 = [coder decodeIntegerForKey:@"CPTLineStyle.lineJoin"];
		miterLimit	 = [coder decodeCGFloatForKey:@"CPTLineStyle.miterLimit"];
		lineWidth	 = [coder decodeCGFloatForKey:@"CPTLineStyle.lineWidth"];
		dashPattern	 = [[coder decodeObjectForKey:@"CPTLineStyle.dashPattern"] retain];
		patternPhase = [coder decodeCGFloatForKey:@"CPTLineStyle.patternPhase"];
		lineColor	 = [[coder decodeObjectForKey:@"CPTLineStyle.lineColor"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

/** @brief Sets all of the line drawing properties in the given graphics context.
 *  @param theContext The graphics context.
 **/
-(void)setLineStyleInContext:(CGContextRef)theContext
{
	CGContextSetLineCap(theContext, lineCap);
	CGContextSetLineJoin(theContext, lineJoin);
	CGContextSetMiterLimit(theContext, miterLimit);
	CGContextSetLineWidth(theContext, lineWidth);
	NSUInteger dashCount = dashPattern.count;
	if ( dashCount > 0 ) {
		CGFloat *dashLengths = (CGFloat *)calloc( dashCount, sizeof(CGFloat) );

		NSUInteger dashCounter = 0;
		for ( NSNumber *currentDashLength in dashPattern ) {
			dashLengths[dashCounter++] = [currentDashLength cgFloatValue];
		}

		CGContextSetLineDash(theContext, patternPhase, dashLengths, dashCount);
		free(dashLengths);
	}
	else {
		CGContextSetLineDash(theContext, 0.0, NULL, 0);
	}
	CGContextSetStrokeColorWithColor(theContext, lineColor.cgColor);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPTLineStyle *styleCopy = [[CPTLineStyle allocWithZone:zone] init];

	styleCopy->lineCap		= self->lineCap;
	styleCopy->lineJoin		= self->lineJoin;
	styleCopy->miterLimit	= self->miterLimit;
	styleCopy->lineWidth	= self->lineWidth;
	styleCopy->dashPattern	= [self->dashPattern copy];
	styleCopy->patternPhase = self->patternPhase;
	styleCopy->lineColor	= [self->lineColor copy];

	return styleCopy;
}

#pragma mark -
#pragma mark NSMutableCopying methods

-(id)mutableCopyWithZone:(NSZone *)zone
{
	CPTLineStyle *styleCopy = [[CPTMutableLineStyle allocWithZone:zone] init];

	styleCopy->lineCap		= self->lineCap;
	styleCopy->lineJoin		= self->lineJoin;
	styleCopy->miterLimit	= self->miterLimit;
	styleCopy->lineWidth	= self->lineWidth;
	styleCopy->dashPattern	= [self->dashPattern copy];
	styleCopy->patternPhase = self->patternPhase;
	styleCopy->lineColor	= [self->lineColor copy];

	return styleCopy;
}

@end
