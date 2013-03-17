#import "CPTTextLayer.h"

#import "CPTShadow.h"
#import <tgmath.h>

const CGFloat kCPTTextLayerMarginWidth = CPTFloat(1.0);

/**
 *  @brief A Core Animation layer that displays text drawn in a uniform style.
 **/
@implementation CPTTextLayer

/** @property NSString *text
 *  @brief The text to display.
 *  Insert newline characters (<code>'\\n'</code>) at the line breaks to display multi-line text.
 **/
@synthesize text;

/** @property CPTTextStyle *textStyle
 *  @brief The text style used to draw the text.
 **/
@synthesize textStyle;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTTextLayer object with the provided text and style. This is the designated initializer.
 *  @param newText The text to display.
 *  @param newStyle The text style used to draw the text.
 *  @return The initialized CPTTextLayer object.
 **/
-(id)initWithText:(NSString *)newText style:(CPTTextStyle *)newStyle
{
    if ( (self = [super initWithFrame:CGRectZero]) ) {
        textStyle = [newStyle retain];
        text      = [newText copy];

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

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTTextLayer *theLayer = (CPTTextLayer *)layer;

        textStyle = [theLayer->textStyle retain];
        text      = [theLayer->text retain];
    }
    return self;
}

/// @endcond

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTTextLayer object with the provided frame rectangle.
 *
 *  The initialized layer will have the following properties:
 *  - @ref text = @nil
 *  - @ref textStyle = @nil
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTTextLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    return [self initWithText:nil style:nil];
}

/// @}

/// @cond

-(void)dealloc
{
    [textStyle release];
    [text release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

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
        text      = [[coder decodeObjectForKey:@"CPTTextLayer.text"] copy];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

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

-(void)setPaddingLeft:(CGFloat)newPadding
{
    if ( newPadding != self.paddingLeft ) {
        [super setPaddingLeft:newPadding];
        [self sizeToFit];
    }
}

-(void)setPaddingRight:(CGFloat)newPadding
{
    if ( newPadding != self.paddingRight ) {
        [super setPaddingRight:newPadding];
        [self sizeToFit];
    }
}

-(void)setPaddingTop:(CGFloat)newPadding
{
    if ( newPadding != self.paddingTop ) {
        [super setPaddingTop:newPadding];
        [self sizeToFit];
    }
}

-(void)setPaddingBottom:(CGFloat)newPadding
{
    if ( newPadding != self.paddingBottom ) {
        [super setPaddingBottom:newPadding];
        [self sizeToFit];
    }
}

/// @endcond

#pragma mark -
#pragma mark Layout

/**
 *  @brief Determine the minimum size needed to fit the text
 **/
-(CGSize)sizeThatFits
{
    if ( self.text == nil ) {
        return CGSizeZero;
    }
    CGSize textSize = [self.text sizeWithTextStyle:self.textStyle];

    // Add small margin
    textSize.width += kCPTTextLayerMarginWidth * CPTFloat(2.0);
    textSize.width  = ceil(textSize.width);

    textSize.height += kCPTTextLayerMarginWidth * CPTFloat(2.0);
    textSize.height  = ceil(textSize.height);

    return textSize;
}

/**
 *  @brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
 **/
-(void)sizeToFit
{
    if ( self.text == nil ) {
        return;
    }
    CGSize sizeThatFits = [self sizeThatFits];
    CGRect newBounds    = self.bounds;
    newBounds.size         = sizeThatFits;
    newBounds.size.width  += self.paddingLeft + self.paddingRight;
    newBounds.size.height += self.paddingTop + self.paddingBottom;

    self.bounds = newBounds;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing of text

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    [super renderAsVectorInContext:context];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CPTFloat(0.0), self.bounds.size.height);
    CGContextScaleCTM( context, CPTFloat(1.0), CPTFloat(-1.0) );
#endif

    CGRect newBounds = CGRectInset(self.bounds, kCPTTextLayerMarginWidth, kCPTTextLayerMarginWidth);
    newBounds.origin.x    += self.paddingLeft;
    newBounds.origin.y    += self.paddingBottom;
    newBounds.size.width  -= self.paddingLeft + self.paddingRight;
    newBounds.size.height -= self.paddingTop + self.paddingBottom;

    [self.text drawInRect:newBounds
            withTextStyle:self.textStyle
                inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGContextRestoreGState(context);
#endif
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ \"%@\">", [super description], self.text];
}

/// @endcond

@end
