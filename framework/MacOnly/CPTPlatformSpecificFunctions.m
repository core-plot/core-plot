#import "CPTPlatformSpecificFunctions.h"

#pragma mark Graphics Context

// linked list to store saved contexts
static NSMutableArray *pushedContexts   = nil;
static dispatch_once_t contextOnceToken = 0;

static dispatch_queue_t contextQueue  = NULL;
static dispatch_once_t queueOnceToken = 0;

/** @brief Pushes the current AppKit graphics context onto a stack and replaces it with the given Core Graphics context.
 *  @param newContext The graphics context.
 **/
void CPTPushCGContext(CGContextRef newContext)
{
    dispatch_once(&contextOnceToken, ^{
        pushedContexts = [[NSMutableArray alloc] init];
    });
    dispatch_once(&queueOnceToken, ^{
        contextQueue = dispatch_queue_create("CorePlot.contextQueue", NULL);
    });

    dispatch_sync(contextQueue, ^{
        if ( newContext ) {
            [pushedContexts addObject:[NSGraphicsContext currentContext]];
            [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:newContext flipped:NO]];
        }
        else {
            [pushedContexts addObject:[NSNull null]];
        }
    });
}

/**
 *  @brief Pops the top context off the stack and restores it to the AppKit graphics context.
 **/
void CPTPopCGContext(void)
{
    dispatch_once(&contextOnceToken, ^{
        pushedContexts = [[NSMutableArray alloc] init];
    });
    dispatch_once(&queueOnceToken, ^{
        contextQueue = dispatch_queue_create("CorePlot.contextQueue", NULL);
    });

    dispatch_sync(contextQueue, ^{
        if ( pushedContexts.count > 0 ) {
            NSGraphicsContext *lastContext = pushedContexts.lastObject;

            if ( [lastContext isKindOfClass:[NSGraphicsContext class]] ) {
                [NSGraphicsContext setCurrentContext:lastContext];
            }
            [pushedContexts removeLastObject];
        }
    });
}

#pragma mark -
#pragma mark Context

/**
 *  @brief Get the default graphics context
 **/
CGContextRef CPTGetCurrentContext(void)
{
    return [[NSGraphicsContext currentContext] graphicsPort];
}

#pragma mark -
#pragma mark Colors

/** @brief Creates a @ref CGColorRef from an NSColor.
 *
 *  The caller must release the returned @ref CGColorRef. Pattern colors are not supported.
 *
 *  @param nsColor The NSColor.
 *  @return The @ref CGColorRef.
 **/
CGColorRef CPTCreateCGColorFromNSColor(NSColor *nsColor)
{
    NSColor *rgbColor = [nsColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    CGFloat r, g, b, a;

    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    return CGColorCreateGenericRGB(r, g, b, a);
}

/** @brief Creates a CPTRGBAColor from an NSColor.
 *
 *  Pattern colors are not supported.
 *
 *  @param nsColor The NSColor.
 *  @return The CPTRGBAColor.
 **/
CPTRGBAColor CPTRGBAColorFromNSColor(NSColor *nsColor)
{
    CGFloat red, green, blue, alpha;

    [[nsColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];

    CPTRGBAColor rgbColor;
    rgbColor.red   = red;
    rgbColor.green = green;
    rgbColor.blue  = blue;
    rgbColor.alpha = alpha;

    return rgbColor;
}
