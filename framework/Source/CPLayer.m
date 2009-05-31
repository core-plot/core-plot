
#import "CPLayer.h"
#import "CPPlatformSpecificFunctions.h"

@implementation CPLayer

@synthesize layerAutoresizingMask;

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super init] ) {
		previousBounds = CGRectZero;
		self.frame = newFrame;
		self.needsDisplayOnBoundsChange = NO;
        self.opaque = NO;
		layerAutoresizingMask = kCPLayerNotSizable;
		self.masksToBounds = NO;
	}
	return self;
}

- (id)init
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
	
	for (CPLayer *currentSublayer in self.sublayers) {
		CGContextSaveGState(context);
        
		// Shift origin of context to match starting coordinate of sublayer
		CGPoint currentSublayerOrigin = currentSublayer.frame.origin;
		CGContextTranslateCTM (context, currentSublayerOrigin.x, currentSublayerOrigin.y);
		[currentSublayer recursivelyRenderInContext:context];
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
	
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	CGContextFillRect (pdfContext, mediaBox);
	
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
	CGRect mainLayerBounds = self.bounds;
	
	for (CALayer *currentLayer in self.sublayers) {
		// People might add normal CALayers to their hierarchy, don't lay out those
		if ([currentLayer isKindOfClass:[CPLayer class]]) {
			CPLayer *currentCPLayer = (CPLayer *)currentLayer;
			CGRect sublayerFrame = currentCPLayer.frame;
			unsigned int currentAutoresizingMask = currentCPLayer.layerAutoresizingMask;
			
			// Align and size along X
			if (currentAutoresizingMask & kCPLayerWidthSizable) {
				if (currentAutoresizingMask & kCPLayerMaxXMargin) {
					CGFloat maxXMargin = previousBounds.size.width - (sublayerFrame.origin.x + sublayerFrame.size.width);
					if (currentAutoresizingMask & kCPLayerMinXMargin) {
						sublayerFrame.size.width = MAX(0.0, mainLayerBounds.size.width - sublayerFrame.origin.x - maxXMargin);
					}
					else {
						sublayerFrame.origin.x = mainLayerBounds.size.width - sublayerFrame.size.width - maxXMargin;
					}
				}
				else {
					if (currentAutoresizingMask & kCPLayerMinXMargin) {
					}
					else {
						CGFloat scaleDifferenceFromOldWidth = mainLayerBounds.size.width / previousBounds.size.width;
						sublayerFrame.origin.x = sublayerFrame.origin.x * scaleDifferenceFromOldWidth;
						if (sublayerFrame.size.width <= 0.0)
							sublayerFrame.size.width = mainLayerBounds.size.width;
						else
							sublayerFrame.size.width = sublayerFrame.size.width * scaleDifferenceFromOldWidth;
					}
				}
			}
			else {
				if (currentAutoresizingMask & kCPLayerMaxXMargin) {
					CGFloat maxXMargin = previousBounds.size.width - (sublayerFrame.origin.x + sublayerFrame.size.width);
					
					if (currentAutoresizingMask & kCPLayerMinXMargin) {
					}
					else {
						sublayerFrame.origin.x = mainLayerBounds.size.width - sublayerFrame.size.width - maxXMargin;
					}
				}
				else {
					if (currentAutoresizingMask & kCPLayerMinXMargin) {
					}
					else {
						CGFloat scaleDifferenceFromOldWidth = mainLayerBounds.size.width / previousBounds.size.width;
						sublayerFrame.origin.x = sublayerFrame.origin.x * scaleDifferenceFromOldWidth;						
					}
				}
			}
				
			// Align and size along Y
			if (currentAutoresizingMask & kCPLayerHeightSizable) {
				if (currentAutoresizingMask & kCPLayerMaxYMargin) {
					CGFloat maxYMargin = previousBounds.size.height - (sublayerFrame.origin.y + sublayerFrame.size.height);
					
					if (currentAutoresizingMask & kCPLayerMinYMargin) {
						sublayerFrame.size.height = MAX(0.0, mainLayerBounds.size.height - sublayerFrame.origin.y - maxYMargin);
					}
					else {
						sublayerFrame.origin.y = mainLayerBounds.size.height - sublayerFrame.size.height - maxYMargin;
					}
				}
				else {
					if (currentAutoresizingMask & kCPLayerMinYMargin) {
					}
					else {
						CGFloat scaleDifferenceFromOldHeight = mainLayerBounds.size.height / previousBounds.size.height;
						sublayerFrame.origin.y = sublayerFrame.origin.y * scaleDifferenceFromOldHeight;
						if (sublayerFrame.size.height <= 0.0)
							sublayerFrame.size.height = mainLayerBounds.size.height;
						else
							sublayerFrame.size.height = sublayerFrame.size.height * scaleDifferenceFromOldHeight;
					}
				}
			}
			else {
				if (currentAutoresizingMask & kCPLayerMaxYMargin) {
					CGFloat maxYMargin = previousBounds.size.height - (sublayerFrame.origin.y + sublayerFrame.size.height);
					
					if (currentAutoresizingMask & kCPLayerMinYMargin) {
					}
					else {
						sublayerFrame.origin.y = mainLayerBounds.size.height - sublayerFrame.size.height - maxYMargin;
					}
				}
				else {
					if (currentAutoresizingMask & kCPLayerMinXMargin) {
					}
					else {
						CGFloat scaleDifferenceFromOldHeight = mainLayerBounds.size.height / previousBounds.size.height;
						sublayerFrame.origin.y = sublayerFrame.origin.y * scaleDifferenceFromOldHeight;						
					}
				}
			}
			
			if (!CGRectEqualToRect(sublayerFrame, currentCPLayer.frame))
				currentCPLayer.frame = sublayerFrame;
		}		
	}	
	
	previousBounds = self.bounds;
}

#pragma mark -
#pragma mark Accessors

-(void)setBounds:(CGRect)newBounds;
{
	// Deal with the initial bounds setting
	if (CGRectEqualToRect(previousBounds, CGRectZero))
		previousBounds = newBounds;

//	NSLog(@"Bounds: %f, %f", newBounds.size.width, newBounds.size.height);
	[super setBounds:newBounds];
}

@end
