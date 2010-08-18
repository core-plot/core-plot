
#import "CPPlatformSpecificFunctions.h"
#import "CPPlatformSpecificDefines.h"
#import "CPDefinitions.h"

#pragma mark -
#pragma mark Graphics Context

// linked list to store saved contexts
static CPContextNode *pushedContexts = NULL;

/**	@brief Pushes the current AppKit graphics context onto a stack and replaces it with the given Core Graphics context.
 *	@param newContext The graphics context.
 **/
void CPPushCGContext(CGContextRef newContext)
{
	if (newContext) {
		CPContextNode *newNode = malloc(sizeof(CPContextNode));
		(*newNode).context = [NSGraphicsContext currentContext];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:newContext flipped:NO]];
		(*newNode).nextNode = pushedContexts;
		pushedContexts = newNode;
	}
}

/**	@brief Pops the top context off the stack and restores it to the AppKit graphics context.
 **/
void CPPopCGContext(void)
{
	if (pushedContexts) {
		[NSGraphicsContext setCurrentContext:(*pushedContexts).context];
		CPContextNode *next = (*pushedContexts).nextNode;
		free(pushedContexts);
		pushedContexts = next;
	}
}

#pragma mark -
#pragma mark Context

/** @brief Get the default graphics context
 **/
 
CGContextRef CPGetCurrentContext(void)
{
    return [[NSGraphicsContext currentContext] graphicsPort];
}

#pragma mark -
#pragma mark Colors

/**	@brief Creates a CGColorRef from an NSColor.
 *
 *	The caller must release the returned CGColorRef. Pattern colors are not supported.
 *
 *	@param nsColor The NSColor.
 *	@return The CGColorRef.
 **/
CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor)
{
	NSColor *rgbColor = [nsColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	CGFloat r, g, b, a;
	[rgbColor getRed:&r green:&g blue:&b alpha:&a];
	return CGColorCreateGenericRGB(r, g, b, a);
}

/**	@brief Creates a CPRGBAColor from an NSColor.
 *
 *	Pattern colors are not supported.
 *
 *	@param nsColor The NSColor.
 *	@return The CPRGBAColor.
 **/
CPRGBAColor CPRGBAColorFromNSColor(NSColor *nsColor)
{
	CGFloat red, green, blue, alpha;
	
	[[nsColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
	
	CPRGBAColor rgbColor;
	rgbColor.red = red;
	rgbColor.green = green;
	rgbColor.blue = blue;
	rgbColor.alpha = alpha;
	
	return rgbColor;
}
