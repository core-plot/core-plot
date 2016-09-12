#import "CPTPlatformSpecificCategories.h"

#import "CPTGraph.h"
#import "CPTGraphHostingView.h"
#import "CPTPlatformSpecificFunctions.h"

#pragma mark CPTLayer

@implementation CPTLayer(CPTPlatformSpecificLayerExtensions)

/** @brief Gets an image of the layer contents.
 *  @return A native image representation of the layer content.
 **/
-(nonnull CPTNativeImage *)imageOfLayer
{
    CGSize boundsSize = self.bounds.size;

    // Figure out the scale of pixels to points
    CGFloat scale = 0.0;

    if ( [self respondsToSelector:@selector(hostingView)] ) {
        scale = ( (CPTGraph *)self ).hostingView.window.backingScaleFactor;
    }
    else {
        NSWindow *myWindow = self.graph.hostingView.window;

        if ( myWindow ) {
            scale = myWindow.backingScaleFactor;
        }
        else {
            scale = [NSScreen mainScreen].backingScaleFactor;
        }
    }

    NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc]
                                    initWithBitmapDataPlanes:NULL
                                                  pixelsWide:(NSInteger)(boundsSize.width * scale)
                                                  pixelsHigh:(NSInteger)(boundsSize.height * scale)
                                               bitsPerSample:8
                                             samplesPerPixel:4
                                                    hasAlpha:YES
                                                    isPlanar:NO
                                              colorSpaceName:NSCalibratedRGBColorSpace
                                                bitmapFormat:NSAlphaFirstBitmapFormat
                                                 bytesPerRow:0
                                                bitsPerPixel:0
                                   ];

    // Setting the size communicates the dpi; enables proper scaling for Retina screens
    layerImage.size = NSSizeFromCGSize(boundsSize);

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

-(nonnull NSColor *)nsColor
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
-(void)drawInRect:(CGRect)rect inContext:(nonnull CGContextRef)context
{
    CPTPushCGContext(context);

    [self drawWithRect:NSRectFromCGRect(rect)
               options:CPTStringDrawingOptions];

    CPTPopCGContext();
}

/**
 *  @brief Computes the size of the styled text when drawn rounded up to the nearest whole number in each dimension.
 **/
-(CGSize)sizeAsDrawn
{
    CGRect rect = CGRectZero;

    if ( [self respondsToSelector:@selector(boundingRectWithSize:options:context:)] ) {
        rect = [self boundingRectWithSize:CPTSizeMake(10000.0, 10000.0)
                                  options:CPTStringDrawingOptions
                                  context:nil];
    }
    else {
        rect = [self boundingRectWithSize:CPTSizeMake(10000.0, 10000.0)
                                  options:CPTStringDrawingOptions];
    }

    CGSize textSize = rect.size;

    textSize.width  = ceil(textSize.width);
    textSize.height = ceil(textSize.height);

    return textSize;
}

@end
