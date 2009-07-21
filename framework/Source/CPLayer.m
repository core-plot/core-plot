
#import "CPLayer.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"

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
		self.frame = newFrame;
		self.needsDisplayOnBoundsChange = NO;
		self.opaque = NO;
		self.masksToBounds = NO;
		self.zPosition = [self.class defaultZPosition];
		self.paddingLeft = 0.0f;
		self.paddingTop = 0.0f;
		self.paddingRight = 0.0f;
		self.paddingBottom = 0.0f;
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

#pragma mark -
#pragma mark Drawing

-(void)drawInContext:(CGContextRef)context
{
	[self renderAsVectorInContext:context];
}

/**	@brief Draws layer content into the provided graphics context.
 *
 *	This method replaces the drawInContext: method to ensure that layer content is always draw as vectors
 *	and objects rather than as a cached bitmapped image representation.
 *	Subclasses should do all drawing here.
 *
 *	@param context The graphics context to draw into.
 **/
-(void)renderAsVectorInContext:(CGContextRef)context;
{
	// This is where subclasses do their drawing
}

/**	@brief Draws layer content and the content of all sublayers into the provided graphics context.
 *
 *	@param context The graphics context to draw into.
 **/
-(void)recursivelyRenderInContext:(CGContextRef)context
{
	[self renderAsVectorInContext:context];

	for (CALayer *currentSublayer in self.sublayers) {
		CGContextSaveGState(context);
		
		// Shift origin of context to match starting coordinate of sublayer
		CGPoint currentSublayerFrameOrigin = currentSublayer.frame.origin;
		CGPoint currentSublayerBoundsOrigin = currentSublayer.bounds.origin;
		CGContextTranslateCTM(context, currentSublayerFrameOrigin.x - currentSublayerBoundsOrigin.x, currentSublayerFrameOrigin.y - currentSublayerBoundsOrigin.y);
		if (self.masksToBounds) {
			CGContextClipToRect(context, currentSublayer.bounds);
		}
		if ([currentSublayer isKindOfClass:[CPLayer class]]) {
			[(CPLayer *)currentSublayer recursivelyRenderInContext:context];
		} else {
			[currentSublayer drawInContext:context];
		}
		CGContextRestoreGState(context);
	}
}

/**	@brief Draws layer content and the content of all sublayers into a PDF document.
 *
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
		CGRect subLayerBounds = subLayer.bounds;
		subLayerBounds.size = subLayerSize;
		subLayer.bounds = subLayerBounds;
		subLayer.anchorPoint = CGPointZero;
		subLayer.position = CGPointMake(selfBounds.origin.x + self.paddingLeft, selfBounds.origin.y	+ self.paddingBottom);
	}
}

#pragma mark -
#pragma mark Bindings

static NSString * const BindingsNotSupportedString = @"Bindings are not supported on the iPhone in Core Plot";

+(void)exposeBinding:(NSString *)binding 
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#else
    [super exposeBinding:binding];
#endif
}

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
    [NSException raise:CPException format:BindingsNotSupportedString];
#else
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
#endif
}

-(void)unbind:(NSString *)binding
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
    [NSException raise:CPException format:BindingsNotSupportedString];
#else
    [super unbind:binding];
#endif
}

-(Class)valueClassForBinding:(NSString *)binding
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
    [NSException raise:CPException format:BindingsNotSupportedString];
    return Nil;
#else
    return [super valueClassForBinding:binding];
#endif
}

///	@}

@end
