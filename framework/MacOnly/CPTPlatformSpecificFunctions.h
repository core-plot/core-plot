#import "CPTDefinitions.h"

/// @file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Graphics Context
/// @{
CGContextRef CPTGetCurrentContext(void);

/// @}

/// @name Color Conversion
/// @{
CGColorRef CPTCreateCGColorFromNSColor(NSColor *nsColor);
CPTRGBAColor CPTRGBAColorFromNSColor(NSColor *nsColor);

/// @}

#if __cplusplus
}
#endif
