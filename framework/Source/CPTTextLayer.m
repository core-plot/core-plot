#import "CPTTextLayer.h"

#import "CPTPlatformSpecificCategories.h"
#import "CPTShadow.h"
#import "CPTTextStylePlatformSpecific.h"
#import "CPTUtilities.h"
#import <tgmath.h>

const CGFloat kCPTTextLayerMarginWidth = CPTFloat(2.0);

/**
 *  @brief A Core Animation layer that displays text drawn in a uniform style.
 **/
@implementation CPTTextLayer

/** @property NSString *text
 *  @brief The text to display.
 *
 *  Assigning a new value to this property also sets the value of the @ref attributedText property to @nil.
 *  Insert newline characters (<code>'\\n'</code>) at the line breaks to display multi-line text.
 **/
@synthesize text;

/** @property CPTTextStyle *textStyle
 *  @brief The text style used to draw the text.
 *
 *  Assigning a new value to this property also sets the value of the @ref attributedText property to @nil.
 **/
@synthesize textStyle;

/** @property NSAttributedString *attributedText
 *  @brief The styled text to display.
 *
 *  Assigning a new value to this property also sets the value of the @ref text property to the
 *  same string, without formatting information. It also replaces the @ref textStyle with
 *  a style matching the first position (location @num{0}) of the styled text.
 *  Insert newline characters (<code>'\\n'</code>) at the line breaks to display multi-line text.
 **/
@synthesize attributedText;

/** @property CGSize maximumSize
 *  @brief The maximum size of the layer. The default is {@num{0.0}, @num{0.0}}.
 *
 *  A text layer will size itself to fit its text drawn with its text style unless it exceeds this size.
 *  If the @par{width} and/or @par{height} of this size is less than or equal to zero (@num{0.0}),
 *  no size limit will be enforced in the corresponding dimension. The maximum layer size includes
 *  any padding applied to the layer.
 **/
@synthesize maximumSize;

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
        textStyle      = [newStyle retain];
        text           = [newText copy];
        attributedText = nil;
        maximumSize    = CGSizeZero;

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

/** @brief Initializes a newly allocated CPTTextLayer object with the provided styled text.
 *  @param newText The styled text to display.
 *  @return The initialized CPTTextLayer object.
 **/
-(id)initWithAttributedText:(NSAttributedString *)newText
{
    CPTTextStyle *newStyle = [CPTTextStyle textStyleWithAttributes:[newText attributesAtIndex:0 effectiveRange:NULL]];

    if ( (self = [self initWithText:newText.string style:newStyle]) ) {
        attributedText = [newText copy];

        [self sizeToFit];
    }

    return self;
}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTTextLayer *theLayer = (CPTTextLayer *)layer;

        textStyle      = [theLayer->textStyle retain];
        text           = [theLayer->text retain];
        attributedText = [theLayer->attributedText retain];
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
 *  - @ref attributedText = @nil
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
    [attributedText release];

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
    [coder encodeObject:self.attributedText forKey:@"CPTTextLayer.attributedText"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        textStyle      = [[coder decodeObjectForKey:@"CPTTextLayer.textStyle"] retain];
        text           = [[coder decodeObjectForKey:@"CPTTextLayer.text"] copy];
        attributedText = [[coder decodeObjectForKey:@"CPTTextLayer.attributedText"] copy];
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

        [attributedText release];
        attributedText = nil;

        [self sizeToFit];
    }
}

-(void)setTextStyle:(CPTTextStyle *)newStyle
{
    if ( textStyle != newStyle ) {
        [textStyle release];
        textStyle = [newStyle retain];

        [attributedText release];
        attributedText = nil;

        [self sizeToFit];
    }
}

-(void)setAttributedText:(NSAttributedString *)newValue
{
    if ( attributedText != newValue ) {
        [attributedText release];
        attributedText = [newValue copy];

        [textStyle release];
        [text release];
        if ( attributedText.length > 0 ) {
            textStyle = [[CPTTextStyle textStyleWithAttributes:[attributedText attributesAtIndex:0
                                                                                  effectiveRange:NULL]] retain];
            text = [attributedText.string copy];
        }
        else {
            textStyle = nil;
            text      = nil;
        }

        [self sizeToFit];
    }
}

-(void)setMaximumSize:(CGSize)newSize
{
    if ( !CGSizeEqualToSize(maximumSize, newSize) ) {
        maximumSize = newSize;
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
    CGSize textSize  = CGSizeZero;
    NSString *myText = self.text;

    if ( myText.length > 0 ) {
        NSAttributedString *styledText = self.attributedText;
        if ( (styledText.length > 0) && [styledText respondsToSelector:@selector(size)] ) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            textSize = styledText.size;
#else
            textSize = NSSizeToCGSize(styledText.size);
#endif
        }
        else {
            textSize = [myText sizeWithTextStyle:self.textStyle];
        }

        // Add small margin
        textSize.width += kCPTTextLayerMarginWidth * CPTFloat(2.0);
        textSize.width  = ceil(textSize.width);

        textSize.height += kCPTTextLayerMarginWidth * CPTFloat(2.0);
        textSize.height  = ceil(textSize.height);
    }

    return textSize;
}

/**
 *  @brief Resizes the layer to fit its contents leaving a narrow margin on all four sides.
 **/
-(void)sizeToFit
{
    if ( self.text.length > 0 ) {
        CGSize sizeThatFits = [self sizeThatFits];
        CGRect newBounds    = self.bounds;
        newBounds.size         = sizeThatFits;
        newBounds.size.width  += self.paddingLeft + self.paddingRight;
        newBounds.size.height += self.paddingTop + self.paddingBottom;

        CGSize myMaxSize = self.maximumSize;
        if ( myMaxSize.width > CPTFloat(0.0) ) {
            newBounds.size.width = MIN(newBounds.size.width, myMaxSize.width);
        }
        if ( myMaxSize.height > CPTFloat(0.0) ) {
            newBounds.size.height = MIN(newBounds.size.height, myMaxSize.height);
        }

        newBounds.size.width  = ceil(newBounds.size.width);
        newBounds.size.height = ceil(newBounds.size.height);

        self.bounds = newBounds;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Drawing of text

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    NSString *myText = self.text;
    if ( myText.length > 0 ) {
        [super renderAsVectorInContext:context];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CPTFloat(0.0), self.bounds.size.height);
        CGContextScaleCTM( context, CPTFloat(1.0), CPTFloat(-1.0) );
#endif

        CGRect newBounds = CGRectInset(self.bounds, kCPTTextLayerMarginWidth, kCPTTextLayerMarginWidth);
        newBounds.origin.x += self.paddingLeft;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        newBounds.origin.y += self.paddingTop;
#else
        newBounds.origin.y += self.paddingBottom;
#endif
        newBounds.size.width  -= self.paddingLeft + self.paddingRight;
        newBounds.size.height -= self.paddingTop + self.paddingBottom;

        NSAttributedString *styledText = self.attributedText;
        if ( (styledText.length > 0) && [styledText respondsToSelector:@selector(drawInRect:)] ) {
            [styledText drawInRect:newBounds
                         inContext:context];
        }
        else {
            [myText drawInRect:newBounds
                 withTextStyle:self.textStyle
                     inContext:context];
        }

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGContextRestoreGState(context);
#endif
    }
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
