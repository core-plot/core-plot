#import "CPTextLayer.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPColor.h"
#import "CPColorSpace.h"
#import "CPPlatformSpecificCategories.h"

#define USECROSSPLATFORMUNICODETEXTRENDERING

@interface CPTextLayer ()

+(NSString *)defaultFontName;

@end

@implementation CPTextLayer

#pragma mark -
#pragma mark Accessors

@synthesize text;
@synthesize fontSize;
@synthesize fontName;
@synthesize fontColor;

-(void)setText:(NSString *)newValue
{
	if ([text isEqualToString:newValue]) {
		return;
	}
	
	[text release];
	text = [newValue copy];
	
	[self sizeToFit];
}

-(void)setFontSize:(CGFloat)newValue
{
	if (fontSize == newValue) {
		return;
	}
	
	fontSize = newValue;
	[self sizeToFit];
}

-(void)setFontName:(NSString *)newValue
{
	if (!newValue) {
		return;
	}
	if ([fontName isEqualToString:newValue]) {
		return;
	}
	
	[fontName release];
	fontName = [newValue copy];
	
	[self sizeToFit];
}

#pragma mark -
#pragma mark Initialization and teardown

+(NSString *)defaultFontName
{
    return @"Helvetica";
}

-(id)initWithString:(NSString *)newText fontSize:(CGFloat)newFontSize
{
	if (self = [super init]) {	
		self.needsDisplayOnBoundsChange = NO;
		fontSize = newFontSize;
		fontName = [[[self class] defaultFontName] retain];
		fontColor = [[CPColor blackColor] retain];
		text = [newText copy];
		[self sizeToFit];
	}

	return self;
}

-(void)dealloc 
{
	// don't use assessors here--don't need to call sizeToFit from dealloc
	[fontColor release];
	[fontName release];
	[text release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Layout

-(void)sizeToFit
{
	// TODO: Put a spacing inset around the edges of the text?
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIFont *theFont = [UIFont fontWithName:self.fontName size:self.fontSize];
	CGSize textSize = [self.text sizeWithFont:theFont];
#else
	NSFont *theFont = [NSFont fontWithName:self.fontName size:self.fontSize];
	CGSize textSize;
	if (theFont) {
		textSize = NSSizeToCGSize([self.text sizeWithAttributes:[NSDictionary dictionaryWithObject:theFont forKey:NSFontAttributeName]]);
	} else {
		textSize = CGSizeMake(0.0, 0.0);
	}
#endif
	CGPoint layerOrigin = self.frame.origin;
	self.frame = CGRectMake(layerOrigin.x, layerOrigin.y, textSize.width, textSize.height);
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if (!self.fontColor) {
		return;
	}
	
#if defined(USECROSSPLATFORMUNICODETEXTRENDERING)
	// Cross-platform text drawing, with Unicode support
	
    CPPushCGContext(context);
	
	CGContextSetStrokeColorWithColor(context, self.fontColor.cgColor);	
	CGContextSetFillColorWithColor(context, self.fontColor.cgColor);
	CGContextSetAllowsAntialiasing(context, true);
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0f, self.frame.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	UIFont *theFont = [UIFont fontWithName:self.fontName size:self.fontSize];
	[self.text drawAtPoint:CGPointZero withFont:theFont];
	CGContextRestoreGState(context);
#else
	NSFont *theFont = [NSFont fontWithName:self.fontName size:self.fontSize];
	if (theFont) {
		[self.text drawAtPoint:NSZeroPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, self.fontColor.nsColor, NSForegroundColorAttributeName, nil]];
	}
#endif
	
	CGContextSetAllowsAntialiasing(context, false);
	
    CPPopCGContext();
	
#else
	// Pure Quartz drawing:
	
	CGContextSetStrokeColorWithColor(context, self.fontColor.cgColor);	
	CGContextSetFillColorWithColor(context, self.fontColor.cgColor);
	
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSelectFont(context, STANDARDLABELFONTNAME,(self.fontSize * scale), kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextSetTextPosition(context, 0.0f, round(self.fontSize / 4.0f));
	CGContextShowText(context, [self.text UTF8String], strlen([self.text UTF8String]));
	CGContextSetAllowsAntialiasing(context, false);
	
	CGContextSetShadowWithColor( context, CGSizeMake( 0.0, 0.0 ), 5.0f, self.fontColor.cgColor );
#endif
}

@end
