
#import "CPLayer.h"
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"

@implementation CPLayer

@synthesize paddingLeft;
@synthesize paddingTop;
@synthesize paddingRight;
@synthesize paddingBottom;

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

-(void)renderAsVectorInContext:(CGContextRef)context;
{
	// This is where subclasses do their drawing
}

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

-(void)mouseOrFingerDownAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

-(void)mouseOrFingerUpAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

-(void)mouseOrFingerDraggedAtPoint:(CGPoint)interactionPoint
{
	// Subclasses should handle mouse or touch interactions here
}

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
	
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
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

@end
