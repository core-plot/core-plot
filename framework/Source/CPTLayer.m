#import "CPTLayer.h"

#import "CPTAxisSet.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"
#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"
#import "CPTPlatformSpecificDefines.h"
#import "CPTPlatformSpecificFunctions.h"
#import "CPTShadow.h"
#import "CPTUtilities.h"
#import "CorePlotProbes.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"
#import <objc/runtime.h>
#import <tgmath.h>

NSString *const CPTLayerBoundsDidChangeNotification = @"CPTLayerBoundsDidChangeNotification";

/** @defgroup animation Animatable Properties
 *  @brief Custom layer properties that can be animated using Core Animation.
 *  @if MacOnly
 *  @since Custom layer property animation is supported on MacOS 10.6 and later.
 *  @endif
 **/

/** @defgroup notification Notifications
 *  @brief Notifications used by Core Plot.
 **/

/// @cond
@interface CPTLayer()

@property (nonatomic, readwrite, getter = isRenderingRecursively) BOOL renderingRecursively;
@property (nonatomic, readwrite, assign) BOOL useFastRendering;

-(void)applyTransform:(CATransform3D)transform toContext:(CGContextRef)context;
-(NSString *)subLayersAtIndex:(NSUInteger)idx;

@end

/// @endcond

#pragma mark -

/** @brief Base class for all Core Animation layers in Core Plot.
 *
 *  Unless @ref useFastRendering is @YES,
 *  all drawing is done in a way that preserves the
 *  drawing vectors. Sublayers are arranged automatically to fill the layer&rsquo;s
 *  bounds, minus any padding. Default animations for changes in position, bounds,
 *  and sublayers are turned off. The default layer is not opaque and does not mask
 *  to bounds.
 **/
@implementation CPTLayer

/** @property __cpt_weak CPTGraph *graph
 *  @brief The graph for the layer.
 **/
@synthesize graph;

/** @property CGFloat paddingLeft
 *  @brief Amount to inset the left side of each sublayer.
 **/
@synthesize paddingLeft;

/** @property CGFloat paddingTop
 *  @brief Amount to inset the top of each sublayer.
 **/
@synthesize paddingTop;

/** @property CGFloat paddingRight
 *  @brief Amount to inset the right side of each sublayer.
 **/
@synthesize paddingRight;

/** @property CGFloat paddingBottom
 *  @brief Amount to inset the bottom of each sublayer.
 **/
@synthesize paddingBottom;

/** @property BOOL masksToBorder
 *  @brief If @YES, a sublayer mask is applied to clip sublayer content to the inside of the border.
 **/
@synthesize masksToBorder;

/** @property CGFloat contentsScale
 *  @brief The scale factor applied to the layer.
 **/
@dynamic contentsScale;

/** @property CPTShadow *shadow
 *  @brief The shadow drawn under the layer content. If @nil (the default), no shadow is drawn.
 **/
@synthesize shadow;

/** @property CGPathRef outerBorderPath
 *  @brief A drawing path that encompasses the outer boundary of the layer border.
 **/
@synthesize outerBorderPath;

/** @property CGPathRef innerBorderPath
 *  @brief A drawing path that encompasses the inner boundary of the layer border.
 **/
@synthesize innerBorderPath;

/** @property CGPathRef maskingPath
 *  @brief A drawing path that encompasses the layer content including any borders. Set to @NULL when no masking is desired.
 *
 *  This path defines the outline of the layer and is used to mask all drawing. Set to @NULL when no masking is desired.
 *  The caller must @emph{not} release the path returned by this property.
 **/
@dynamic maskingPath;

/** @property CGPathRef sublayerMaskingPath
 *  @brief A drawing path that encompasses the layer content excluding any borders. Set to @NULL when no masking is desired.
 *
 *  This path defines the outline of the part of the layer where sublayers should draw and is used to mask all sublayer drawing.
 *  Set to @NULL when no masking is desired.
 *  The caller must @emph{not} release the path returned by this property.
 **/
@dynamic sublayerMaskingPath;

/** @property NSSet *sublayersExcludedFromAutomaticLayout
 *  @brief A set of sublayers that should be excluded from the automatic sublayer layout.
 **/
@dynamic sublayersExcludedFromAutomaticLayout;

/** @property BOOL useFastRendering
 *  @brief If @YES, subclasses should optimize their drawing for speed over precision.
 **/
@synthesize useFastRendering;

/** @property id<NSCopying, NSCoding, NSObject> identifier
 *  @brief An object used to identify the layer in collections.
 **/
@synthesize identifier;

// Private properties
@synthesize renderingRecursively;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTLayer object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref paddingLeft = @num{0.0}
 *  - @ref paddingTop = @num{0.0}
 *  - @ref paddingRight = @num{0.0}
 *  - @ref paddingBottom = @num{0.0}
 *  - @ref masksToBorder = @NO
 *  - @ref shadow = @nil
 *  - @ref useFastRendering = @NO
 *  - @ref graph = @nil
 *  - @ref outerBorderPath = @NULL
 *  - @ref innerBorderPath = @NULL
 *  - @ref identifier = @nil
 *  - @ref needsDisplayOnBoundsChange = @NO
 *  - @ref opaque = @NO
 *  - @ref masksToBounds = @NO
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super init]) ) {
        paddingLeft          = CPTFloat(0.0);
        paddingTop           = CPTFloat(0.0);
        paddingRight         = CPTFloat(0.0);
        paddingBottom        = CPTFloat(0.0);
        masksToBorder        = NO;
        shadow               = nil;
        renderingRecursively = NO;
        useFastRendering     = NO;
        graph                = nil;
        outerBorderPath      = NULL;
        innerBorderPath      = NULL;
        identifier           = nil;

        self.frame                      = newFrame;
        self.needsDisplayOnBoundsChange = NO;
        self.opaque                     = NO;
        self.masksToBounds              = NO;
    }
    return self;
}

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTLayer object with an empty frame rectangle.
 *  @return The initialized object.
 **/
-(id)init
{
    return [self initWithFrame:CGRectZero];
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTLayer *theLayer = (CPTLayer *)layer;

        paddingLeft          = theLayer->paddingLeft;
        paddingTop           = theLayer->paddingTop;
        paddingRight         = theLayer->paddingRight;
        paddingBottom        = theLayer->paddingBottom;
        masksToBorder        = theLayer->masksToBorder;
        shadow               = [theLayer->shadow retain];
        renderingRecursively = theLayer->renderingRecursively;
        graph                = theLayer->graph;
        outerBorderPath      = CGPathRetain(theLayer->outerBorderPath);
        innerBorderPath      = CGPathRetain(theLayer->innerBorderPath);
        identifier           = [theLayer->identifier retain];
    }
    return self;
}

-(void)dealloc
{
    graph = nil;
    [shadow release];
    [identifier release];
    CGPathRelease(outerBorderPath);
    CGPathRelease(innerBorderPath);

    [super dealloc];
}

-(void)finalize
{
    CGPathRelease(outerBorderPath);
    CGPathRelease(innerBorderPath);
    [super finalize];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeCGFloat:self.paddingLeft forKey:@"CPTLayer.paddingLeft"];
    [coder encodeCGFloat:self.paddingTop forKey:@"CPTLayer.paddingTop"];
    [coder encodeCGFloat:self.paddingRight forKey:@"CPTLayer.paddingRight"];
    [coder encodeCGFloat:self.paddingBottom forKey:@"CPTLayer.paddingBottom"];
    [coder encodeBool:self.masksToBorder forKey:@"CPTLayer.masksToBorder"];
    [coder encodeObject:self.shadow forKey:@"CPTLayer.shadow"];
    [coder encodeConditionalObject:self.graph forKey:@"CPTLayer.graph"];
    [coder encodeObject:self.identifier forKey:@"CPTLayer.identifier"];

    // No need to archive these properties:
    // renderingRecursively
    // outerBorderPath
    // innerBorderPath
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        paddingLeft   = [coder decodeCGFloatForKey:@"CPTLayer.paddingLeft"];
        paddingTop    = [coder decodeCGFloatForKey:@"CPTLayer.paddingTop"];
        paddingRight  = [coder decodeCGFloatForKey:@"CPTLayer.paddingRight"];
        paddingBottom = [coder decodeCGFloatForKey:@"CPTLayer.paddingBottom"];
        masksToBorder = [coder decodeBoolForKey:@"CPTLayer.masksToBorder"];
        shadow        = [[coder decodeObjectForKey:@"CPTLayer.shadow"] copy];
        graph         = [coder decodeObjectForKey:@"CPTLayer.graph"];
        identifier    = [[coder decodeObjectForKey:@"CPTLayer.identifier"] copy];

        renderingRecursively = NO;
        outerBorderPath      = NULL;
        innerBorderPath      = NULL;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

-(id<CAAction>)actionForKey:(NSString *)aKey
{
    return nil;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawInContext:(CGContextRef)context
{
    self.useFastRendering = YES;
    [self renderAsVectorInContext:context];
    self.useFastRendering = NO;
}

/// @endcond

/** @brief Draws layer content into the provided graphics context.
 *
 *  This method replaces the CALayer @link CALayer::drawInContext: -drawInContext: @endlink method
 *  to ensure that layer content is always drawn as vectors
 *  and objects rather than as a cached bitmapped image representation.
 *  Subclasses should do all drawing here and must call @super to set up the clipping path.
 *
 *  @param context The graphics context to draw into.
 **/
-(void)renderAsVectorInContext:(CGContextRef)context
{
    // This is where subclasses do their drawing
    if ( self.renderingRecursively ) {
        [self applyMaskToContext:context];
    }
    [self.shadow setShadowInContext:context];
}

/** @brief Draws layer content and the content of all sublayers into the provided graphics context.
 *  @param context The graphics context to draw into.
 **/
-(void)recursivelyRenderInContext:(CGContextRef)context
{
    // render self
    CGContextSaveGState(context);

    [self applyTransform:self.transform toContext:context];

    self.renderingRecursively = YES;
    if ( !self.masksToBounds ) {
        CGContextSaveGState(context);
    }
    [self renderAsVectorInContext:context];
    if ( !self.masksToBounds ) {
        CGContextRestoreGState(context);
    }
    self.renderingRecursively = NO;

    // render sublayers
    NSArray *sublayersCopy = [self.sublayers copy];
    for ( CALayer *currentSublayer in sublayersCopy ) {
        CGContextSaveGState(context);

        // Shift origin of context to match starting coordinate of sublayer
        CGPoint currentSublayerFrameOrigin = currentSublayer.frame.origin;
        CGRect currentSublayerBounds       = currentSublayer.bounds;
        CGContextTranslateCTM(context,
                              currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x,
                              currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
        [self applyTransform:self.sublayerTransform toContext:context];
        if ( [currentSublayer isKindOfClass:[CPTLayer class]] ) {
            [(CPTLayer *) currentSublayer recursivelyRenderInContext:context];
        }
        else {
            if ( self.masksToBounds ) {
                CGContextClipToRect(context, currentSublayer.bounds);
            }
            [currentSublayer drawInContext:context];
        }
        CGContextRestoreGState(context);
    }
    [sublayersCopy release];

    CGContextRestoreGState(context);
}

/// @cond

-(void)applyTransform:(CATransform3D)transform3D toContext:(CGContextRef)context
{
    if ( !CATransform3DIsIdentity(transform3D) ) {
        if ( CATransform3DIsAffine(transform3D) ) {
            CGRect selfBounds    = self.bounds;
            CGPoint anchorPoint  = self.anchorPoint;
            CGPoint anchorOffset = CPTPointMake(anchorOffset.x = selfBounds.origin.x + anchorPoint.x * selfBounds.size.width,
                                                anchorOffset.y = selfBounds.origin.y + anchorPoint.y * selfBounds.size.height);

            CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(-anchorOffset.x, -anchorOffset.y);
            affineTransform = CGAffineTransformConcat( affineTransform, CATransform3DGetAffineTransform(transform3D) );
            affineTransform = CGAffineTransformTranslate(affineTransform, anchorOffset.x, anchorOffset.y);

            CGRect transformedBounds = CGRectApplyAffineTransform(selfBounds, affineTransform);

            CGContextTranslateCTM(context, -transformedBounds.origin.x, -transformedBounds.origin.y);
            CGContextConcatCTM(context, affineTransform);
        }
    }
}

/// @endcond

/** @brief Updates the layer layout if needed and then draws layer content and the content of all sublayers into the provided graphics context.
 *  @param context The graphics context to draw into.
 */
-(void)layoutAndRenderInContext:(CGContextRef)context
{
    [self layoutIfNeeded];
    [self recursivelyRenderInContext:context];
}

/** @brief Draws layer content and the content of all sublayers into a PDF document.
 *  @return PDF representation of the layer content.
 **/
-(NSData *)dataForPDFRepresentationOfLayer
{
    NSMutableData *pdfData         = [[NSMutableData alloc] init];
    CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData( (CFMutableDataRef)pdfData );

    const CGRect mediaBox   = CPTRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, &mediaBox, NULL);

    CPTPushCGContext(pdfContext);

    CGContextBeginPage(pdfContext, &mediaBox);
    [self layoutAndRenderInContext:pdfContext];
    CGContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);

    CPTPopCGContext();

    CGContextRelease(pdfContext);
    CGDataConsumerRelease(dataConsumer);

    return [pdfData autorelease];
}

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    return NO;
}

-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    return NO;
}

-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    return NO;
}

-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    return NO;
}

/// @}

#pragma mark -
#pragma mark Layout

/**
 *  @brief Align the receiver&rsquo;s position with pixel boundaries.
 **/
-(void)pixelAlign
{
    CGFloat scale           = self.contentsScale;
    CGPoint currentPosition = self.position;

    CGPoint newPosition;

    if ( scale == 1.0 ) {
        newPosition.x = round(currentPosition.x);
        newPosition.y = round(currentPosition.y);
    }
    else {
        newPosition.x = round(currentPosition.x * scale) / scale;
        newPosition.y = round(currentPosition.y * scale) / scale;
    }

    if ( CATransform3DIsIdentity(self.transform) ) {
        CGSize currentSize = self.bounds.size;
        CGPoint anchor     = self.anchorPoint;

        newPosition.x += (currentSize.width * anchor.x) - round(currentSize.width * anchor.x);
        newPosition.y += (currentSize.height * anchor.y) - round(currentSize.height * anchor.y);
    }

    self.position = newPosition;
}

/// @cond

-(void)setPaddingLeft:(CGFloat)newPadding
{
    if ( newPadding != paddingLeft ) {
        paddingLeft = newPadding;
        [self setNeedsLayout];
    }
}

-(void)setPaddingRight:(CGFloat)newPadding
{
    if ( newPadding != paddingRight ) {
        paddingRight = newPadding;
        [self setNeedsLayout];
    }
}

-(void)setPaddingTop:(CGFloat)newPadding
{
    if ( newPadding != paddingTop ) {
        paddingTop = newPadding;
        [self setNeedsLayout];
    }
}

-(void)setPaddingBottom:(CGFloat)newPadding
{
    if ( newPadding != paddingBottom ) {
        paddingBottom = newPadding;
        [self setNeedsLayout];
    }
}

/// @endcond

/// @name Layout
/// @{

/**
 *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds minus any padding.
 *
 *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
 *  Subclasses should override this method to provide a different layout of their own sublayers.
 **/
-(void)layoutSublayers
{
    CGRect selfBounds    = self.bounds;
    NSArray *mySublayers = self.sublayers;

    if ( mySublayers.count > 0 ) {
        CGFloat leftPadding, topPadding, rightPadding, bottomPadding;

        [self sublayerMarginLeft:&leftPadding top:&topPadding right:&rightPadding bottom:&bottomPadding];

        CGSize subLayerSize = selfBounds.size;
        subLayerSize.width  -= leftPadding + rightPadding;
        subLayerSize.width   = MAX(subLayerSize.width, (CGFloat)0.0);
        subLayerSize.width   = round(subLayerSize.width);
        subLayerSize.height -= topPadding + bottomPadding;
        subLayerSize.height  = MAX(subLayerSize.height, (CGFloat)0.0);
        subLayerSize.height  = round(subLayerSize.height);

        CGRect subLayerFrame;
        subLayerFrame.origin = CGPointMake( round(leftPadding), round(bottomPadding) );
        subLayerFrame.size   = subLayerSize;

        NSSet *excludedSublayers = [self sublayersExcludedFromAutomaticLayout];
        Class layerClass         = [CPTLayer class];
        for ( CALayer *subLayer in mySublayers ) {
            if ( [subLayer isKindOfClass:layerClass] && ![excludedSublayers containsObject:subLayer] ) {
                subLayer.frame = subLayerFrame;
            }
        }
    }
}

/// @}

-(NSSet *)sublayersExcludedFromAutomaticLayout
{
    return nil;
}

/** @brief Returns the margins that should be left between the bounds of the receiver and all sublayers.
 *  @param left The left margin.
 *  @param top The top margin.
 *  @param right The right margin.
 *  @param bottom The bottom margin.
 **/
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom
{
    *left   = self.paddingLeft;
    *top    = self.paddingTop;
    *right  = self.paddingRight;
    *bottom = self.paddingBottom;
}

#pragma mark -
#pragma mark Sublayers

/// @cond

-(void)setSublayers:(NSArray *)sublayers
{
    [super setSublayers:sublayers];

    Class layerClass = [CPTLayer class];
    CGFloat scale    = self.contentsScale;
    for ( CALayer *layer in sublayers ) {
        if ( [layer isKindOfClass:layerClass] ) {
            ( (CPTLayer *)layer ).contentsScale = scale;
        }
    }
}

-(void)addSublayer:(CALayer *)layer
{
    [super addSublayer:layer];

    if ( [layer isKindOfClass:[CPTLayer class]] ) {
        ( (CPTLayer *)layer ).contentsScale = self.contentsScale;
    }
}

-(void)insertSublayer:(CALayer *)layer atIndex:(unsigned)idx
{
    [super insertSublayer:layer atIndex:idx];

    if ( [layer isKindOfClass:[CPTLayer class]] ) {
        ( (CPTLayer *)layer ).contentsScale = self.contentsScale;
    }
}

-(void)insertSublayer:(CALayer *)layer below:(CALayer *)sibling
{
    [super insertSublayer:layer below:sibling];

    if ( [layer isKindOfClass:[CPTLayer class]] ) {
        ( (CPTLayer *)layer ).contentsScale = self.contentsScale;
    }
}

-(void)insertSublayer:(CALayer *)layer above:(CALayer *)sibling
{
    [super insertSublayer:layer above:sibling];

    if ( [layer isKindOfClass:[CPTLayer class]] ) {
        ( (CPTLayer *)layer ).contentsScale = self.contentsScale;
    }
}

-(void)replaceSublayer:(CALayer *)layer with:(CALayer *)layer2
{
    [super replaceSublayer:layer with:layer2];

    if ( [layer2 isKindOfClass:[CPTLayer class]] ) {
        ( (CPTLayer *)layer2 ).contentsScale = self.contentsScale;
    }
}

/// @endcond

#pragma mark -
#pragma mark Masking

// default path is the rounded rect layer bounds
-(CGPathRef)maskingPath
{
    if ( self.masksToBounds ) {
        CGPathRef path = self.outerBorderPath;
        if ( path ) {
            return path;
        }

        CGRect selfBounds = self.bounds;

        if ( self.cornerRadius > 0.0 ) {
            CGFloat radius = MIN( MIN( self.cornerRadius, selfBounds.size.width / CPTFloat(2.0) ), selfBounds.size.height / CPTFloat(2.0) );
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
    return self.innerBorderPath;
}

/** @brief Recursively sets the clipping path of the given graphics context to the sublayer masking paths of its superlayers.
 *
 *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *  @param context The graphics context to clip.
 *  @param sublayer The sublayer that called this method.
 *  @param offset The cumulative position offset between the receiver and the first layer in the recursive calling chain.
 **/
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPTLayer *)sublayer withOffset:(CGPoint)offset
{
    CGPoint sublayerBoundsOrigin = sublayer.bounds.origin;
    CGPoint layerOffset          = offset;

    if ( !self.renderingRecursively ) {
        CGPoint convertedOffset = [self convertPoint:sublayerBoundsOrigin fromLayer:sublayer];
        layerOffset.x += convertedOffset.x;
        layerOffset.y += convertedOffset.y;
    }

    CGAffineTransform sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform);
    CGContextConcatCTM( context, CGAffineTransformInvert(sublayerTransform) );

    CALayer *superlayer = self.superlayer;
    if ( [superlayer isKindOfClass:[CPTLayer class]] ) {
        [(CPTLayer *) superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
    }

    CGPathRef maskPath = self.sublayerMaskingPath;
    if ( maskPath ) {
        CGContextTranslateCTM(context, -layerOffset.x, -layerOffset.y);
        CGContextAddPath(context, maskPath);
        CGContextClip(context);
        CGContextTranslateCTM(context, layerOffset.x, layerOffset.y);
    }

    CGContextConcatCTM(context, sublayerTransform);
}

/** @brief Sets the clipping path of the given graphics context to mask the content.
 *
 *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *  @param context The graphics context to clip.
 **/
-(void)applyMaskToContext:(CGContextRef)context
{
    CPTLayer *mySuperlayer = (CPTLayer *)self.superlayer;

    if ( [mySuperlayer isKindOfClass:[CPTLayer class]] ) {
        [mySuperlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointZero];
    }

    CGPathRef maskPath = self.maskingPath;
    if ( maskPath ) {
        CGContextAddPath(context, maskPath);
        CGContextClip(context);
    }
}

/// @cond

-(void)setNeedsLayout
{
    [super setNeedsLayout];

    CPTGraph *theGraph = self.graph;
    if ( theGraph ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                            object:theGraph];
    }
}

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];

    CPTGraph *theGraph = self.graph;
    if ( theGraph ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                            object:theGraph];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setPosition:(CGPoint)newPosition
{
    [super setPosition:newPosition];
    if ( COREPLOT_LAYER_POSITION_CHANGE_ENABLED() ) {
        CGRect currentFrame = self.frame;
        if ( !CGRectEqualToRect( currentFrame, CGRectIntegral(self.frame) ) ) {
            COREPLOT_LAYER_POSITION_CHANGE( (char *)class_getName([self class]),
                                            (int)ceil(currentFrame.origin.x * 1000.0),
                                            (int)ceil(currentFrame.origin.y * 1000.0),
                                            (int)ceil(currentFrame.size.width * 1000.0),
                                            (int)ceil(currentFrame.size.height * 1000.0) );
        }
    }
}

-(void)setHidden:(BOOL)newHidden
{
    if ( newHidden != self.hidden ) {
        [super setHidden:newHidden];
        if ( !newHidden ) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setContentsScale:(CGFloat)newContentsScale
{
    NSParameterAssert(newContentsScale > 0.0);

    if ( self.contentsScale != newContentsScale ) {
        if ( [CALayer instancesRespondToSelector:@selector(setContentsScale:)] ) {
            super.contentsScale = newContentsScale;
            [self setNeedsDisplay];

            Class layerClass = [CPTLayer class];
            for ( CALayer *subLayer in self.sublayers ) {
                if ( [subLayer isKindOfClass:layerClass] ) {
                    ( (CPTLayer *)subLayer ).contentsScale = newContentsScale;
                }
            }
        }
    }
}

-(CGFloat)contentsScale
{
    CGFloat scale = CPTFloat(1.0);

    if ( [CALayer instancesRespondToSelector:@selector(contentsScale)] ) {
        scale = super.contentsScale;
    }

    return scale;
}

-(void)setShadow:(CPTShadow *)newShadow
{
    if ( newShadow != shadow ) {
        [shadow release];
        shadow = [newShadow copy];
        [self setNeedsDisplay];
    }
}

-(void)setOuterBorderPath:(CGPathRef)newPath
{
    if ( newPath != outerBorderPath ) {
        CGPathRelease(outerBorderPath);
        outerBorderPath = CGPathRetain(newPath);
    }
}

-(void)setInnerBorderPath:(CGPathRef)newPath
{
    if ( newPath != innerBorderPath ) {
        CGPathRelease(innerBorderPath);
        innerBorderPath = CGPathRetain(newPath);
        [self.mask setNeedsDisplay];
    }
}

-(void)setBounds:(CGRect)newBounds
{
    if ( !CGRectEqualToRect(self.bounds, newBounds) ) {
        [super setBounds:newBounds];

        self.outerBorderPath = NULL;
        self.innerBorderPath = NULL;

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTLayerBoundsDidChangeNotification
                                                            object:self];
    }
}

-(void)setCornerRadius:(CGFloat)newRadius
{
    if ( newRadius != self.cornerRadius ) {
        super.cornerRadius = newRadius;

        [self setNeedsDisplay];

        self.outerBorderPath = NULL;
        self.innerBorderPath = NULL;
    }
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ bounds: %@>", [super description], CPTStringFromRect(self.bounds)];
}

/// @endcond

/**
 *  @brief Logs this layer and all of its sublayers.
 **/
-(void)logLayers
{
    NSLog(@"Layer tree:\n%@", [self subLayersAtIndex:0]);
}

/// @cond

-(NSString *)subLayersAtIndex:(NSUInteger)idx
{
    NSMutableString *result = [NSMutableString string];

    for ( NSUInteger i = 0; i < idx; i++ ) {
        [result appendString:@".   "];
    }
    [result appendString:[self description]];

    for ( CPTLayer *sublayer in self.sublayers ) {
        [result appendString:@"\n"];

        if ( [sublayer respondsToSelector:@selector(subLayersAtIndex:)] ) {
            [result appendString:[sublayer subLayersAtIndex:idx + 1]];
        }
        else {
            [result appendString:[sublayer description]];
        }
    }

    return result;
}

/// @endcond

@end
