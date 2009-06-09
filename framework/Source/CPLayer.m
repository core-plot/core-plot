
#import "CPLayer.h"
#import "CPPlatformSpecificFunctions.h"

@interface CPLayer()

@property (nonatomic, readwrite) CGRect previousBounds;

@end

@implementation CPLayer

@synthesize layerAutoresizingMask;
@synthesize previousBounds;
@synthesize deallocating;

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super init] ) {
		self.frame = newFrame;
		self.previousBounds = self.bounds;
		self.needsDisplayOnBoundsChange = NO;
		self.opaque = NO;
		self.layerAutoresizingMask = kCPLayerNotSizable;
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
	NSLog(@"begin layoutSublayers for %@", self);
	
	// This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask
	CGRect mainLayerBounds = self.bounds;
	CGRect oldBounds = self.previousBounds;
	CGFloat dx = mainLayerBounds.size.width - oldBounds.size.width;
	CGFloat dy = mainLayerBounds.size.height - oldBounds.size.height;
	
	for (CALayer *currentLayer in self.sublayers) {
		// People might add normal CALayers to their hierarchy, don't lay those out
		if ([currentLayer isKindOfClass:[CPLayer class]]) {
			NSLog(@"currentLayer: %@", currentLayer);

			CPLayer *currentCPLayer = (CPLayer *)currentLayer;
			CGRect sublayerFrame = currentCPLayer.frame;
			NSUInteger currentAutoresizingMask = currentCPLayer.layerAutoresizingMask;
            
            if ( currentAutoresizingMask == kCPLayerNotSizable ) continue;
			
			// Align and size along X
			NSUInteger count = 0;
			if (currentAutoresizingMask & kCPLayerMinXMargin) count++;
			if (currentAutoresizingMask & kCPLayerWidthSizable) count++;
			if (currentAutoresizingMask & kCPLayerMaxXMargin) count++;
			
			if (count > 0) {
				CGFloat offset = dx / (CGFloat)count;
				NSLog(@"x offset = %f", offset);
				if (currentAutoresizingMask & kCPLayerMinXMargin) sublayerFrame.origin.x += offset;
				if (currentAutoresizingMask & kCPLayerWidthSizable) sublayerFrame.size.width += offset;
			}
			
			// Align and size along Y
			count = 0;
			if (currentAutoresizingMask & kCPLayerMinYMargin) count++;
			if (currentAutoresizingMask & kCPLayerHeightSizable) count++;
			if (currentAutoresizingMask & kCPLayerMaxYMargin) count++;
			
			if (count > 0) {
				CGFloat offset = dy / (CGFloat)count;
				NSLog(@"y offset = %f", offset);
				if (currentAutoresizingMask & kCPLayerMinYMargin) sublayerFrame.origin.y += offset;
				if (currentAutoresizingMask & kCPLayerHeightSizable) sublayerFrame.size.height += offset;
			}
			
			if (!CGRectEqualToRect(sublayerFrame, currentCPLayer.frame)) {
				currentCPLayer.previousBounds = currentCPLayer.bounds;
				currentCPLayer.frame = sublayerFrame;
			}
		}
		[currentLayer layoutSublayers];
	}	
	self.previousBounds = self.bounds;	
	NSLog(@"end layoutSublayers for %@", self);
}

#pragma mark -
#pragma mark Accessors

-(void)setBounds:(CGRect)newBounds;
{
	self.previousBounds = self.bounds;	
	NSLog(@"%@ setBounds: %@", self, NSStringFromRect(NSRectFromCGRect(newBounds)));
	[super setBounds:newBounds];
}

@end
