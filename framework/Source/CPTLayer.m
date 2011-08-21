#import "CPTAxisSet.h"
#import "CPTGraph.h"
#import "CPTLayer.h"
#import "CPTPathExtensions.h"
#import "CPTPlatformSpecificDefines.h"
#import "CPTPlatformSpecificFunctions.h"
#import "CPTExceptions.h"
#import "CPTLineStyle.h"
#import "CPTShadow.h"
#import "CPTUtilities.h"
#import "CorePlotProbes.h"
#import <objc/runtime.h>
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"
#import <tgmath.h>

/**	@defgroup animation Animatable Properties
 *	@brief Custom layer properties that can be animated using Core Animation.
 *	@if MacOnly
 *	@since Custom layer property animation is supported on MacOS 10.6 and later.
 *	@endif
 **/

/**	@defgroup notification Notifications
 *	@brief Notifications used by Core Plot.
 **/

/**	@cond */
@interface CPTLayer()

@property (nonatomic, readwrite, getter=isRenderingRecursively) BOOL renderingRecursively;
@property (nonatomic, readwrite, assign) BOOL useFastRendering;

-(void)applyTransform:(CATransform3D)transform toContext:(CGContextRef)context;

@end
/**	@endcond */

#pragma mark -

/** @brief Base class for all Core Animation layers in Core Plot.
 *
 *	Default animations for changes in position, bounds, and sublayers are turned off.
 *	The default layer is not opaque and does not mask to bounds.
 *
 *	@todo More documentation needed 
 **/
@implementation CPTLayer

/**	@property graph
 *	@brief The graph for the layer.
 **/
@synthesize graph;

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

/** @property masksToBorder 
 *  @brief If YES, a sublayer mask is applied to clip sublayer content to the inside of the border.
 **/
@synthesize masksToBorder;

/** @property contentsScale 
 *  @brief The scale factor applied to the layer.
 **/
@dynamic contentsScale;

/** @property shadow 
 *  @brief The shadow drawn under the layer content. If nil (the default), no shadow is drawn.
 **/
@synthesize shadow;

/** @property outerBorderPath
 *  @brief A drawing path that encompasses the outer boundary of the layer border.
 **/
@synthesize outerBorderPath;

/** @property innerBorderPath
 *  @brief A drawing path that encompasses the inner boundary of the layer border.
 **/
@synthesize innerBorderPath;

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

/** @property sublayersExcludedFromAutomaticLayout
 *  @brief A set of sublayers that should be excluded from the automatic sublayer layout.
 **/
@dynamic sublayersExcludedFromAutomaticLayout;

/** @property useFastRendering 
 *  @brief If YES, subclasses should optimize their drawing for speed over precision.
 **/
@synthesize useFastRendering;

// Private properties
@synthesize renderingRecursively;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTLayer object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties that
 *	are different than a CALayer:
 *	- needsDisplayOnBoundsChange = NO
 *	- opaque = NO
 *	- masksToBounds = NO
 *	- padding = 0 on all four sides
 *	- Default animations for changes in position, bounds, and sublayers are turned off.
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super init]) ) {
		paddingLeft = 0.0;
		paddingTop = 0.0;
		paddingRight = 0.0;
		paddingBottom = 0.0;
		masksToBorder = NO;
		shadow = nil;
		renderingRecursively = NO;
		useFastRendering = NO;
		graph = nil;
		outerBorderPath = NULL;
		innerBorderPath = NULL;

		self.frame = newFrame;
		self.needsDisplayOnBoundsChange = NO;
		self.opaque = NO;
		self.masksToBounds = NO;
	}
	return self;
}

-(id)init
{
	return [self initWithFrame:CGRectZero];
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTLayer *theLayer = (CPTLayer *)layer;
		
		paddingLeft = theLayer->paddingLeft;
		paddingTop = theLayer->paddingTop;
		paddingRight = theLayer->paddingRight;
		paddingBottom = theLayer->paddingBottom;
		masksToBorder = theLayer->masksToBorder;
		shadow = [theLayer->shadow retain];
		renderingRecursively = theLayer->renderingRecursively;
		graph = theLayer->graph;
		outerBorderPath = CGPathRetain(theLayer->outerBorderPath);
		innerBorderPath = CGPathRetain(theLayer->innerBorderPath);
	}
	return self;
}

-(void)dealloc
{
	graph = nil;
	[shadow release];
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

#pragma mark -
#pragma mark NSCoding methods

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

	// No need to archive these properties:
	// renderingRecursively
	// outerBorderPath
	// innerBorderPath
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
		paddingLeft = [coder decodeCGFloatForKey:@"CPTLayer.paddingLeft"];
		paddingTop = [coder decodeCGFloatForKey:@"CPTLayer.paddingTop"];
		paddingRight = [coder decodeCGFloatForKey:@"CPTLayer.paddingRight"];
		paddingBottom = [coder decodeCGFloatForKey:@"CPTLayer.paddingBottom"];
		masksToBorder = [coder decodeBoolForKey:@"CPTLayer.masksToBorder"];
		shadow = [[coder decodeObjectForKey:@"CPTLayer.shadow"] copy];
		graph = [coder decodeObjectForKey:@"CPTLayer.graph"];
		
		renderingRecursively = NO;
		outerBorderPath = NULL;
		innerBorderPath = NULL;
	}
    return self;
}

#pragma mark -
#pragma mark Animation

-(id <CAAction>)actionForKey:(NSString *)aKey
{
    return nil;
}

#pragma mark -
#pragma mark Drawing

-(void)drawInContext:(CGContextRef)context
{
	self.useFastRendering = YES;
	[self renderAsVectorInContext:context];
	self.useFastRendering = NO;
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
	[self.shadow setShadowInContext:context];
}

/**	@brief Draws layer content and the content of all sublayers into the provided graphics context.
 *	@param context The graphics context to draw into.
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
		CGRect currentSublayerBounds = currentSublayer.bounds;
		CGContextTranslateCTM(context,
							  currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x, 
							  currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
		[self applyTransform:self.sublayerTransform toContext:context];
		if ( [currentSublayer isKindOfClass:[CPTLayer class]] ) {
			[(CPTLayer *)currentSublayer recursivelyRenderInContext:context];
		} else {
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

-(void)applyTransform:(CATransform3D)transform3D toContext:(CGContextRef)context
{
	if ( !CATransform3DIsIdentity(transform3D) ) {
		if ( CATransform3DIsAffine(transform3D) ) {
			CGRect selfBounds = self.bounds;
			CGPoint anchorPoint = self.anchorPoint;
			CGPoint anchorOffset = CGPointMake(anchorOffset.x = selfBounds.origin.x + anchorPoint.x * selfBounds.size.width,
											   anchorOffset.y = selfBounds.origin.y + anchorPoint.y * selfBounds.size.height);
			
			CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(-anchorOffset.x, -anchorOffset.y);
			affineTransform = CGAffineTransformConcat(affineTransform, CATransform3DGetAffineTransform(transform3D));
			affineTransform = CGAffineTransformTranslate(affineTransform, anchorOffset.x, anchorOffset.y);
			
			CGRect transformedBounds = CGRectApplyAffineTransform(selfBounds, affineTransform);
			
			CGContextTranslateCTM(context, -transformedBounds.origin.x, -transformedBounds.origin.y);
			CGContextConcatCTM(context, affineTransform);
		}
	}
}

/**	@brief Updates the layer layout if needed and then draws layer content and the content of all sublayers into the provided graphics context.
 *	@param context The graphics context to draw into.
 */
-(void)layoutAndRenderInContext:(CGContextRef)context
{
	CPTGraph *theGraph = nil;
	if ( [self isKindOfClass:[CPTGraph class]] ) {
		theGraph = (CPTGraph *)self;
	}
	else {
		theGraph = self.graph;
	}
	if ( theGraph ) {
		[theGraph reloadDataIfNeeded];
		[theGraph.axisSet.axes makeObjectsPerformSelector:@selector(relabel)];
	}
	[self layoutIfNeeded];
	[self recursivelyRenderInContext:context];
}

/**	@brief Draws layer content and the content of all sublayers into a PDF document.
 *	@return PDF representation of the layer content.
 **/
-(NSData *)dataForPDFRepresentationOfLayer
{
	NSMutableData *pdfData = [[NSMutableData alloc] init];
	CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfData);
	
	const CGRect mediaBox = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
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

/** @brief Informs the receiver that a pinch gesture occurred
 *  @param pinchGestureRecognizer The pinch gesture itself.
 *  @param interactionPoint The coordinates of the gesture's centroid.
 *  @param interactionScale The scale of the pinching gesture.
 *  @return                 YES should be returned if the gesture was handled (exclusively) by the receiver, NO otherwise.
 **/
-(BOOL) recognizer:(id)pinchGestureRecognizer atPoint:(CGPoint)interactionPoint withScale:(CGFloat)interactionScale
{
  return NO;
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger down event.
 *  @param event Native event object of device.
 *	@param interactionPoint The coordinates of the event in the host view.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	return NO;
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger up event.
 *  @param event Native event object of device.
 *	@param interactionPoint The coordinates of the event in the host view.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	return NO;
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger dragged event.
 *  @param event Native event object of device.
 *	@param interactionPoint The coordinates of the event in the host view.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	return NO;
}

/**	@brief Abstraction of Mac and iPhone event handling. Mouse or finger event cancelled.
 *  @param event Native event object of device.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceCancelledEvent:(id)event
{
	return NO;
}

#pragma mark -
#pragma mark Layout

/**	@brief Align the receiver's position with pixel boundaries.
 **/
-(void)pixelAlign
{
    CGSize currentSize = self.bounds.size;
    CGPoint currentPosition = self.position;
	CGPoint anchor = self.anchorPoint;  
    CGPoint newPosition = self.position;  
    newPosition.x = round(currentPosition.x) - round(currentSize.width * anchor.x) + (currentSize.width * anchor.x);
    newPosition.y = round(currentPosition.y) - round(currentSize.height * anchor.y) + (currentSize.height * anchor.y);
    self.position = newPosition;
}

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

-(void)layoutSublayers
{
	// This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask
	// Subclasses should override to lay out their own sublayers
	// Sublayers fill the super layer's bounds minus any padding by default
	CGFloat leftPadding, topPadding, rightPadding, bottomPadding;
	[self sublayerMarginLeft:&leftPadding top:&topPadding right:&rightPadding bottom:&bottomPadding];
	
	CGRect selfBounds = self.bounds;
	CGSize subLayerSize = selfBounds.size;
	subLayerSize.width -= leftPadding + rightPadding;
	subLayerSize.width = MAX(subLayerSize.width, 0.0);
	subLayerSize.height -= topPadding + bottomPadding;
	subLayerSize.height = MAX(subLayerSize.height, 0.0);
		
    NSSet *excludedSublayers = [self sublayersExcludedFromAutomaticLayout];
	for (CALayer *subLayer in self.sublayers) {
		if (![excludedSublayers containsObject:subLayer] && [subLayer isKindOfClass:[CPTLayer class]]) {
            subLayer.frame = CGRectMake(leftPadding, bottomPadding, subLayerSize.width, subLayerSize.height);
			[subLayer setNeedsLayout];
			[subLayer setNeedsDisplay];
		}
	}
}

-(NSSet *)sublayersExcludedFromAutomaticLayout 
{
    return [NSSet set];
}

/**	@brief Returns the margins that should be left between the bounds of the receiver and all sublayers.
 *	@param left The left margin.
 *	@param top The top margin.
 *	@param right The right margin.
 *	@param bottom The bottom margin.
 **/
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom
{
	*left = self.paddingLeft;
	*top = self.paddingTop;
	*right = self.paddingRight;
	*bottom = self.paddingBottom;
}

#pragma mark -
#pragma mark Sublayers

-(void)setSublayers:(NSArray *)sublayers
{
	[super setSublayers:sublayers];
	
	Class layerClass = [CPTLayer class];
	CGFloat scale = self.contentsScale;
	for ( CALayer *layer in sublayers ) {
		if ( [layer isKindOfClass:layerClass] ) {
			((CPTLayer *)layer).contentsScale = scale;
		}
	}
}

-(void)addSublayer:(CALayer *)layer
{
	[super addSublayer:layer];
	
	if ( [layer isKindOfClass:[CPTLayer class]] ) {
		((CPTLayer *)layer).contentsScale = self.contentsScale;
	}
}

-(void)insertSublayer:(CALayer *)layer atIndex:(unsigned)idx
{
	[super insertSublayer:layer atIndex:idx];
	
	if ( [layer isKindOfClass:[CPTLayer class]] ) {
		((CPTLayer *)layer).contentsScale = self.contentsScale;
	}
}

-(void)insertSublayer:(CALayer *)layer below:(CALayer *)sibling
{
	[super insertSublayer:layer below:sibling];
	
	if ( [layer isKindOfClass:[CPTLayer class]] ) {
		((CPTLayer *)layer).contentsScale = self.contentsScale;
	}
}

-(void)insertSublayer:(CALayer *)layer above:(CALayer *)sibling
{
	[super insertSublayer:layer above:sibling];
	
	if ( [layer isKindOfClass:[CPTLayer class]] ) {
		((CPTLayer *)layer).contentsScale = self.contentsScale;
	}
}

-(void)replaceSublayer:(CALayer *)layer with:(CALayer *)layer2
{
	[super replaceSublayer:layer with:layer2];
	
	if ( [layer2 isKindOfClass:[CPTLayer class]] ) {
		((CPTLayer *)layer2).contentsScale = self.contentsScale;
	}
}

#pragma mark -
#pragma mark Masking

// default path is the rounded rect layer bounds
-(CGPathRef)maskingPath 
{
	if ( self.masksToBounds ) {
		CGPathRef path = self.outerBorderPath;
		if ( path ) return path;
		
		CGRect selfBounds = self.bounds;
		
		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / 2.0), selfBounds.size.height / 2.0);
			path = CreateRoundedRectPath(selfBounds, radius);
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

/**	@brief Recursively sets the clipping path of the given graphics context to the sublayer masking paths of its superlayers.
 *
 *	The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *	each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *	@param context The graphics context to clip.
 *	@param sublayer The sublayer that called this method.
 *	@param offset The cumulative position offset between the receiver and the first layer in the recursive calling chain.
 **/
-(void)applySublayerMaskToContext:(CGContextRef)context forSublayer:(CPTLayer *)sublayer withOffset:(CGPoint)offset
{
	CGPoint sublayerBoundsOrigin = sublayer.bounds.origin;
	CGPoint layerOffset = offset;
	if ( !self.renderingRecursively ) {
		CGPoint convertedOffset = [self convertPoint:sublayerBoundsOrigin fromLayer:sublayer];
		layerOffset.x += convertedOffset.x;
		layerOffset.y += convertedOffset.y;
	}
	
	CGAffineTransform sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform);
	CGContextConcatCTM(context, CGAffineTransformInvert(sublayerTransform));
	
	CALayer *superlayer = self.superlayer;
	if ( [superlayer isKindOfClass:[CPTLayer class]] ) {
		[(CPTLayer *)superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
	}
	
	CGPathRef maskPath = self.sublayerMaskingPath;
	if ( maskPath ) {
		//		CGAffineTransform transform = CATransform3DGetAffineTransform(self.transform);
		//		CGAffineTransform sublayerTransform = CATransform3DGetAffineTransform(self.sublayerTransform);
		
		CGContextTranslateCTM(context, -layerOffset.x, -layerOffset.y);
		//		CGContextConcatCTM(context, CGAffineTransformInvert(transform));
		//		CGContextConcatCTM(context, CGAffineTransformInvert(sublayerTransform));
		
		CGContextAddPath(context, maskPath);
		CGContextClip(context);

		//		CGContextConcatCTM(context, sublayerTransform);
		//		CGContextConcatCTM(context, transform);
		CGContextTranslateCTM(context, layerOffset.x, layerOffset.y);
	}
	
	CGContextConcatCTM(context, sublayerTransform);
}

/**	@brief Sets the clipping path of the given graphics context to mask the content.
 *
 *	The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *	each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *	@param context The graphics context to clip.
 **/
-(void)applyMaskToContext:(CGContextRef)context
{
	if ( [self.superlayer isKindOfClass:[CPTLayer class]] ) {
		[(CPTLayer *)self.superlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointZero];
	}
	
	CGPathRef maskPath = self.maskingPath;
	if ( maskPath ) {
		CGContextAddPath(context, maskPath);
		CGContextClip(context);
	}
}

-(void)setNeedsLayout
{
    [super setNeedsLayout];
    if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
}

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];
    if ( self.graph ) [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification object:self.graph];
}

#pragma mark -
#pragma mark Line style delegate

-(void)lineStyleDidChange:(CPTLineStyle *)lineStyle
{
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Accessors

- (void)setPosition:(CGPoint)newPosition;
{
	[super setPosition:newPosition];
	if ( COREPLOT_LAYER_POSITION_CHANGE_ENABLED() ) {
		CGRect currentFrame = self.frame;
		if (!CGRectEqualToRect(currentFrame, CGRectIntegral(self.frame)))
			COREPLOT_LAYER_POSITION_CHANGE((char *)class_getName([self class]),
										   (int)ceil(currentFrame.origin.x * 1000.0), 
										   (int)ceil(currentFrame.origin.y * 1000.0),
										   (int)ceil(currentFrame.size.width * 1000.0),
										   (int)ceil(currentFrame.size.height * 1000.0));
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
		if ( [super respondsToSelector:@selector(setContentsScale:)] ) {
			super.contentsScale = newContentsScale;
			[self setNeedsDisplay];
			
			Class layerClass = [CPTLayer class];
			for ( CALayer *subLayer in self.sublayers ) {
				if ( [subLayer isKindOfClass:layerClass] ) {
					((CPTLayer *)subLayer).contentsScale = newContentsScale;
				}
			}
		}
	}
}

-(CGFloat)contentsScale
{
	CGFloat scale = 1.0;
	
	if ( [super respondsToSelector:@selector(contentsScale)] ) {
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
	}
}

-(void)setBounds:(CGRect)newBounds
{
	[super setBounds:newBounds];
	self.outerBorderPath = NULL;
	self.innerBorderPath = NULL;
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

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ bounds: %@>", [super description], CPTStringFromRect(self.bounds)];
};

@end
