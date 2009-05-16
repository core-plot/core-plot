
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"
#import "CPDefinitions.h"

#pragma mark -
#pragma mark Graphics Context

static NSGraphicsContext *pushedContext = nil;

void CPPushCGContext(CGContextRef newContext)
{
    if ( pushedContext != nil ) 
        [NSException raise:CPException format:@"Tried to push two CGContexts in CPPushCGContext"];
    pushedContext = [NSGraphicsContext currentContext];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:newContext flipped:NO]];
}

void CPPopCGContext(void)
{
    [NSGraphicsContext setCurrentContext:pushedContext];
    pushedContext = nil;
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
