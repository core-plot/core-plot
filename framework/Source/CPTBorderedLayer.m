#import "CPTBorderedLayer.h"

#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"
#import "_CPTBorderLayer.h"
#import "_CPTMaskLayer.h"

/// @cond

@interface CPTBorderedLayer()

@property (nonatomic, readonly, retain) CPTLayer *borderLayer;

@end

/// @endcond

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
    [coder encodeBool:self.inLayout forKey:@"CPTBorderedLayer.inLayout"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        borderLineStyle = [[coder decodeObjectForKey:@"CPTBorderedLayer.borderLineStyle"] copy];
        fill            = [[coder decodeObjectForKey:@"CPTBorderedLayer.fill"] copy];
        inLayout        = [coder decodeBoolForKey:@"CPTBorderedLayer.inLayout"];
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
    [self renderBorderedLayer:self asVectorInContext:context];
}

/// @endcond

/** @brief Draws the fill and border of a CPTBorderedLayer into the given graphics context.
 *  @param layer The CPTBorderedLayer that provides the fill and border line style.
 *  @param context The graphics context to draw into.
 **/
-(void)renderBorderedLayer:(CPTBorderedLayer *)layer asVectorInContext:(CGContextRef)context
{
    CPTFill *theFill = layer.fill;

    if ( theFill ) {
        BOOL useMask = layer.masksToBounds;
        layer.masksToBounds = YES;
        CGContextBeginPath(context);
        CGContextAddPath(context, layer.maskingPath);
        [theFill fillPathInContext:context];
        layer.masksToBounds = useMask;
    }

    CPTLineStyle *theLineStyle = layer.borderLineStyle;
    if ( theLineStyle ) {
        CGFloat inset      = theLineStyle.lineWidth * (CGFloat)0.5;
        CGRect layerBounds = CGRectInset(layer.bounds, inset, inset);

        [theLineStyle setLineStyleInContext:context];

        if ( layer.cornerRadius > 0.0 ) {
            CGFloat radius = MIN(MIN(layer.cornerRadius, layerBounds.size.width * (CGFloat)0.5), layerBounds.size.height * (CGFloat)0.5);
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

    CPTLineStyle *theLineStyle = self.borderLineStyle;
    if ( theLineStyle ) {
        CGFloat inset = theLineStyle.lineWidth * CPTFloat(0.5);

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

        CGFloat lineWidth = self.borderLineStyle.lineWidth;
        CGRect selfBounds = self.bounds;

        if ( self.cornerRadius > 0.0 ) {
            CGFloat radius = MIN( MIN( self.cornerRadius + lineWidth / CPTFloat(2.0), selfBounds.size.width / CPTFloat(2.0) ), selfBounds.size.height / CPTFloat(2.0) );
            path                 = CreateRoundedRectPath(selfBounds, radius);
            self.outerBorderPath = path;
            CGPathRelease(path);
        }
        else {
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            CGPathAddRect(mutablePath, NULL, selfBounds);
            self.outerBorderPath = mutablePath;
            CGPathRelease(mutablePath);
        }

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

        if ( self.cornerRadius > 0.0 ) {
            CGFloat radius = MIN( MIN( self.cornerRadius - lineWidth / CPTFloat(2.0), selfBounds.size.width / CPTFloat(2.0) ), selfBounds.size.height / CPTFloat(2.0) );
            path                 = CreateRoundedRectPath(selfBounds, radius);
            self.innerBorderPath = path;
            CGPathRelease(path);
        }
        else {
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            CGPathAddRect(mutablePath, NULL, selfBounds);
            self.innerBorderPath = mutablePath;
            CGPathRelease(mutablePath);
        }

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
        if ( self.masksToBorder ) {
            [self.superlayer setNeedsDisplay];
        }
        else {
            [self setNeedsDisplay];
        }
    }
}

-(void)setFill:(CPTFill *)newFill
{
    if ( newFill != fill ) {
        [fill release];
        fill = [newFill copy];
        if ( self.masksToBorder ) {
            [self.superlayer setNeedsDisplay];
        }
        else {
            [self setNeedsDisplay];
        }
    }
}

-(void)setMasksToBorder:(BOOL)newMasksToBorder
{
    if ( newMasksToBorder != self.masksToBorder ) {
        [super setMasksToBorder:newMasksToBorder];

        if ( newMasksToBorder ) {
            CPTMaskLayer *maskLayer = [[CPTMaskLayer alloc] initWithFrame:self.bounds];
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
                CPTBorderLayer *newBorderLayer = [[CPTBorderLayer alloc] initWithFrame:self.frame];
                newBorderLayer.maskedLayer = self;

                [superLayer replaceSublayer:self with:newBorderLayer];
                [newBorderLayer addSublayer:self];

                newBorderLayer.transform = self.transform;

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

-(void)setTransform:(CATransform3D)newTransform
{
    if ( self.masksToBorder ) {
        [self.borderLayer setTransform:newTransform];
    }
    else {
        [super setTransform:newTransform];
    }
}

/// @endcond

@end
