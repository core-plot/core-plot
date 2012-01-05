#import "CPTColor.h"

#import "CPTColorSpace.h"
#import "CPTPlatformSpecificFunctions.h"
#import "NSCoderExtensions.h"

/** @brief An immutable color.
 *
 *  An immutable object wrapper class around CGColorRef.
 *	It provides convenience methods to create the same predefined colors
 *	defined by NSColor and UIColor.
 **/
@implementation CPTColor

/**	@property cgColor
 *	@brief The CGColorRef to wrap around.
 **/
@synthesize cgColor;

#pragma mark -
#pragma mark Factory Methods

/** @brief Returns a shared instance of CPTColor initialized with a fully transparent color.
 *
 *  @return A shared CPTColor object initialized with a fully transparent color.
 **/
+(CPTColor *)clearColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		CGColorRef clear  = NULL;
		CGFloat values[4] = { 0.0, 0.0, 0.0, 0.0 };
		clear = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, values);
		color = [[CPTColor alloc] initWithCGColor:clear];
		CGColorRelease(clear);
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque white color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque white color.
 **/
+(CPTColor *)whiteColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[self colorWithGenericGray:1.0] retain];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 2/3 gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 2/3 gray color.
 **/
+(CPTColor *)lightGrayColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[self colorWithGenericGray:2.0 / 3.0] retain];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 50% gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 50% gray color.
 **/
+(CPTColor *)grayColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[self colorWithGenericGray:0.5] retain];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque 1/3 gray color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque 1/3 gray color.
 **/
+(CPTColor *)darkGrayColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[self colorWithGenericGray:1.0 / 3.0] retain];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque black color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque black color.
 **/
+(CPTColor *)blackColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[self colorWithGenericGray:0.0] retain];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque red color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque red color.
 **/
+(CPTColor *)redColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque green color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque green color.
 **/
+(CPTColor *)greenColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:0.0 green:1.0 blue:0.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque blue color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque blue color.
 **/
+(CPTColor *)blueColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:0.0 green:0.0 blue:1.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque cyan color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque cyan color.
 **/
+(CPTColor *)cyanColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:0.0 green:1.0 blue:1.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque yellow color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque yellow color.
 **/
+(CPTColor *)yellowColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:1.0 green:1.0 blue:0.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque magenta color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque magenta color.
 **/
+(CPTColor *)magentaColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:1.0 green:0.0 blue:1.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque orange color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque orange color.
 **/
+(CPTColor *)orangeColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:1.0 green:0.5 blue:0.0 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque purple color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque purple color.
 **/
+(CPTColor *)purpleColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:0.5 green:0.0 blue:0.5 alpha:1.0];
	}
	return color;
}

/** @brief Returns a shared instance of CPTColor initialized with a fully opaque brown color.
 *
 *  @return A shared CPTColor object initialized with a fully opaque brown color.
 **/
+(CPTColor *)brownColor
{
	static CPTColor *color = nil;

	if ( nil == color ) {
		color = [[CPTColor alloc] initWithComponentRed:0.6 green:0.4 blue:0.2 alpha:1.0];
	}
	return color;
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided CGColorRef.
 *  @param newCGColor The color to wrap.
 *  @return A new CPTColor instance initialized with the provided CGColorRef.
 **/
+(CPTColor *)colorWithCGColor:(CGColorRef)newCGColor
{
	return [[[CPTColor alloc] initWithCGColor:newCGColor] autorelease];
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided RGBA color components.
 *  @param red The red component (0 ≤ red ≤ 1).
 *  @param green The green component (0 ≤ green ≤ 1).
 *  @param blue The blue component (0 ≤ blue ≤ 1).
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return A new CPTColor instance initialized with the provided RGBA color components.
 **/
+(CPTColor *)colorWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	return [[[CPTColor alloc] initWithComponentRed:red green:green blue:blue alpha:alpha] autorelease];
}

/** @brief Creates and returns a new CPTColor instance initialized with the provided gray level.
 *  @param gray The gray level (0 ≤ gray ≤ 1).
 *  @return A new CPTColor instance initialized with the provided gray level.
 **/
+(CPTColor *)colorWithGenericGray:(CGFloat)gray
{
	CGFloat values[4]	= { gray, gray, gray, 1.0 };
	CGColorRef colorRef = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, values);
	CPTColor *color		= [[CPTColor alloc] initWithCGColor:colorRef];

	CGColorRelease(colorRef);
	return [color autorelease];
}

#pragma mark -
#pragma mark Initialize/Deallocate

/** @brief Initializes a newly allocated CPTColor object with the provided CGColorRef.
 *
 *	@param newCGColor The color to wrap.
 *  @return The initialized CPTColor object.
 **/
-(id)initWithCGColor:(CGColorRef)newCGColor
{
	if ( (self = [super init]) ) {
		CGColorRetain(newCGColor);
		cgColor = newCGColor;
	}
	return self;
}

/** @brief Initializes a newly allocated CPTColor object with the provided RGBA color components.
 *
 *  @param red The red component (0 ≤ red ≤ 1).
 *  @param green The green component (0 ≤ green ≤ 1).
 *  @param blue The blue component (0 ≤ blue ≤ 1).
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return The initialized CPTColor object.
 **/
-(id)initWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	CGFloat colorComponents[4];

	colorComponents[0] = red;
	colorComponents[1] = green;
	colorComponents[2] = blue;
	colorComponents[3] = alpha;
	CGColorRef color = CGColorCreate([CPTColorSpace genericRGBSpace].cgColorSpace, colorComponents);
	self = [self initWithCGColor:color];
	CGColorRelease(color);
	return self;
}

-(void)dealloc
{
	CGColorRelease(cgColor);
	[super dealloc];
}

-(void)finalize
{
	CGColorRelease(cgColor);
	[super finalize];
}

#pragma mark -
#pragma mark Creating colors from other colors

/** @brief Creates and returns a new CPTColor instance having color components identical to the current object
 *	but having the provided alpha component.
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return A new CPTColor instance having the provided alpha component.
 **/
-(CPTColor *)colorWithAlphaComponent:(CGFloat)alpha
{
	CGColorRef newCGColor = CGColorCreateCopyWithAlpha(self.cgColor, alpha);
	CPTColor *newColor	  = [CPTColor colorWithCGColor:newCGColor];

	CGColorRelease(newCGColor);
	return newColor;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	CGColorRef theColor = self.cgColor;

	[coder encodeCGColorSpace:CGColorGetColorSpace(theColor) forKey:@"CPTColor.colorSpace"];

	size_t numberOfComponents = CGColorGetNumberOfComponents(theColor);
	[coder encodeInteger:numberOfComponents forKey:@"CPTColor.numberOfComponents"];

	const CGFloat *colorComponents = CGColorGetComponents(theColor);

	for ( size_t i = 0; i < numberOfComponents; i++ ) {
		NSString *newKey = [[NSString alloc] initWithFormat:@"CPTColor.component[%u]", i];
		[coder encodeCGFloat:colorComponents[i] forKey:newKey];
		[newKey release];
	}
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		CGColorSpaceRef colorSpace = [coder newCGColorSpaceDecodeForKey:@"CPTColor.colorSpace"];

		size_t numberOfComponents = [coder decodeIntegerForKey:@"CPTColor.numberOfComponents"];

		CGFloat *colorComponents = malloc( numberOfComponents * sizeof(CGFloat) );

		for ( size_t i = 0; i < numberOfComponents; i++ ) {
			NSString *newKey = [[NSString alloc] initWithFormat:@"CPTColor.component[%u]", i];
			colorComponents[i] = [coder decodeCGFloatForKey:newKey];
			[newKey release];
		}

		cgColor = CGColorCreate(colorSpace, colorComponents);
		CGColorSpaceRelease(colorSpace);
		free(colorComponents);
	}
	return self;
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CGColorRef cgColorCopy = NULL;

	if ( cgColor ) {
		cgColorCopy = CGColorCreateCopy(cgColor);
	}
	CPTColor *colorCopy = [[[self class] allocWithZone:zone] initWithCGColor:cgColorCopy];
	CGColorRelease(cgColorCopy);
	return colorCopy;
}

#pragma mark -
#pragma mark Color comparison

-(BOOL)isEqual:(id)object
{
	if ( self == object ) {
		return YES;
	}
	else if ( [object isKindOfClass:[self class]] ) {
		return CGColorEqualToColor(self.cgColor, ( (CPTColor *)object ).cgColor);
	}
	else {
		return NO;
	}
}

-(NSUInteger)hash
{
	// Equal objects must hash the same.
	CGFloat theHash	   = 0.0;
	CGFloat multiplier = 256.0;

	CGColorRef theColor			   = self.cgColor;
	size_t numberOfComponents	   = CGColorGetNumberOfComponents(theColor);
	const CGFloat *colorComponents = CGColorGetComponents(theColor);

	for ( NSUInteger i = 0; i < numberOfComponents; i++ ) {
		theHash	   += multiplier * colorComponents[i];
		multiplier *= 256.0;
	}

	return (NSUInteger)theHash;
}

@end
