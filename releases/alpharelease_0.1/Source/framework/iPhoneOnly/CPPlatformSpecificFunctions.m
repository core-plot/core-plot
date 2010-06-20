
#import <UIKit/UIKit.h>
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"

void CPPushCGContext(CGContextRef newContext)
{
    UIGraphicsPushContext(newContext);
}

void CPPopCGContext(void)
{
    UIGraphicsPopContext();
}

