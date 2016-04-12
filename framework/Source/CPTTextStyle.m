#import "CPTTextStyle.h"

#import "CPTColor.h"
#import "CPTMutableTextStyle.h"
#import "NSCoderExtensions.h"

/// @cond
@interface CPTTextStyle()

@property (readwrite, copy, nonatomic, nullable) NSString *fontName;
@property (readwrite, assign, nonatomic) CGFloat fontSize;
@property (readwrite, copy, nonatomic, nullable) CPTColor *color;
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

/** @property nullable NSString *fontName
 *  @brief The font name. Default is Helvetica.
 **/
@synthesize fontName;

/** @property nullable CPTColor *color
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
+(nonnull instancetype)textStyle
{
    return [[self alloc] init];
}

/** @brief Creates and returns a new text style instance initialized from an existing text style.
 *
 *  The text style will be initalized with values from the given @par{textStyle}.
 *
 *  @param textStyle An existing CPTTextStyle.
 *  @return A new text style instance.
 **/
+(nonnull instancetype)textStyleWithStyle:(nullable CPTTextStyle *)textStyle
{
    CPTTextStyle *newTextStyle = [[self alloc] init];

    newTextStyle.color         = textStyle.color;
    newTextStyle.fontName      = textStyle.fontName;
    newTextStyle.fontSize      = textStyle.fontSize;
    newTextStyle.textAlignment = textStyle.textAlignment;
    newTextStyle.lineBreakMode = textStyle.lineBreakMode;

    return newTextStyle;
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
-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        fontName      = @"Helvetica";
        fontSize      = CPTFloat(12.0);
        color         = [CPTColor blackColor];
        textAlignment = CPTTextAlignmentLeft;
        lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

/// @}

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.fontName forKey:@"CPTTextStyle.fontName"];
    [coder encodeCGFloat:self.fontSize forKey:@"CPTTextStyle.fontSize"];
    [coder encodeObject:self.color forKey:@"CPTTextStyle.color"];
    [coder encodeInteger:self.textAlignment forKey:@"CPTTextStyle.textAlignment"];
    [coder encodeInteger:(NSInteger)self.lineBreakMode forKey:@"CPTTextStyle.lineBreakMode"];
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super init]) ) {
        fontName = [[coder decodeObjectOfClass:[NSString class]
                                        forKey:@"CPTTextStyle.fontName"] copy];
        fontSize = [coder decodeCGFloatForKey:@"CPTTextStyle.fontSize"];
        color    = [[coder decodeObjectOfClass:[CPTColor class]
                                        forKey:@"CPTTextStyle.color"] copy];
        textAlignment = (CPTTextAlignment)[coder decodeIntegerForKey:@"CPTTextStyle.textAlignment"];
        lineBreakMode = (NSLineBreakMode)[coder decodeIntegerForKey:@"CPTTextStyle.lineBreakMode"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
    CPTTextStyle *newCopy = [[CPTTextStyle allocWithZone:zone] init];

    newCopy.fontName      = self.fontName;
    newCopy.color         = self.color;
    newCopy.fontSize      = self.fontSize;
    newCopy.textAlignment = self.textAlignment;
    newCopy.lineBreakMode = self.lineBreakMode;

    return newCopy;
}

/// @endcond

#pragma mark -
#pragma mark NSMutableCopying Methods

/// @cond

-(nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
{
    CPTTextStyle *newCopy = [[CPTMutableTextStyle allocWithZone:zone] init];

    newCopy.fontName      = self.fontName;
    newCopy.color         = self.color;
    newCopy.fontSize      = self.fontSize;
    newCopy.textAlignment = self.textAlignment;
    newCopy.lineBreakMode = self.lineBreakMode;

    return newCopy;
}

/// @endcond

#pragma mark -
#pragma mark Debugging

/// @cond

-(nullable id)debugQuickLookObject
{
    NSString *lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    return [[NSAttributedString alloc] initWithString:lorem attributes:self.attributes];
}

/// @endcond

@end
