#import "CPTPlatformSpecificCategories.h"
#import "CPTShadow.h"
#import "CPTTextLayer.h"
#import <tgmath.h>

const CGFloat kCPTTextLayerMarginWidth = 1.0;

/**	@brief A Core Animation layer that displays a single line of text drawn in a uniform style.
 **/
@implementation CPTTextLayer

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

/** @brief Initializes a newly allocated CPTTextLayer object with the provided text and style. This is the designated initializer.
 *  @param newText The text to display.
 *  @param newStyle The text style used to draw the text.
 *  @return The initialized CPTTextLayer object.
 **/
-(id)initWithText:(NSString *)newText style:(CPTTextStyle *)newStyle
{
	if ( (self = [super initWithFrame:CGRectZero]) ) {
		textStyle = [newStyle retain];
		text	  = [newText copy];

		self.needsDisplayOnBoundsChange = NO;
		[self sizeToFit];
	}

	return self;
}

/** @brief Initializes a newly allocated CPTTextLayer object with the provided text and the default text style.
 *  @param newText The text to display.
 *  @return The initialized CPTTextLayer object.
 **/
-(id)initWithText:(NSString *)newText
{
	return [self initWithText:newText style:[CPTTextStyle textStyle]];
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTTextLayer *theLayer = (CPTTextLayer *)layer;

		textStyle = [theLayer->textStyle retain];
		text	  = [theLayer->text retain];
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
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.textStyle forKey:@"CPTTextLayer.textStyle"];
	[coder encodeObject:self.text forKey:@"CPTTextLayer.text"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		textStyle = [[coder decodeObjectForKey:@"CPTTextLayer.textStyle"] retain];
		text	  = [[coder decodeObjectForKey:@"CPTTextLayer.text"] copy];
	}
	return self;
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

-(void)setTextStyle:(CPTTextStyle *)newStyle
{
	if ( textStyle != newStyle ) {
		[textStyle release];
		textStyle = [newStyle retain];
		[self sizeToFit];
	}
}

-(void)setShadow:(CPTShadow *)newShadow
{
	if ( newShadow != self.shadow ) {
		[super setShadow:newShadow];
		[self sizeToFit];
	}
}

#pragma mark -
#pragma mark Layout

/** @brief Determine the minimum size needed to fit the text
 **/
-(CGSize)sizeThatFits
{
	if ( self.text == nil ) {
		return CGSizeZero;
	}
	CGSize textSize		 = [self.text sizeWithTextStyle:self.textStyle];
	CGSize shadowOffset	 = CGSizeZero;
	CGFloat shadowRadius = 0.0;
	CPTShadow *myShadow	 = self.shadow;
	if ( myShadow ) {
		shadowOffset = myShadow.shadowOffset;
		shadowRadius = myShadow.shadowBlurRadius;
	}

	// Add small margin
	textSize.width += (ABS( shadowOffset.width ) + shadowRadius + kCPTTextLayerMarginWidth) * (CGFloat)2.0;
	textSize.width	= ceil( textSize.width );

	textSize.height += (ABS( shadowOffset.height ) + shadowRadius + kCPTTextLayerMarginWidth) * (CGFloat)2.0;
	textSize.height	 = ceil( textSize.height );

	return textSize;
}

/**	@brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
 **/
-(void)sizeToFit
{
	if ( self.text == nil ) {
		return;
	}
	CGSize sizeThatFits = [self sizeThatFits];
	CGRect newBounds	= self.bounds;
	newBounds.size = sizeThatFits;
	self.bounds	   = newBounds;
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}

	[super renderAsVectorInContext:context];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextSaveGState( context );
	CGContextTranslateCTM( context, 0.0, self.bounds.size.height );
	CGContextScaleCTM( context, 1.0, -1.0 );
#endif

	CGSize shadowOffset	 = CGSizeZero;
	CGFloat shadowRadius = 0.0;
	CPTShadow *myShadow	 = self.shadow;
	if ( myShadow ) {
		shadowOffset = myShadow.shadowOffset;
		shadowRadius = myShadow.shadowBlurRadius;
	}

	[self.text drawInRect:CGRectInset( self.bounds,
									   ABS( shadowOffset.width ) + shadowRadius + kCPTTextLayerMarginWidth,
									   ABS( shadowOffset.height ) + shadowRadius + kCPTTextLayerMarginWidth )
			withTextStyle:self.textStyle
				inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextRestoreGState( context );
#endif
}

#pragma mark -
#pragma mark Text style delegate

-(void)textStyleDidChange:(CPTTextStyle *)textStyle
{
	[self sizeToFit];
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ \"%@\">", [super description], self.text];
}

@end
