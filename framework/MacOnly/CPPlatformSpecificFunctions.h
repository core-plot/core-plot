#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPDefinitions.h"

///	@file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPPushCGContext(CGContextRef context);
void CPPopCGContext(void);
///	@}

/// @name Graphics Context
/// @{
CGContextRef CPGetCurrentContext(void);
/// @}

/// @name Color Conversion
/// @{
CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor);
CPRGBAColor CPRGBAColorFromNSColor(NSColor *nsColor);
///	@}

#if __cplusplus
}
#endif
