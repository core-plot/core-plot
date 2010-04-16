
#import "CPTextStyle.h"
#import "CPTextStylePlatformSpecific.h"
#import "CPPlatformSpecificCategories.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPColor.h"

@implementation NSString(CPTextStyleExtensions)

#pragma mark -
#pragma mark Layout

/**	@brief Determines the size of text drawn with the given style.
 *	@param style The text style.
 *	@return The size of the text when drawn with the given style.
 **/
-(CGSize)sizeWithTextStyle:(CPTextStyle *)style
{	
	UIFont *theFont = [UIFont fontWithName:style.fontName size:style.fontSize];
	CGSize textSize = [self sizeWithFont:theFont];	
	return textSize;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the text into the given graphics context using the given style.
 *  @param point The origin of the drawing position.
 *	@param style The text style.
 *  @param context The graphics context to draw into.
 **/
-(void)drawAtPoint:(CGPoint)point withTextStyle:(CPTextStyle *)style inContext:(CGContextRef)context
{	
	if ( style.color == nil ) return;
    
    CGContextSaveGState(context);
	CGColorRef textColor = style.color.cgColor;
	
	CGContextSetStrokeColorWithColor(context, textColor);	
	CGContextSetFillColorWithColor(context, textColor);
	
	CPPushCGContext(context);	
	
	UIFont *theFont = [UIFont fontWithName:style.fontName size:style.fontSize];
	[self drawAtPoint:point withFont:theFont];
	
	CGContextRestoreGState(context);
	CPPopCGContext();
}

@end
