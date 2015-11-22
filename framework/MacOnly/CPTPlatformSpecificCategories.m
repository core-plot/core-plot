#import "CPTPlatformSpecificCategories.h"

#import "CPTPlatformSpecificFunctions.h"

#pragma mark CPTLayer

@implementation CPTLayer(CPTPlatformSpecificLayerExtensions)

/** @brief Gets an image of the layer contents.
 *  @return A native image representation of the layer content.
 **/
-(CPTNativeImage *)imageOfLayer
{
    CGSize boundsSize = self.bounds.size;

    NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                           pixelsWide:(NSInteger)boundsSize.width
                                                                           pixelsHigh:(NSInteger)boundsSize.height
                                                                        bitsPerSample:8
                                                                      samplesPerPixel:4
                                                                             hasAlpha:YES
                                                                             isPlanar:NO
                                                                       colorSpaceName:NSCalibratedRGBColorSpace
                                                                          bytesPerRow:(NSInteger)boundsSize.width * 4
                                                                         bitsPerPixel:32];

    NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
    CGContextRef context             = (CGContextRef)bitmapContext.graphicsPort;

    CGContextClearRect( context, CPTRectMake(0.0, 0.0, boundsSize.width, boundsSize.height) );
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldSmoothFonts(context, false);
    [self layoutAndRenderInContext:context];
    CGContextFlush(context);

    NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
    [image addRepresentation:layerImage];

    return image;
}

@end

#pragma mark - CPTColor

@implementation CPTColor(CPTPlatformSpecificColorExtensions)

/** @property nsColor
 *  @brief Gets the color value as an NSColor.
 **/
@dynamic nsColor;

-(NSColor *)nsColor
{
    return [NSColor colorWithCIColor:[CIColor colorWithCGColor:self.cgColor]];
}

@end

#pragma mark - NSAttributedString

@implementation NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)

/** @brief Draws the styled text into the given graphics context.
 *  @param rect The bounding rectangle in which to draw the text.
 *  @param context The graphics context to draw into.
 **/
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context
{
    CPTPushCGContext(context);

    [self drawWithRect:NSRectFromCGRect(rect)
               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine];

    CPTPopCGContext();
}

@end
