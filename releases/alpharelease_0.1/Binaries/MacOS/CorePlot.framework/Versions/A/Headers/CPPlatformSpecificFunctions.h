
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPDefinitions.h"

///	@file

/// @name Graphics Context Save Stack
/// @{
void CPPushCGContext(CGContextRef context);
void CPPopCGContext(void);
///	@}

/// @name Color Conversion
/// @{
CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor);
CPRGBAColor CPRGBAColorFromNSColor(NSColor *nsColor);
///	@}
