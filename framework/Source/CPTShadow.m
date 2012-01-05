#import "CPTShadow.h"

#import "CPTColor.h"
#import "CPTMutableShadow.h"
#import "NSCoderExtensions.h"

///	@cond
@interface CPTShadow()

@property (nonatomic, readwrite, assign) CGSize shadowOffset;
@property (nonatomic, readwrite, assign) CGFloat shadowBlurRadius;
@property (nonatomic, readwrite, retain) CPTColor *shadowColor;

@end

///	@endcond

/** @brief Immutable wrapper for various shadow drawing properties.
 *
 *	@see See Apple's <a href="http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadows/dq_shadows.html">Quartz 2D</a>
 *	and <a href="http://developer.apple.com/documentation/GraphicsImaging/Reference/CGContext/Reference/reference.html">CGContext</a>
 *	documentation for more information about each of these properties.
 *
 *  In general, you will want to create a CPTMutableShadow if you want to customize properties.
 **/

@implementation CPTShadow

/** @property shadowOffset
 *  @brief The horizontal and vertical offset values, specified using the width and height fields
 *	of the CGSize data type. The offsets are not affected by custom transformations. Positive values extend
 *	up and to the right. Default is <code>CGSizeZero</code>.
 **/
@synthesize shadowOffset;

/** @property shadowBlurRadius
 *  @brief The blur radius, measured in the default user coordinate space. A value of 0.0 (the default) indicates no blur,
 *	while larger values produce correspondingly larger blurring. This value must not be negative.
 **/
@synthesize shadowBlurRadius;

/** @property shadowColor
 *  @brief The shadow color. If <code>nil</code> (the default), the shadow will not be drawn.
 **/
@synthesize shadowColor;

#pragma mark -
#pragma mark init/dealloc

/** @brief Creates and returns a new CPTShadow instance.
 *  @return A new CPTShadow instance.
 **/
+(id)shadow
{
	return [[[self alloc] init] autorelease];
}

-(id)init
{
	if ( (self = [super init]) ) {
		shadowOffset	 = CGSizeZero;
		shadowBlurRadius = 0.0;
		shadowColor		 = nil;
	}
	return self;
}

-(void)dealloc
{
	[shadowColor release];

	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeCPTSize:self.shadowOffset forKey:@"CPTShadow.shadowOffset"];
	[coder encodeCGFloat:self.shadowBlurRadius forKey:@"CPTShadow.shadowBlurRadius"];
	[coder encodeObject:self.shadowColor forKey:@"CPTShadow.shadowColor"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		shadowOffset	 = [coder decodeCPTSizeForKey:@"CPTShadow.shadowOffset"];
		shadowBlurRadius = [coder decodeCGFloatForKey:@"CPTShadow.shadowBlurRadius"];
		shadowColor		 = [[coder decodeObjectForKey:@"CPTShadow.shadowColor"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

/** @brief Sets the shadow properties in the given graphics context.
 *  @param theContext The graphics context.
 **/
-(void)setShadowInContext:(CGContextRef)theContext
{
	CGContextSetShadowWithColor(theContext,
								self.shadowOffset,
								self.shadowBlurRadius,
								self.shadowColor.cgColor);
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPTShadow *shadowCopy = [[CPTShadow allocWithZone:zone] init];

	shadowCopy->shadowOffset	 = self->shadowOffset;
	shadowCopy->shadowBlurRadius = self->shadowBlurRadius;
	shadowCopy->shadowColor		 = [self->shadowColor copy];

	return shadowCopy;
}

#pragma mark -
#pragma mark NSMutableCopying methods

-(id)mutableCopyWithZone:(NSZone *)zone
{
	CPTShadow *shadowCopy = [[CPTMutableShadow allocWithZone:zone] init];

	shadowCopy->shadowOffset	 = self->shadowOffset;
	shadowCopy->shadowBlurRadius = self->shadowBlurRadius;
	shadowCopy->shadowColor		 = [self->shadowColor copy];

	return shadowCopy;
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setShadowBlurRadius:(CGFloat)newShadowBlurRadius
{
	NSParameterAssert(newShadowBlurRadius >= 0.0);

	if ( newShadowBlurRadius != shadowBlurRadius ) {
		shadowBlurRadius = newShadowBlurRadius;
	}
}

///	@endcond

@end
