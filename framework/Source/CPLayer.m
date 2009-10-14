#import "CPLayer.h"
#import "CPLayoutManager.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"
#import "CorePlotProbes.h"
#import <objc/runtime.h>

///	@cond
@interface CPLayer()

@property (nonatomic, readwrite, getter=isRenderingRecursively) BOOL renderingRecursively;

@end
///	@endcond

/** @brief Base class for all Core Animation layers in Core Plot.
 *
 *	Default animations for changes in position, bounds, and sublayers are turned off.
 *	The default layer is not opaque and does not mask to bounds.
 *
 *	@todo More documentation needed 
 **/

@implementation CPLayer

/// @defgroup CPLayer CPLayer
/// @{

/** @property paddingLeft
 *  @brief Amount to inset the left side of each sublayer.
 **/
@synthesize paddingLeft;

/** @property paddingTop
 *  @brief Amount to inset the top of each sublayer.
 **/
@synthesize paddingTop;

/** @property paddingRight
 *  @brief Amount to inset the right side of each sublayer.
 **/
@synthesize paddingRight;

/** @property paddingBottom
 *  @brief Amount to inset the bottom of each sublayer.
 **/
@synthesize paddingBottom;

/** @property maskingPath
 *  @brief A drawing path that encompasses the layer content including any borders. Set to NULL when no masking is desired.
 *
 *	This path defines the outline of the layer and is used to mask all drawing. Set to NULL when no masking is desired.
 *	The caller must NOT release the path returned by this property.
 **/
@dynamic maskingPath;

/** @property sublayerMaskingPath
 *  @brief A drawing path that encompasses the layer content excluding any borders. Set to NULL when no masking is desired.
 *
 *	This path defines the outline of the part of the layer where sublayers should draw and is used to mask all sublayer drawing.
 *	Set to NULL when no masking is desired.
 *	The caller must NOT release the path returned by this property.
 **/
@dynamic sublayerMaskingPath;

/** @property layoutManager
 *  @brief The layout manager for this layer.
 **/
@synthesize layoutManager;

// Private properties
@synthesize renderingRecursively;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPLayer object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties that
 *	are different than a CALayer:
 *	- needsDisplayOnBoundsChange = NO
 *	- opaque = NO
 *	- masksToBounds = NO
 *	- zPosition = defaultZPosition
 *	- padding = 0 on all four sides
 *	- Default animations for changes in position, bounds, and sublayers are turned off.
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super init] ) {
		paddingLeft = 0.0f;
		paddingTop = 0.0f;
		paddingRight = 0.0f;
		paddingBottom = 0.0f;
		layoutManager = nil;
		renderingRecursively = NO;

		self.frame = newFrame;
		self.needsDisplayOnBoundsChange = NO;
		self.opaque = NO;
		self.masksToBounds = NO;
		self.zPosition = [self.class defaultZPosition];
        NSDictionary *actionsDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", [NSNull null], @"sublayers", nil];
        self.actions = actionsDict;
        [actionsDict release];
	}
	return self;
}

-(id)init
{
	return [self initWithFrame:CGRectZero];
}

-(void)dealloc
{
	[layoutManager release];
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawInContext:(CGContextRef)context
{
	[self renderAsVectorInContext:context];
}

/**	@brief Draws layer content into the provided graphics context.
 *
 *	This method replaces the drawInContext: method to ensure that layer content is always drawn as vectors
 *	and objects rather than as a cached bitmapped image representation.
 *	Subclasses should do all drawing here and must call super to set up the clipping path.
 *
 *	@param context The graphics context to draw into.
 **/
-(void)renderAsVectorInContext:(CGContextRef)context;
{
	// This is where subclasses do their drawing
	[self applyMaskToContext:context];
}

/**	@brief Draws layer content and the content of all sublayers into the provided graphics context.
 *	@param context The graphics context to draw into.
 **/
-(void)recursivelyRenderInContext:(CGContextRef)context
{
	self.renderingRecursively = YES;
	[self renderAsVectorInContext:context];
	self.renderingRecursively = NO;

	for ( CALayer *currentSublayer in self.sublayers ) {
		CGContextSaveGState(context);
		
		// Shift origin of context to match starting coordinate of sublayer
		CGPoint currentSublayerFrameOrigin = currentSublayer.frame.origin;
		CGPoint currentSublayerBoundsOrigin = currentSublayer.bounds.origin;
		CGContextTranslateCTM(context, currentSublayerFrameOrigin.x - currentSublayerBoundsOrigin.x, currentSublayerFrameOrigin.y - currentSublayerBoundsOrigin.y);
		if ( [currentSublayer isKindOfClass:[CPLayer class]] ) {
			[(CPLayer *)currentSublayer recursivelyRenderInContext:context];
		} else {
			if ( self.masksToBounds ) {
				CGContextClipToRect(context, currentSublayer.bounds);
			}
			[currentSublayer drawInContext:context];
		}
		CGContextRestoreGState(context);
	}
}

/**	@brief Draws layer content and the content of all sublayers into a PDF document.
 *	@return PDF representation of the layer content.
 **/
-(NSData *)dataForPDFRepresentationOfLayer;
{
	NSMutableData *pdfData = [[NSMutableData alloc] init];
	CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfData);
	
	const CGRect mediaBox = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
	CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, &mediaBox, NULL);
	
	CPPushCGContext(pdfContext);
	
	CGContextBeginPage(pdfContext, &mediaBox);
	[self recursivelyRenderInContext:pdfContext];
	CGContextEndPage(pdfContext);
	CGPDFContextClose(pdfContext);
	
	CPPopCGContext();
	
	CGContextRelease(pdfContext);
	CGDataConsumerRelease(dataConsumer);
	
	return [pdfData autorelease];
}

#pragma mark -
#pragma mark User interaction

-(BOOL)containsPoint:(CGPoint)thePoint
{
	// By default, don't respond to touch or mouse events
	return NO;
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger down event.
 *	@param interactionPoint The coordinates of the event.
 **/
-(void)mouseOrFingerDownAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger up event.
 *	@param interactionPoint The coordinates of the event.
 **/
-(void)mouseOrFingerUpAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger dragged event.
 *	@param interactionPoint The coordinates of the event.
 **/
-(void)mouseOrFingerDraggedAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

/**	@brief Abstraction of Mac and iPhone event handling. Mouse or finger event cancelled.
 **/
-(void)mouseOrFingerCancelled
{
	// Subclasses should handle mouse or touch interactions here
}

#pragma mark -
#pragma mark Layout

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

/**	@brief The default z-position for the layer.
 *	@return The z-position.
 **/
+(CGFloat)defaultZPosition 
{
	return 0.0f;
}

-(void)layoutSublayers
{
	// This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask
	// Subclasses should override to lay out their own sublayers
	// TODO: create a generic layout manager akin to CAConstraintLayoutManager ("struts and springs" is not flexible enough)
	// Sublayers fill the super layer's bounds minus any padding by default
	CGRect selfBounds = self.bounds;
	CGSize subLayerSize = selfBounds.size;
	subLayerSize.width -= self.paddingLeft + self.paddingRight;
	subLayerSize.width = MAX(subLayerSize.width, 0.0f);
	subLayerSize.height -= self.paddingTop + self.paddingBottom;
	subLayerSize.height = MAX(subLayerSize.height, 0.0f);
		
	for (CALayer *subLayer in self.sublayers) {
		if ([subLayer isKindOfClass:[CPLayer class]]) {
			CGRect subLayerBounds = subLayer.bounds;
			subLayerBounds.size = subLayerSize;
			subLayer.bounds = subLayerBounds;
			subLayer.anchorPoint = CGPointZero;
			subLayer.position = CGPointMake(selfBounds.origin.x + self.paddingLeft, selfBounds.origin.y	+ self.paddingBottom);
		}
	}
}

#pragma mark -
#pragma mark Masking

-(CGPathRef)maskingPath 
{
	return NULL;
}

-(CGPathRef)sublayerMaskingPath 
{
	return NULL;
}

/**	@brief Recursively sets the clipping path of the given graphics context to the sublayer masking paths of its superlayers.
 *
 *	The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *	each super layer. The tree traversal stops when a layer is encountered that is not a CPLayer.
 *
 *	@param context The graphics context to clip.
 *	@param sublayer The sublayer that called this method.
 *	@param offset The cumulative position offset between the receiver and the first layer in the recursive calling chain.
 **/
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPLayer *)sublayer withOffset:(CGPoint)offset
{
	CGPoint sublayerFrameOrigin = sublayer.frame.origin;
	CGPoint sublayerBoundsOrigin = sublayer.bounds.origin;
	CGPoint layerOffset = offset;
	if ( !self.renderingRecursively ) {
		layerOffset.x += sublayerFrameOrigin.x - sublayerBoundsOrigin.x;
		layerOffset.y += sublayerFrameOrigin.y - sublayerBoundsOrigin.y;
	}
	
	if ( [self.superlayer isKindOfClass:[CPLayer class]] ) {
		[(CPLayer *)self.superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
	}
	
	CGPathRef maskPath = self.sublayerMaskingPath;
	if ( maskPath ) {
		CGContextTranslateCTM(context, -layerOffset.x, -layerOffset.y);

		CGContextAddPath(context, maskPath);
		CGContextClip(context);

		CGContextTranslateCTM(context, layerOffset.x, layerOffset.y);
	}
}

/**	@brief Sets the clipping path of the given graphics context to mask the content.
 *
 *	The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *	each super layer. The tree traversal stops when a layer is encountered that is not a CPLayer.
 *
 *	@param context The graphics context to clip.
 **/
-(void)applyMaskToContext:(CGContextRef)context
{
	if ( [self.superlayer isKindOfClass:[CPLayer class]] ) {
		[(CPLayer *)self.superlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointMake(0.0, 0.0)];
	}
	
	CGPathRef maskPath = self.maskingPath;
	if ( maskPath ) {
		CGContextAddPath(context, maskPath);
		CGContextClip(context);
	}
}

#pragma mark -
#pragma mark Bindings

static NSString * const BindingsNotSupportedString = @"Bindings are not supported on the iPhone in Core Plot";

+(void)exposeBinding:(NSString *)binding 
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
    [super exposeBinding:binding];
#endif
}

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [NSException raise:CPException format:BindingsNotSupportedString];
#else
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
#endif
}

-(void)unbind:(NSString *)binding
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [NSException raise:CPException format:BindingsNotSupportedString];
#else
    [super unbind:binding];
#endif
}

-(Class)valueClassForBinding:(NSString *)binding
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [NSException raise:CPException format:BindingsNotSupportedString];
    return Nil;
#else
    return [super valueClassForBinding:binding];
#endif
}

///	@}

- (void)setPosition:(CGPoint)newPosition;
{
	[super setPosition:newPosition];
	if (COREPLOT_LAYER_POSITION_CHANGE_ENABLED())
	{
		CGRect currentFrame = self.frame;
		if (!CGRectEqualToRect(currentFrame, CGRectIntegral(self.frame)))
			COREPLOT_LAYER_POSITION_CHANGE((char *)class_getName([self class]),
										   (int)ceil(currentFrame.origin.x * 1000.0), 
										   (int)ceil(currentFrame.origin.y * 1000.0),
										   (int)ceil(currentFrame.size.width * 1000.0),
										   (int)ceil(currentFrame.size.height * 1000.0));
	}
}

@end
