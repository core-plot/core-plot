
#import "CPTextStyle.h"
#import "CPMutableTextStyle.h"
#import "CPColor.h"


@interface CPTextStyle ()

@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPColor *color;

@end


/** @brief Immutable wrapper for various text style properties.
 *
 *  If you need to customize properties, you should create a CPMutableTextStyle.
 **/

@implementation CPTextStyle

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

#pragma mark -
#pragma mark Factory Methods

/** @brief Creates and returns a new CPTextStyle instance.
 *  @return A new CPTextStyle instance.
 **/
+(id)textStyle
{
	return [[[self alloc] init] autorelease];
}

#pragma mark -
#pragma mark Initialization and teardown

-(id)init 
{
	if ( self = [super init] ) {
		fontName = @"Helvetica";
		fontSize = 12.0;
		color = [[CPColor blackColor] retain];
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
	[coder encodeObject:self.fontName forKey:@"fontName"];
	[coder encodeDouble:self.fontSize forKey:@"fontSize"];
	[coder encodeObject:self.color forKey:@"color"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if ( self ) {
		self->fontName = [[coder decodeObjectForKey:@"fontName"] copy];
		self->fontSize = [coder decodeDoubleForKey:@"fontSize"];
		self->color = [[coder decodeObjectForKey:@"color"] copy];
	}
    return self;
}

#pragma mark -
#pragma mark Copying

-(id)copyWithZone:(NSZone *)zone 
{
	CPTextStyle *newCopy = [[CPTextStyle allocWithZone:zone] init];
	newCopy->fontName = [self->fontName copy];
	newCopy->color = [self->color copy];
	newCopy->fontSize = self->fontSize;
	return newCopy;
}

-(id)mutableCopyWithZone:(NSZone *)zone 
{
	CPTextStyle *newCopy = [[CPMutableTextStyle allocWithZone:zone] init];
	newCopy->fontName = [self->fontName copy];
	newCopy->color = [self->color copy];
	newCopy->fontSize = self->fontSize;
	return newCopy;
}

@end
