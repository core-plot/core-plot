#import "CPTMutableTextStyle.h"

#import "CPTColor.h"

/** @brief Mutable wrapper for text style properties.
 *
 *  Use this whenever you need to customize the properties of a text style.
 **/

@implementation CPTMutableTextStyle

/** @property fontSize
 *  @brief The font size. Default is 12.0.
 **/
@dynamic fontSize;

/** @property fontName
 *  @brief The font name. Default is "Helvetica".
 **/
@dynamic fontName;

/** @property color
 *  @brief The current text color. Default is solid black.
 **/
@dynamic color;

/** @property textAlignment
 *  @brief The paragraph alignment for multi-line text. Default is #CPTTextAlignmentLeft.
 **/
@dynamic textAlignment;

@end
