#import "CPTextLayer.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPColor.h"
#import "CPColorSpace.h"
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"

const CGFloat kCPTextLayerMarginWidth = 1.0;

/**	@brief A Core Animation layer that displays a single line of text drawn in a uniform style.
 **/
@implementation CPTextLayer

/**	@property text
 *	@brief The text to display.
 **/
@synthesize text;

/**	@property textStyle
 *	@brief The text style used to draw the text.
 **/
@synthesize textStyle;

#pragma mark -
#pragma mark Initialization and teardown

/** @brief Initializes a newly allocated CPTextLayer object with the provided text and style. This is the designated initializer.
 *  @param newText The text to display.
 *  @param newStyle The text style used to draw the text.
 *  @return The initialized CPTextLayer object.
 **/
-(id)initWithText:(NSString *)newText style:(CPTextStyle *)newStyle
{
	if (self = [super initWithFrame:CGRectZero]) {	
		textStyle = [newStyle retain];
		text = [newText copy];

		self.needsDisplayOnBoundsChange = NO;
		[self sizeToFit];
	}
	
	return self;
}

/** @brief Initializes a newly allocated CPTextLayer object with the provided text and the default text style.
 *  @param newText The text to display.
 *  @return The initialized CPTextLayer object.
 **/
-(id)initWithText:(NSString *)newText
{
	return [self initWithText:newText style:[CPTextStyle textStyle]];
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPTextLayer *theLayer = (CPTextLayer *)layer;
		
		textStyle = [theLayer->textStyle retain];
		text = [theLayer->text retain];
	}
	return self;
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
	if ( text != newValue ) {
		[text release];
		text = [newValue copy];
		[self sizeToFit];
	}
}

-(void)setTextStyle:(CPTextStyle *)newStyle 
{
	if ( textStyle != newStyle ) {
		textStyle.delegate = nil;
		[textStyle release];
		textStyle = [newStyle retain];
		textStyle.delegate = self;
		[self sizeToFit];
	}
}

#pragma mark -
#pragma mark Layout

/**	@brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
 **/
-(void)sizeToFit
{	
	if ( self.text == nil ) return;
	CGSize textSize = [self.text sizeWithTextStyle:textStyle];

	// Add small margin
	textSize.width += 2 * kCPTextLayerMarginWidth;
	textSize.height += 2 * kCPTextLayerMarginWidth;
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);

	CGRect newBounds = self.bounds;
	newBounds.size = textSize;
	self.bounds = newBounds;
    [self pixelAlign];
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

-(void)renderAsVectorInContext:(CGContextRef)context
{
	[super renderAsVectorInContext:context];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
#endif
	[self.text drawAtPoint:CPAlignPointToUserSpace(context, CGPointMake(kCPTextLayerMarginWidth, kCPTextLayerMarginWidth)) withTextStyle:self.textStyle inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextRestoreGState(context);
#endif
}

#pragma mark -
#pragma mark Text style delegate

-(void)textStyleDidChange:(CPTextStyle *)textStyle
{
	[self sizeToFit];
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ \"%@\">", [super description], self.text];
};

@end
