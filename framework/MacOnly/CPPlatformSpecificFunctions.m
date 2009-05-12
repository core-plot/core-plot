
#import "CPPlatformSpecificFunctions.h"
#import "CPExceptions.h"

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

