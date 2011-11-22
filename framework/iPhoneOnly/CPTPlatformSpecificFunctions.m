#import "CPTPlatformSpecificFunctions.h"

#import "CPTExceptions.h"
#import <UIKit/UIKit.h>

void CPTPushCGContext(CGContextRef newContext)
{
	UIGraphicsPushContext(newContext);
}

void CPTPopCGContext(void)
{
	UIGraphicsPopContext();
}

CGContextRef CPTGetCurrentContext(void)
{
	return UIGraphicsGetCurrentContext();
}
