
#import "CPLayer.h"
#import "CPPlatformSpecificFunctions.h"

@implementation CPLayer

@synthesize deallocating;

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super init] ) {
		self.frame = newFrame;
		self.needsDisplayOnBoundsChange = NO;
		self.opaque = NO;
		self.masksToBounds = NO;
        self.deallocating = NO;
	}
	return self;
}

- (id)init
{
	return [self initWithFrame:CGRectZero];
}

#pragma mark -
#pragma mark Drawing

-(void)setNeedsLayout 
{
    if ( self.deallocating ) return;
    [super setNeedsLayout];
}

-(void)setNeedsDisplay
{
    if ( self.deallocating ) return;
    [super setNeedsDisplay];
}

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
	// TODO: set up clipping for sublayers
	[self renderAsVectorInContext:context];
	CGContextStrokeRectWithWidth(context, self.bounds, 1.0f);
	CGContextFillEllipseInRect(context, CGRectMake(-2, -2, 4, 4));
	NSLog(@"recursivelyRenderInContext %@ in frame %@ with bounds %@", self, NSStringFromRect(NSRectFromCGRect(self.frame)), NSStringFromRect(NSRectFromCGRect(self.bounds)));
	
	for (CALayer *currentSublayer in self.sublayers) {
		CGContextSaveGState(context);
		
		// Shift origin of context to match starting coordinate of sublayer
		CGPoint currentSublayerOrigin = currentSublayer.frame.origin;
		CGContextTranslateCTM(context, currentSublayerOrigin.x, currentSublayerOrigin.y);
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

-(void)layoutSublayers
{
	// This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask
	// Subclasses should override to lay out their own sublayers
	// TODO: create a generic layout manager akin to CAConstraintLayoutManager ("struts and springs" is not flexible enough)
	// Sublayers fill the super layer's bounds by default
	CGRect selfBounds = self.bounds;
	
	for (CALayer *subLayer in self.sublayers) {
		subLayer.bounds = selfBounds;
		subLayer.anchorPoint = CGPointZero;
		subLayer.position = selfBounds.origin;
	}
}

@end
