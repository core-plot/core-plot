#import "CPTMutableTextStyle.h"

/** @brief Mutable wrapper for text style properties.
 *
 *  Use this whenever you need to customize the properties of a text style.
 **/

@implementation CPTMutableTextStyle

/** @property CGFloat fontSize
 *  @brief The font size. Default is @num{12.0}.
 **/
@dynamic fontSize;

/** @property NSString *fontName
 *  @brief The font name. Default is Helvetica.
 **/
@dynamic fontName;

/** @property CPTColor *color
 *  @brief The current text color. Default is solid black.
 **/
@dynamic color;

/** @property CPTTextAlignment textAlignment
 *  @brief The paragraph alignment for multi-line text. Default is #CPTTextAlignmentLeft.
 **/
@dynamic textAlignment;

/** @property NSLineBreakMode lineBreakMode
 *  @brief The line break mode used when laying out the text. Default is @link NSParagraphStyle::NSLineBreakByWordWrapping NSLineBreakByWordWrapping @endlink.
 **/
@dynamic lineBreakMode;

/** @brief Creates and returns a new CPTMutableTextStyle instance initialized from an existing CPTTextStyle.
 *
 *  The text style will be initalized with values from the given textStyle, useful to create
 *  a mutable copy from an immutable instance.
 *
 *  @param textStyle An existing CPTTextStyle.
 *  @return A new CPTMutableTextStyle instance.
 **/
+(instancetype)textStyleWithStyle:(CPTTextStyle *)textStyle
{
    CPTMutableTextStyle *newTextStyle = [[CPTMutableTextStyle alloc] init];

    newTextStyle.color         = textStyle.color;
    newTextStyle.fontName      = textStyle.fontName;
    newTextStyle.fontSize      = textStyle.fontSize;
    newTextStyle.textAlignment = textStyle.textAlignment;
    newTextStyle.lineBreakMode = textStyle.lineBreakMode;

    return newTextStyle;
}

@end
