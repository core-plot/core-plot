
#import "CPTextStyle.h"
#import "CPTextStylePlatformSpecific.h"
#import "CPPlatformSpecificCategories.h"
#import "CPPlatformSpecificFunctions.h"

@implementation NSString (CPTextStyleExtensions)

#pragma mark -
#pragma mark Layout

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
#pragma mark Drawing of Text

-(void)drawAtPoint:(CGPoint)point withStyle:(CPTextStyle *)style inContext:(CGContextRef)context
{	
	if ( style.color == nil ) return;
	
	CGContextSetAllowsAntialiasing(context, true);

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
	
	CGContextSetAllowsAntialiasing(context, false);
}

@end
