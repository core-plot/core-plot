
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPDefinitions.h"

// Graphics Context
void CPPushCGContext(CGContextRef context);
void CPPopCGContext(void);

// Colors
CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor);
CPRGBAColor CPRGBAColorFromNSColor(NSColor *nsColor);