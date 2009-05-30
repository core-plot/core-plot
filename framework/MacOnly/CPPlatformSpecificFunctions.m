
#import "CPPlatformSpecificFunctions.h"
#import "CPDefinitions.h"

#pragma mark -
#pragma mark Graphics Context

// linked list to store saved contexts
static CPContextNode *pushedContexts = NULL;

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
#pragma mark Colors

CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor)
{
	NSColor *rgbColor = [nsColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	CGFloat r, g, b, a;
	[rgbColor getRed:&r green:&g blue:&b alpha:&a];
	return CGColorCreateGenericRGB(r, g, b, a);
}

CPRGBAColor CPRGBAColorFromNSColor(NSColor *nsColor)
{
	CPRGBAColor rgbColor;
	[[nsColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&rgbColor.red green:&rgbColor.green blue:&rgbColor.blue alpha:&rgbColor.alpha];
	return rgbColor;
}
