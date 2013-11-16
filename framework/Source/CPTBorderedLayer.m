#import "CPTBorderedLayer.h"

#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"
#import "_CPTBorderLayer.h"
#import "_CPTMaskLayer.h"

/// @cond

@interface CPTBorderedLayer()

@property (nonatomic, readonly, retain) CPTLayer *borderLayer;

-(void)updateOpacity;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A layer with a border line and background fill.
 *
 *  Sublayers will be positioned and masked so that the border line remains visible.
 **/
@implementation CPTBorderedLayer

/** @property CPTLineStyle *borderLineStyle
 *  @brief The line style for the layer border.
 *
 *  If @nil, the border is not drawn.
 **/
@synthesize borderLineStyle;

/** @property CPTFill *fill
 *  @brief The fill for the layer background.
 *
 *  If @nil, the layer background is not filled.
 **/
@synthesize fill;

/** @property BOOL inLayout
 *  @brief Set to @YES when changing the layout of this layer. Otherwise, if masking the border,
 *  all layout property changes will be passed to the superlayer.
 **/
@synthesize inLayout;

@dynamic borderLayer;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTBorderedLayer object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref borderLineStyle = @nil
 *  - @ref fill = @nil
 *  - @ref inLayout = @NO
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTBorderedLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        borderLineStyle = nil;
        fill            = nil;
        inLayout        = NO;

        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTBorderedLayer *theLayer = (CPTBorderedLayer *)layer;

        borderLineStyle = [theLayer->borderLineStyle retain];
        fill            = [theLayer->fill retain];
        inLayout        = theLayer->inLayout;
    }
    return self;
}

-(void)dealloc
{
    [borderLineStyle release];
    [fill release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.borderLineStyle forKey:@"CPTBorderedLayer.borderLineStyle"];
    [coder encodeObject:self.fill forKey:@"CPTBorderedLayer.fill"];

    // No need to archive these properties:
    // inLayout
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        borderLineStyle = [[coder decodeObjectForKey:@"CPTBorderedLayer.borderLineStyle"] copy];
        fill            = [[coder decodeObjectForKey:@"CPTBorderedLayer.fill"] copy];

        inLayout = NO;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden || self.masksToBorder ) {
        return;
    }

    [super renderAsVectorInContext:context];
    [self renderBorderedLayerAsVectorInContext:context];
}

/// @endcond

/** @brief Draws the fill and border of a CPTBorderedLayer into the given graphics context.
 *  @param context The graphics context to draw into.
 **/
-(void)renderBorderedLayerAsVectorInContext:(CGContextRef)context
{
    CPTFill *theFill = self.fill;

    if ( theFill ) {
        BOOL useMask = self.masksToBounds;
        self.masksToBounds = YES;
        CGContextBeginPath(context);
        CGContextAddPath(context, self.maskingPath);
        [theFill fillPathInContext:context];
        self.masksToBounds = useMask;
    }

    CPTLineStyle *theLineStyle = self.borderLineStyle;
    if ( theLineStyle ) {
        CGFloat inset      = theLineStyle.lineWidth * CPTFloat(0.5);
        CGRect layerBounds = CGRectInset(self.bounds, inset, inset);

        [theLineStyle setLineStyleInContext:context];

        CGFloat radius = self.cornerRadius;

        if ( radius > CPTFloat(0.0) ) {
            CGContextBeginPath(context);
            AddRoundedRectPath(context, layerBounds, radius);
            [theLineStyle strokePathInContext:context];
        }
        else {
            [theLineStyle strokeRect:layerBounds inContext:context];
        }
    }
}

#pragma mark -
#pragma mark Layout

/// @name Layout
/// @{

/** @brief Increases the sublayer margin on all four sides by half the width of the border line style.
 *  @param left The left margin.
 *  @param top The top margin.
 *  @param right The right margin.
 *  @param bottom The bottom margin.
 **/
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom
{
    [super sublayerMarginLeft:left top:top right:right bottom:bottom];

    CGFloat inset = self.borderLineStyle.lineWidth * CPTFloat(0.5);

    if ( inset > CPTFloat(0.0) ) {
        *left   += inset;
        *top    += inset;
        *right  += inset;
        *bottom += inset;
    }
}

/// @}

/// @cond

-(void)layoutSublayers
{
    [super layoutSublayers];

    self.mask.frame = self.bounds;
}

/// @endcond

#pragma mark -
#pragma mark Masking

/// @cond

-(CGPathRef)maskingPath
{
    if ( self.masksToBounds ) {
        CGPathRef path = self.outerBorderPath;
        if ( path ) {
            return path;
        }

        CGFloat radius = self.cornerRadius + self.borderLineStyle.lineWidth;

        path                 = CreateRoundedRectPath(self.bounds, radius);
        self.outerBorderPath = path;
        CGPathRelease(path);

        return self.outerBorderPath;
    }
    else {
        return NULL;
    }
}

-(CGPathRef)sublayerMaskingPath
{
    if ( self.masksToBorder ) {
        CGPathRef path = self.innerBorderPath;
        if ( path ) {
            return path;
        }

        CGFloat lineWidth = self.borderLineStyle.lineWidth;
        CGRect selfBounds = CGRectInset(self.bounds, lineWidth, lineWidth);

        path                 = CreateRoundedRectPath( selfBounds, self.cornerRadius - lineWidth * CPTFloat(0.5) );
        self.innerBorderPath = path;
        CGPathRelease(path);

        return self.innerBorderPath;
    }
    else {
        return NULL;
    }
}

/// @endcond

#pragma mark -
#pragma mark Layers

/// @cond

-(void)removeFromSuperlayer
{
    // remove the super layer, too, if we're masking the border
    CPTBorderLayer *superLayer = (CPTBorderLayer *)self.superlayer;

    if ( [superLayer isKindOfClass:[CPTBorderLayer class]] ) {
        if ( superLayer.maskedLayer == self ) {
            [superLayer removeFromSuperlayer];
        }
    }

    [super removeFromSuperlayer];
}

-(void)updateOpacity
{
    BOOL opaqueLayer = ( ( self.cornerRadius <= CPTFloat(0.0) ) && self.fill.opaque );

    CPTLineStyle *lineStyle = self.borderLineStyle;

    if ( lineStyle ) {
        opaqueLayer = opaqueLayer && lineStyle.opaque;
    }

    self.opaque             = NO;
    self.borderLayer.opaque = opaqueLayer;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setBorderLineStyle:(CPTLineStyle *)newLineStyle
{
    if ( newLineStyle != borderLineStyle ) {
        if ( newLineStyle.lineWidth != borderLineStyle.lineWidth ) {
            self.outerBorderPath = NULL;
            self.innerBorderPath = NULL;
            [self setNeedsLayout];
        }

        [borderLineStyle release];
        borderLineStyle = [newLineStyle copy];

        [self updateOpacity];

        [self.borderLayer setNeedsDisplay];
    }
}

-(void)setFill:(CPTFill *)newFill
{
    if ( newFill != fill ) {
        [fill release];
        fill = [newFill copy];

        [self updateOpacity];

        [self.borderLayer setNeedsDisplay];
    }
}

-(void)setCornerRadius:(CGFloat)newRadius
{
    if ( newRadius != self.cornerRadius ) {
        super.cornerRadius = newRadius;

        [self updateOpacity];
    }
}

-(void)setMasksToBorder:(BOOL)newMasksToBorder
{
    if ( newMasksToBorder != self.masksToBorder ) {
        [super setMasksToBorder:newMasksToBorder];

        if ( newMasksToBorder ) {
            CPTMaskLayer *maskLayer = [(CPTMaskLayer *)[CPTMaskLayer alloc] initWithFrame : self.bounds];
            [maskLayer setNeedsDisplay];
            self.mask = maskLayer;
            [maskLayer release];
        }
        else {
            self.mask = nil;
        }

        [self.borderLayer setNeedsDisplay];
        [self setNeedsDisplay];
    }
}

-(CPTLayer *)borderLayer
{
    CPTLayer *theBorderLayer   = nil;
    CPTBorderLayer *superLayer = (CPTBorderLayer *)self.superlayer;

    if ( self.masksToBorder ) {
        // check layer structure
        if ( superLayer ) {
            if ( ![superLayer isKindOfClass:[CPTBorderLayer class]] ) {
                CPTBorderLayer *newBorderLayer = [(CPTBorderLayer *)[CPTBorderLayer alloc] initWithFrame : self.frame];
                newBorderLayer.maskedLayer = self;

                [superLayer replaceSublayer:self with:newBorderLayer];
                [newBorderLayer addSublayer:self];

                newBorderLayer.transform = self.transform;
                newBorderLayer.shadow    = self.shadow;

                self.transform = CATransform3DIdentity;

                [superLayer setNeedsLayout];

                theBorderLayer = newBorderLayer;

                [newBorderLayer autorelease];
            }
            else {
                theBorderLayer = superLayer;
            }
        }
    }
    else {
        // remove the super layer for the border if no longer needed
        if ( [superLayer isKindOfClass:[CPTBorderLayer class]] ) {
            if ( superLayer.maskedLayer == self ) {
                self.transform = superLayer.transform;

                [superLayer.superlayer replaceSublayer:superLayer with:self];

                [self setNeedsLayout];
            }
        }

        theBorderLayer = self;
    }

    return theBorderLayer;
}

-(void)setBounds:(CGRect)newBounds
{
    if ( self.masksToBorder && !self.inLayout ) {
        [self.borderLayer setBounds:newBounds];
    }
    else {
        [super setBounds:newBounds];
    }
}

-(void)setPosition:(CGPoint)newPosition
{
    if ( self.masksToBorder && !self.inLayout ) {
        [self.borderLayer setPosition:newPosition];
    }
    else {
        [super setPosition:newPosition];
    }
}

-(void)setAnchorPoint:(CGPoint)newAnchorPoint
{
    if ( self.masksToBorder && !self.inLayout ) {
        [self.borderLayer setAnchorPoint:newAnchorPoint];
    }
    else {
        [super setAnchorPoint:newAnchorPoint];
    }
}

-(void)setHidden:(BOOL)newHidden
{
    if ( self.masksToBorder ) {
        [self.borderLayer setHidden:newHidden];
    }
    else {
        [super setHidden:newHidden];
    }
}

-(void)setTransform:(CATransform3D)newTransform
{
    if ( self.masksToBorder ) {
        [self.borderLayer setTransform:newTransform];
    }
    else {
        [super setTransform:newTransform];
    }
}

-(void)setShadow:(CPTShadow *)newShadow
{
    if ( newShadow != self.shadow ) {
        [super setShadow:newShadow];

        if ( self.masksToBorder ) {
            self.borderLayer.shadow = newShadow;
        }
    }
}

/// @endcond

@end
