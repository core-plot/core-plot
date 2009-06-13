
#import <AppKit/AppKit.h>
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"

@implementation CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer
{
	CGSize boundsSize = self.bounds.size;
	
	NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:boundsSize.width pixelsHigh:boundsSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:(NSInteger)boundsSize.width * 4 bitsPerPixel:32];
	NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
	CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];
	
	CGContextClearRect(context, CGRectMake(0.0f, 0.0f, boundsSize.width, boundsSize.height));
	CGContextSetAllowsAntialiasing(context, true);
	[self recursivelyRenderInContext:context];	
	CGContextSetAllowsAntialiasing(context, false);
	CGContextFlush(context);
	
    NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
    [image addRepresentation:layerImage];
	[layerImage release];
    
	return [image autorelease];
}

@end

@implementation CPColor (CPPlatformSpecificColorExtensions)

-(NSColor *)nsColor
{
	return [NSColor colorWithCIColor:[CIColor colorWithCGColor:self.cgColor]];
}

@end
