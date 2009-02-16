
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

-(void)writePDFOfLayerToFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	CFURLRef pdfURL = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)[documentsDirectory stringByAppendingPathComponent:fileName], kCFURLPOSIXPathStyle, false);
	
	const CGRect mediaBox = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	CGContextRef pdfContext = CGPDFContextCreateWithURL(pdfURL, &mediaBox, NULL);
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPushContext(pdfContext);
#else
	NSGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:pdfContext flipped:NO]];
#endif
	
	CGContextBeginPage(pdfContext, &mediaBox);
	
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	CGContextFillRect (pdfContext, mediaBox);
	
	[self recursivelyRenderInContext:pdfContext];
	
	CGContextEndPage(pdfContext);	
	
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
	UIGraphicsPopContext();
#else
	[NSGraphicsContext setCurrentContext:oldContext];
#endif
	
	CFRelease(pdfURL);
	CGContextRelease(pdfContext);
}

@end
