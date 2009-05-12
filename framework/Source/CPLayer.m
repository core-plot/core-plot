
#import "CPLayer.h"


@implementation CPLayer

-(id)init
{
	if ( self = [super init] ) {
		self.needsDisplayOnBoundsChange = YES;
        self.isOpaque = NO;
	}
	return self;
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
	
	for (CPLayer *currentSublayer in self.sublayers)
	{
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
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPushContext(pdfContext);
#else
	NSGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:pdfContext flipped:NO]];
#endif
	
	CGContextBeginPage(pdfContext, &mediaBox);
	
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	CGContextFillRect (pdfContext, mediaBox);
	
	[self recursivelyRenderInContext:pdfContext];
	
	CGContextEndPage(pdfContext);
	CGPDFContextClose(pdfContext);
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPopContext();
#else
	[NSGraphicsContext setCurrentContext:oldContext];
#endif
	
	CGContextRelease(pdfContext);
	
	return [pdfData autorelease];
}

- (PLATFORMIMAGETYPE *)imageOfLayer;
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsBeginImageContext(self.bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetAllowsAntialiasing(context, true);
	
	CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	[self recursivelyRenderInContext:context];
	//	[onlyEquationLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
	CGContextSetAllowsAntialiasing(context, false);
	
	CGContextRestoreGState(context);
	UIGraphicsEndImageContext();
#else
	NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:self.bounds.size.width pixelsHigh:self.bounds.size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:(self.bounds.size.width * 4) bitsPerPixel:32];
	NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
	CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];
	
	CGContextClearRect(context, CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
	CGContextSetAllowsAntialiasing(context, true);
	[self recursivelyRenderInContext:context];	
	CGContextSetAllowsAntialiasing(context, false);
	CGContextFlush(context);
	[layerImage autorelease];
#endif
	
	return layerImage;
}

@end
