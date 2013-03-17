#import "_CPTBorderLayer.h"

#import "CPTBorderedLayer.h"

/**
 *  @brief A utility layer used to draw the fill and border of a CPTBorderedLayer.
 *
 *  This layer is always the superlayer of a single CPTBorderedLayer. It draws the fill and
 *  border so that they are not clipped by the mask applied to the sublayer.
 **/
@implementation CPTBorderLayer

/** @property CPTBorderedLayer *maskedLayer
 *  @brief The CPTBorderedLayer masked being masked.
 *  Its fill and border are drawn into this layer so that they are outside the mask applied to the @par{maskedLayer}.
 **/
@synthesize maskedLayer;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTBorderLayer object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref maskedLayer = @nil
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTBorderLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        maskedLayer = nil;

        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTBorderLayer *theLayer = (CPTBorderLayer *)layer;

        maskedLayer = [theLayer->maskedLayer retain];
    }
    return self;
}

-(void)dealloc
{
    [maskedLayer release];

    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.maskedLayer forKey:@"CPTBorderLayer.maskedLayer"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        maskedLayer = [[coder decodeObjectForKey:@"CPTBorderLayer.maskedLayer"] retain];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTBorderedLayer *theMaskedLayer = self.maskedLayer;

    if ( theMaskedLayer ) {
        [super renderAsVectorInContext:context];
        [theMaskedLayer renderBorderedLayerAsVectorInContext:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark Layout

/// @cond

-(void)layoutSublayers
{
    [super layoutSublayers];

    CPTBorderedLayer *theMaskedLayer = self.maskedLayer;

    if ( theMaskedLayer ) {
        CGRect newBounds = self.bounds;

        // undo the shadow margin so the masked layer is always the same size
        if ( self.shadow ) {
            CGSize sizeOffset = self.shadowMargin;

            newBounds.origin.x    -= sizeOffset.width;
            newBounds.origin.y    -= sizeOffset.height;
            newBounds.size.width  += sizeOffset.width * CPTFloat(2.0);
            newBounds.size.height += sizeOffset.height * CPTFloat(2.0);
        }

        theMaskedLayer.inLayout = YES;
        theMaskedLayer.frame    = newBounds;
        theMaskedLayer.inLayout = NO;
    }
}

-(NSSet *)sublayersExcludedFromAutomaticLayout
{
    CPTBorderedLayer *excludedLayer = self.maskedLayer;

    if ( excludedLayer ) {
        NSMutableSet *excludedSublayers = [[[super sublayersExcludedFromAutomaticLayout] mutableCopy] autorelease];
        if ( !excludedSublayers ) {
            excludedSublayers = [NSMutableSet set];
        }
        [excludedSublayers addObject:excludedLayer];
        return excludedSublayers;
    }
    else {
        return [super sublayersExcludedFromAutomaticLayout];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setMaskedLayer:(CPTBorderedLayer *)newLayer
{
    if ( newLayer != maskedLayer ) {
        [maskedLayer release];
        maskedLayer = [newLayer retain];
        [self setNeedsDisplay];
    }
}

-(void)setBounds:(CGRect)newBounds
{
    if ( !CGRectEqualToRect(newBounds, self.bounds) ) {
        [super setBounds:newBounds];
        [self setNeedsLayout];
    }
}

/// @endcond

@end
