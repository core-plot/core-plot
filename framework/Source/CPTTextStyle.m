#import "CPTTextStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTColor.h"
#import "NSCoderExtensions.h"

/**	@cond */
@interface CPTTextStyle ()

@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPTColor *color;
@property(readwrite, assign, nonatomic) CPTTextAlignment textAlignment;

@end
/**	@endcond */

/** @brief Immutable wrapper for various text style properties.
 *
 *  If you need to customize properties, you should create a CPTMutableTextStyle.
 **/

@implementation CPTTextStyle

/** @property fontSize
 *  @brief The font size.
 **/
@synthesize fontSize;

/** @property fontName
 *  @brief The font name.
 **/
@synthesize fontName;

/** @property color
 *  @brief The current text color.
 **/
@synthesize color;

/** @property textAlignment
 *  @brief The paragraph alignment for multi-line text.
 **/
@synthesize textAlignment;

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTTextStyle instance.
 *  @return A new CPTTextStyle instance.
 **/
+(id)textStyle
{
	return [[[self alloc] init] autorelease];
}

#pragma mark -
#pragma mark Initialization and teardown

-(id)init 
{
	if ( (self = [super init]) ) {
		fontName = @"Helvetica";
		fontSize = 12.0;
		color = [[CPTColor blackColor] retain];
		textAlignment = CPTTextAlignmentLeft;
	}
	return self;
}

-(void)dealloc
{
	[fontName release];
	[color release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.fontName forKey:@"CPTTextStyle.fontName"];
	[coder encodeCGFloat:self.fontSize forKey:@"CPTTextStyle.fontSize"];
	[coder encodeObject:self.color forKey:@"CPTTextStyle.color"];
	[coder encodeInteger:self.textAlignment forKey:@"CPTTextStyle.textAlignment"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if ( self ) {
		self->fontName = [[coder decodeObjectForKey:@"CPTTextStyle.fontName"] copy];
		self->fontSize = [coder decodeCGFloatForKey:@"CPTTextStyle.fontSize"];
		self->color = [[coder decodeObjectForKey:@"CPTTextStyle.color"] copy];
		self->textAlignment = [coder decodeIntegerForKey:@"CPTTextStyle.textAlignment"];
	}
    return self;
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone 
{
	CPTTextStyle *newCopy = [[CPTTextStyle allocWithZone:zone] init];
	newCopy->fontName = [self->fontName copy];
	newCopy->color = [self->color copy];
	newCopy->fontSize = self->fontSize;
	newCopy->textAlignment = self->textAlignment;
	return newCopy;
}

#pragma mark -
#pragma mark NSMutableCopying

-(id)mutableCopyWithZone:(NSZone *)zone 
{
	CPTTextStyle *newCopy = [[CPTMutableTextStyle allocWithZone:zone] init];
	newCopy->fontName = [self->fontName copy];
	newCopy->color = [self->color copy];
	newCopy->fontSize = self->fontSize;
	newCopy->textAlignment = self->textAlignment;
	return newCopy;
}

@end
