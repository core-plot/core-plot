
#import "CPTextStyle.h"
#import "CPTextStylePlatformSpecific.h"
#import "CPPlatformSpecificCategories.h"
#import "CPPlatformSpecificFunctions.h"

/**	@brief NSString extensions for drawing styled text.
 **/

@implementation NSString(CPTextStyleExtensions)

#pragma mark -
#pragma mark Layout

/**	@brief Determines the size of text drawn with the given style.
 *	@param style The text style.
 *	@return The size of the text when drawn with the given style.
 **/
-(CGSize)sizeWithStyle:(CPTextStyle *)style
{	
	NSFont *theFont = [NSFont fontWithName:style.fontName size:style.fontSize];
	
	CGSize textSize;
	if (theFont) {
		textSize = NSSizeToCGSize([self sizeWithAttributes:[NSDictionary dictionaryWithObject:theFont forKey:NSFontAttributeName]]);
	} else {
		textSize = CGSizeMake(0.0, 0.0);
	}
	
	return textSize;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the text into the given graphics context using the given style.
 *  @param point The origin of the drawing position.
 *	@param style The text style.
 *  @param context The graphics context to draw into.
 **/
-(void)drawAtPoint:(CGPoint)point withStyle:(CPTextStyle *)style inContext:(CGContextRef)context
{	
	if ( style.color == nil ) return;
	
	CGColorRef textColor = style.color.cgColor;
	
	CGContextSetStrokeColorWithColor(context, textColor);	
	CGContextSetFillColorWithColor(context, textColor);
	
	CPPushCGContext(context);	
	NSFont *theFont = [NSFont fontWithName:style.fontName size:style.fontSize];
	if (theFont) {
		NSColor *foregroundColor = style.color.nsColor;
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
		[self drawAtPoint:NSPointFromCGPoint(point) withAttributes:attributes];
	}
	CPPopCGContext();
}

@end
