#import "CPTTextStylePlatformSpecific.h"

#import "CPTMutableTextStyle.h"
#import "CPTPlatformSpecificCategories.h"
#import "CPTPlatformSpecificFunctions.h"

@implementation NSString(CPTTextStyleExtensions)

#pragma mark -
#pragma mark Layout

/**	@brief Determines the size of text drawn with the given style.
 *	@param style The text style.
 *	@return The size of the text when drawn with the given style.
 **/
-(CGSize)sizeWithTextStyle:(CPTTextStyle *)style
{
	NSFont *theFont = [NSFont fontWithName:style.fontName size:style.fontSize];

	CGSize textSize;

	if ( theFont ) {
		NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
									theFont, NSFontAttributeName,
									nil];

		textSize = NSSizeToCGSize([self sizeWithAttributes:attributes]);

		[attributes release];
	}
	else {
		textSize = CGSizeZero;
	}

	return textSize;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the text into the given graphics context using the given style.
 *  @param rect The bounding rectangle in which to draw the text.
 *	@param style The text style.
 *  @param context The graphics context to draw into.
 **/
-(void)drawInRect:(CGRect)rect withTextStyle:(CPTTextStyle *)style inContext:(CGContextRef)context
{
	if ( style.color == nil ) {
		return;
	}

	CGColorRef textColor = style.color.cgColor;

	CGContextSetStrokeColorWithColor(context, textColor);
	CGContextSetFillColorWithColor(context, textColor);

	CPTPushCGContext(context);
	NSFont *theFont = [NSFont fontWithName:style.fontName size:style.fontSize];
	if ( theFont ) {
		NSColor *foregroundColor				= style.color.nsColor;
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

		switch ( style.textAlignment ) {
			case CPTTextAlignmentLeft:
				paragraphStyle.alignment = NSLeftTextAlignment;
				break;

			case CPTTextAlignmentCenter:
				paragraphStyle.alignment = NSCenterTextAlignment;
				break;

			case CPTTextAlignmentRight:
				paragraphStyle.alignment = NSRightTextAlignment;
				break;

			default:
				break;
		}

		NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
									theFont, NSFontAttributeName,
									foregroundColor, NSForegroundColorAttributeName,
									paragraphStyle, NSParagraphStyleAttributeName,
									nil];
		[self drawInRect:NSRectFromCGRect(rect) withAttributes:attributes];

		[paragraphStyle release];
		[attributes release];
	}
	CPTPopCGContext();
}

@end
