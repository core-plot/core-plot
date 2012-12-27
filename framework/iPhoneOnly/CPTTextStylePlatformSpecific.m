#import "CPTTextStylePlatformSpecific.h"

#import "CPTColor.h"
#import "CPTPlatformSpecificCategories.h"
#import "CPTPlatformSpecificFunctions.h"
#import "CPTTextStyle.h"

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
    CGSize textSize = [self sizeWithFont:theFont constrainedToSize:CGSizeMake( (CGFloat)10000.0, (CGFloat)10000.0 )];

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
       lineBreakMode:UILineBreakModeWordWrap
           alignment:(NSTextAlignment)style.textAlignment];

    CGContextRestoreGState(context);
    CPTPopCGContext();
}

@end
