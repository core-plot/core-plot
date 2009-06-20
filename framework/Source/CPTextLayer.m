
#import "CPTextLayer.h"
#import "CPTextStyle.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPColor.h"
#import "CPColorSpace.h"
#import "CPPlatformSpecificCategories.h"

CGFloat kCPTextLayerMarginWidth = 1.0f;

@implementation CPTextLayer

@synthesize text;
@synthesize textStyle;

#pragma mark -
#pragma mark Initialization and teardown

-(id)initWithText:(NSString *)newText style:(CPTextStyle *)newStyle
{
	if (self = [super initWithFrame:CGRectZero]) {	
		self.needsDisplayOnBoundsChange = NO;
		self.textStyle = newStyle;
		self.text = newText;
		[self sizeToFit];
	}
	
	return self;
}

-(id)initWithText:(NSString *)newText
{
	return [self initWithText:newText style:[CPTextStyle defaultTextStyle]];
}

-(void)dealloc 
{
	[textStyle release];
	[text release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setText:(NSString *)newValue
{
	if ( text == newValue ) return;	
	[text release];
	text = [newValue copy];
	[self sizeToFit];
}

-(void)setTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != textStyle ) {
		[textStyle release];
		textStyle = [newStyle retain];
		[self sizeToFit];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Layout

-(void)sizeToFit
{	
	if ( self.text == nil ) return;
	CGSize textSize = [self.text sizeWithStyle:textStyle];

	// Add small margin
	textSize.width += 2 * kCPTextLayerMarginWidth;
	textSize.height += 2 * kCPTextLayerMarginWidth;
	
	CGRect newBounds = self.bounds;
	newBounds.size = textSize;
	self.bounds = newBounds;
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

-(void)renderAsVectorInContext:(CGContextRef)context
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
#endif
	[self.text drawAtPoint:CGPointMake(kCPTextLayerMarginWidth, kCPTextLayerMarginWidth) withStyle:self.textStyle inContext:context];
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	CGContextRestoreGState(context);
#endif
}

@end
