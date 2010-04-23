#import <AppKit/AppKit.h>
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"

@implementation CPLayer(CPPlatformSpecificLayerExtensions)

/**	@brief Gets an image of the layer contents.
 *	@return A native image representation of the layer content.
 **/
-(CPNativeImage *)imageOfLayer
{
	CGSize boundsSize = self.bounds.size;
	
	NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:boundsSize.width pixelsHigh:boundsSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:(NSInteger)boundsSize.width * 4 bitsPerPixel:32];
	NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
	CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];
	
	CGContextClearRect(context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height));
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetShouldSmoothFonts(context, false);
	[self layoutAndRenderInContext:context];	
	CGContextFlush(context);
	
    NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
    [image addRepresentation:layerImage];
	[layerImage release];
    
	return [image autorelease];
}

@end

#pragma mark -

@implementation CPColor(CPPlatformSpecificColorExtensions)

/**	@property nsColor
 *	@brief Gets the color value as an NSColor.
 **/
@dynamic nsColor;

-(NSColor *)nsColor
{
	return [NSColor colorWithCIColor:[CIColor colorWithCGColor:self.cgColor]];
}

@end
