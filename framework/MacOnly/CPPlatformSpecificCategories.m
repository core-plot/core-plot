
#import <AppKit/AppKit.h>
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"

@implementation CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer
{
	NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:self.bounds.size.width pixelsHigh:self.bounds.size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:(self.bounds.size.width * 4) bitsPerPixel:32];
	NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
	CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];
	
	CGContextClearRect(context, CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
	CGContextSetAllowsAntialiasing(context, true);
	[self recursivelyRenderInContext:context];	
	CGContextSetAllowsAntialiasing(context, false);
	CGContextFlush(context);
	[layerImage autorelease];
	
    NSSize nsSize = NSMakeSize(self.bounds.size.width, self.bounds.size.height);
    NSImage *image = [[[NSImage alloc] initWithSize:nsSize] autorelease];
    [image addRepresentation:layerImage];
    
	return image;
}

@end
