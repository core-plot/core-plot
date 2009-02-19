

#import "CPTextLayer.h"

#define USECROSSPLATFORMUNICODETEXTRENDERING


@interface CPTextLayer ()

+ (NSString*)defaultFontName;

@end


@implementation CPTextLayer

#pragma mark -
#pragma mark Initialization and teardown

+(NSString *)defaultFontName {
    return @"Helvetica";
}

-(id)initWithString:(NSString *)newText fontSize:(CGFloat)newFontSize
{
	if (self = [super init]) 
	{	
		self.needsDisplayOnBoundsChange = NO;
		fontSize = newFontSize;
        fontName = [[[self class] defaultFontName] retain];
		fontColor = [CPTextLayer blackColor];
		text = [newText copy];
		[self sizeToFit];
	}
	return self;
}

-(void)dealloc 
{
    [fontName release];
    [text release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Cached colors

+(CGColorSpaceRef)genericRGBSpace
{ 
	static CGColorSpaceRef space = NULL; 
	if(NULL == space) 
	{ 
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
		space = CGColorSpaceCreateDeviceRGB();
#else
		space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
#endif
	} 
	return space; 
} 

+(CGColorRef)blackColor
{ 
	static CGColorRef black = NULL; 
	if(black == NULL) 
	{ 
		CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
		
		CGFloat values[4] = {0.0, 0.0, 0.0, 1.0}; 
		black = CGColorCreate(rgbColorspace, values); 
		CGColorSpaceRelease(rgbColorspace);
	} 
	return black; 
} 

#pragma mark -
#pragma mark Layout

-(void)sizeToFit
{
	// TODO: Put a spacing inset around the edges of the text?
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIFont *theFont = [UIFont fontWithName:fontName size:fontSize];
	CGSize textSize = [text sizeWithFont:theFont];
#else
	NSFont *theFont = [NSFont fontWithName:fontName size:fontSize];
	CGSize textSize = NSSizeToCGSize([text sizeWithAttributes:[NSDictionary dictionaryWithObject:theFont forKey: NSFontAttributeName]]);
#endif
	CGPoint layerOrigin = self.frame.origin;
	self.frame = CGRectMake(layerOrigin.x, layerOrigin.y, textSize.width, textSize.height);
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if (fontColor == NULL)
		return;
	
#if defined(USECROSSPLATFORMUNICODETEXTRENDERING)
	// Cross-platform text drawing, with Unicode support
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPushContext(context);
#else
	NSGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
#endif
	
	CGContextSetStrokeColorWithColor(context, fontColor);	
	CGContextSetFillColorWithColor(context, fontColor);
	CGContextSetAllowsAntialiasing(context, true);
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0f, self.frame.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	UIFont *theFont = [UIFont fontWithName:@"Helvetica" size:fontSize];
	[text drawAtPoint:CGPointZero withFont:theFont];
	CGContextRestoreGState(context);
#else
	NSFont *theFont = [NSFont fontWithName:@"Helvetica" size:fontSize];
	[text drawAtPoint:NSZeroPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:theFont, NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil]];
#endif
	
	
	CGContextSetAllowsAntialiasing(context, false);
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPopContext();	
#else
	[NSGraphicsContext setCurrentContext:oldContext];
#endif
	
#else
	// Pure Quartz drawing:
	
	CGContextSetStrokeColorWithColor(context, fontColor);	
	CGContextSetFillColorWithColor(context, fontColor);

	CGContextSetAllowsAntialiasing(context, true);
	CGContextSelectFont(context, STANDARDLABELFONTNAME,(fontSize * scale), kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextSetTextPosition(context, 0.0f, round(fontSize / 4.0f));
	CGContextShowText(context, [text UTF8String], strlen([text UTF8String]));
	CGContextSetAllowsAntialiasing(context, false);

	CGContextSetShadowWithColor( context, CGSizeMake( 0.0, 0.0 ), 5.0f, fontColor );	
	
#endif
	
}

#pragma mark -
#pragma mark Accessors

@synthesize text;
@synthesize fontSize;
@synthesize fontName;

-(void)setText:(NSString *)newValue
{
	if ([text isEqualToString:newValue])
		return;
	
	[text release];
	text = [newValue copy];
	
	[self sizeToFit];
}

-(void)setFontSize:(CGFloat)newValue
{
	if (fontSize == newValue)
		return;
	
	fontSize = newValue;
	[self sizeToFit];
}


@end
