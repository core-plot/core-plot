#import "CPTTextStyle.h"

#import "CPTColor.h"
#import "CPTDefinitions.h"
#import "CPTMutableTextStyle.h"
#import "NSCoderExtensions.h"

/// @cond
@interface CPTTextStyle()

@property (readwrite, copy, nonatomic) NSString *fontName;
@property (readwrite, assign, nonatomic) CGFloat fontSize;
@property (readwrite, copy, nonatomic) CPTColor *color;
@property (readwrite, assign, nonatomic) CPTTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) NSLineBreakMode lineBreakMode;

@end

/// @endcond

#pragma mark -

/** @brief Immutable wrapper for various text style properties.
 *
 *  If you need to customize properties, you should create a CPTMutableTextStyle.
 **/

@implementation CPTTextStyle

/** @property CGFloat fontSize
 *  @brief The font size. Default is @num{12.0}.
 **/
@synthesize fontSize;

/** @property NSString *fontName
 *  @brief The font name. Default is Helvetica.
 **/
@synthesize fontName;

/** @property CPTColor *color
 *  @brief The current text color. Default is solid black.
 **/
@synthesize color;

/** @property CPTTextAlignment textAlignment
 *  @brief The paragraph alignment for multi-line text. Default is #CPTTextAlignmentLeft.
 **/
@synthesize textAlignment;

/** @property NSLineBreakMode lineBreakMode
 *  @brief The line break mode used when laying out the text. Default is @link NSParagraphStyle::NSLineBreakByWordWrapping NSLineBreakByWordWrapping @endlink.
 **/
@synthesize lineBreakMode;

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
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTAnnotation object.
 *
 *  The initialized object will have the following properties:
 *  - @ref fontName = Helvetica
 *  - @ref fontSize = @num{12.0}
 *  - @ref color = opaque black
 *  - @ref textAlignment = #CPTTextAlignmentLeft
 *  - @ref lineBreakMode = @link NSParagraphStyle::NSLineBreakByWordWrapping NSLineBreakByWordWrapping @endlink
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        fontName      = @"Helvetica";
        fontSize      = CPTFloat(12.0);
        color         = [[CPTColor blackColor] retain];
        textAlignment = CPTTextAlignmentLeft;
        lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [fontName release];
    [color release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.fontName forKey:@"CPTTextStyle.fontName"];
    [coder encodeCGFloat:self.fontSize forKey:@"CPTTextStyle.fontSize"];
    [coder encodeObject:self.color forKey:@"CPTTextStyle.color"];
    [coder encodeInt:self.textAlignment forKey:@"CPTTextStyle.textAlignment"];
    [coder encodeInteger:(NSInteger)self.lineBreakMode forKey:@"CPTTextStyle.lineBreakMode"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        self->fontName      = [[coder decodeObjectForKey:@"CPTTextStyle.fontName"] copy];
        self->fontSize      = [coder decodeCGFloatForKey:@"CPTTextStyle.fontSize"];
        self->color         = [[coder decodeObjectForKey:@"CPTTextStyle.color"] copy];
        self->textAlignment = (CPTTextAlignment)[coder decodeIntForKey : @"CPTTextStyle.textAlignment"];
        self->lineBreakMode = (NSLineBreakMode)[coder decodeIntegerForKey : @"CPTTextStyle.lineBreakMode"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTTextStyle *newCopy = [[CPTTextStyle allocWithZone:zone] init];

    newCopy->fontName      = [self->fontName copy];
    newCopy->color         = [self->color copy];
    newCopy->fontSize      = self->fontSize;
    newCopy->textAlignment = self->textAlignment;
    newCopy->lineBreakMode = self->lineBreakMode;
    return newCopy;
}

/// @endcond

#pragma mark -
#pragma mark NSMutableCopying Methods

/// @cond

-(id)mutableCopyWithZone:(NSZone *)zone
{
    CPTTextStyle *newCopy = [[CPTMutableTextStyle allocWithZone:zone] init];

    newCopy->fontName      = [self->fontName copy];
    newCopy->color         = [self->color copy];
    newCopy->fontSize      = self->fontSize;
    newCopy->textAlignment = self->textAlignment;
    newCopy->lineBreakMode = self->lineBreakMode;
    return newCopy;
}

/// @endcond

@end
