#import "CPTTextStylePlatformSpecific.h"

#import "CPTColor.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlatformSpecificCategories.h"
#import "CPTPlatformSpecificFunctions.h"

@implementation CPTTextStyle(CPTPlatformSpecificTextStyleExtensions)

/** @property NSDictionary *attributes
 *  @brief A dictionary of standard text attributes suitable for formatting an NSAttributedString.
 *
 *  The dictionary will contain values for the following keys that represent the receiver's text style:
 *  - #NSFontAttributeName: The font used to draw text. If missing, no font information was specified.
 *  - #NSForegroundColorAttributeName: The color used to draw text. If missing, no color information was specified.
 *  - #NSParagraphStyleAttributeName: The text alignment and line break mode used to draw multi-line text.
 **/
@dynamic attributes;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTTextStyle instance initialized from a dictionary of text attributes.
 *
 *  The text style will be initalized with values associated with the following keys:
 *  - #NSFontAttributeName: Sets the @link CPTTextStyle::fontName fontName @endlink
 *  and @link CPTTextStyle::fontSize fontSize @endlink.
 *  - #NSForegroundColorAttributeName: Sets the @link CPTTextStyle::color color @endlink.
 *  - #NSParagraphStyleAttributeName: Sets the @link CPTTextStyle::textAlignment textAlignment @endlink and @link CPTTextStyle::lineBreakMode lineBreakMode @endlink.
 *
 *  Properties associated with missing keys will be inialized to their default values.
 *
 *  @param attributes A dictionary of standard text attributes.
 *  @return A new CPTTextStyle instance.
 **/
+(id)textStyleWithAttributes:(NSDictionary *)attributes
{
    CPTMutableTextStyle *newStyle = [CPTMutableTextStyle textStyle];

    // Font
    BOOL hasFontAttributeName = (&NSFontAttributeName != NULL);

    if ( hasFontAttributeName ) {
        UIFont *styleFont = [attributes valueForKey:NSFontAttributeName];

        if ( styleFont ) {
            newStyle.fontName = styleFont.fontName;
            newStyle.fontSize = styleFont.pointSize;
        }
    }

    // Color
    BOOL hasColorAttributeName = (&NSForegroundColorAttributeName != NULL);

    if ( hasColorAttributeName ) {
        UIColor *styleColor = [attributes valueForKey:NSForegroundColorAttributeName];
        if ( styleColor ) {
            newStyle.color = [CPTColor colorWithCGColor:styleColor.CGColor];
        }
    }

    // Text alignment and line break mode
    BOOL hasParagraphAttributeName = (&NSParagraphStyleAttributeName != NULL);

    if ( hasParagraphAttributeName ) {
        NSParagraphStyle *paragraphStyle = [attributes valueForKey:NSParagraphStyleAttributeName];
        if ( paragraphStyle ) {
            newStyle.textAlignment = paragraphStyle.alignment;
            newStyle.lineBreakMode = paragraphStyle.lineBreakMode;
        }
    }

    return [newStyle copy];
}

#pragma mark -
#pragma mark Accessors

/// @cond

-(NSDictionary *)attributes
{
    NSMutableDictionary *myAttributes = [NSMutableDictionary dictionary];

    // Font
    UIFont *styleFont = [UIFont fontWithName:self.fontName size:self.fontSize];

    if ( styleFont ) {
        [myAttributes setValue:styleFont
                        forKey:NSFontAttributeName];
    }

    // Color
    UIColor *styleColor = self.color.uiColor;
    if ( styleColor ) {
        [myAttributes setValue:styleColor
                        forKey:NSForegroundColorAttributeName];
    }

    // Text alignment and line break mode
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment     = self.textAlignment;
    paragraphStyle.lineBreakMode = self.lineBreakMode;

    [myAttributes setValue:paragraphStyle
                    forKey:NSParagraphStyleAttributeName];

    return [myAttributes copy];
}

/// @endcond

@end

#pragma mark -

@implementation CPTMutableTextStyle(CPTPlatformSpecificMutableTextStyleExtensions)

/// @cond

+(id)textStyleWithAttributes:(NSDictionary *)attributes
{
    CPTMutableTextStyle *newStyle = [CPTMutableTextStyle textStyle];

    // Font
    UIFont *styleFont = [attributes valueForKey:NSFontAttributeName];

    if ( styleFont ) {
        newStyle.fontName = styleFont.fontName;
        newStyle.fontSize = styleFont.pointSize;
    }

    // Color
    UIColor *styleColor = [attributes valueForKey:NSForegroundColorAttributeName];
    if ( styleColor ) {
        newStyle.color = [CPTColor colorWithCGColor:styleColor.CGColor];
    }

    // Text alignment and line break mode
    NSParagraphStyle *paragraphStyle = [attributes valueForKey:NSParagraphStyleAttributeName];
    if ( paragraphStyle ) {
        newStyle.textAlignment = paragraphStyle.alignment;
        newStyle.lineBreakMode = paragraphStyle.lineBreakMode;
    }

    return newStyle;
}

/// @endcond

@end

#pragma mark -

@implementation NSString(CPTTextStyleExtensions)

#pragma mark -
#pragma mark Layout

/** @brief Determines the size of text drawn with the given style.
 *  @param style The text style.
 *  @return The size of the text when drawn with the given style.
 **/
-(CGSize)sizeWithTextStyle:(CPTTextStyle *)style
{
    UIFont *theFont = [UIFont fontWithName:style.fontName size:style.fontSize];
    CGSize textSize = [self sizeWithFont:theFont constrainedToSize:CGSizeMake( CPTFloat(10000.0), CPTFloat(10000.0) )];

    return textSize;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the text into the given graphics context using the given style.
 *  @param rect The bounding rectangle in which to draw the text.
 *  @param style The text style.
 *  @param context The graphics context to draw into.
 **/
-(void)drawInRect:(CGRect)rect withTextStyle:(CPTTextStyle *)style inContext:(CGContextRef)context
{
    if ( style.color == nil ) {
        return;
    }

    CGContextSaveGState(context);
    CGColorRef textColor = style.color.cgColor;

    CGContextSetStrokeColorWithColor(context, textColor);
    CGContextSetFillColorWithColor(context, textColor);

    CPTPushCGContext(context);

    UIFont *theFont = [UIFont fontWithName:style.fontName size:style.fontSize];

    [self drawInRect:rect
            withFont:theFont
       lineBreakMode:style.lineBreakMode
           alignment:(NSTextAlignment)style.textAlignment];

    CGContextRestoreGState(context);
    CPTPopCGContext();
}

@end
