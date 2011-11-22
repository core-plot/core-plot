#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

///	@file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(CGContextRef context);
void CPTPopCGContext(void);

///	@}

/// @name Graphics Context
/// @{
CGContextRef CPTGetCurrentContext(void);

/// @}

#if __cplusplus
}
#endif
