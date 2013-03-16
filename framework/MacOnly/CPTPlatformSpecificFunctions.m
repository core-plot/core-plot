#import "CPTPlatformSpecificFunctions.h"

/** @brief Node in a linked list of graphics contexts.
**/
typedef struct _CPTContextNode {
    NSGraphicsContext *context;       ///< The graphics context.
    struct _CPTContextNode *nextNode; ///< Pointer to the next node in the list.
}
CPTContextNode;

#pragma mark -
#pragma mark Graphics Context

// linked list to store saved contexts
static CPTContextNode *pushedContexts = NULL;

/** @brief Pushes the current AppKit graphics context onto a stack and replaces it with the given Core Graphics context.
 *  @param newContext The graphics context.
 **/
void CPTPushCGContext(CGContextRef newContext)
{
    if ( newContext ) {
        CPTContextNode *newNode = malloc( sizeof(CPTContextNode) );
        newNode->context = [NSGraphicsContext currentContext];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:newContext flipped:NO]];
        newNode->nextNode = pushedContexts;
        pushedContexts    = newNode;
    }
}

/**
 *  @brief Pops the top context off the stack and restores it to the AppKit graphics context.
 **/
void CPTPopCGContext(void)
{
    if ( pushedContexts ) {
        [NSGraphicsContext setCurrentContext:pushedContexts->context];
        CPTContextNode *next = pushedContexts->nextNode;
        free(pushedContexts);
        pushedContexts = next;
    }
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
