/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTDefinitions.h>
#import <CorePlot/CPTPlatformSpecificDefines.h>
#else
#import "CPTDefinitions.h"
#import "CPTPlatformSpecificDefines.h"
#endif

#import <TargetConditionals.h>

#if TARGET_OS_OSX

#pragma mark macOS
#pragma mark -

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(__nonnull CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Color Conversion
/// @{
__nonnull CGColorRef CPTCreateCGColorFromNSColor(NSColor *__nonnull nsColor) CF_RETURNS_RETAINED;
CPTRGBAColor CPTRGBAColorFromNSColor(NSColor *__nonnull nsColor);

/// @}

/// @name Debugging
/// @{
CPTNativeImage *__nonnull CPTQuickLookImage(CGRect rect, __nonnull CPTQuickLookImageBlock renderBlock);

/// @}

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif

#else

#pragma mark - iOS, tvOS, Mac Catalyst
#pragma mark -

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(__nonnull CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Debugging
/// @{
CPTNativeImage *__nonnull CPTQuickLookImage(CGRect rect, __nonnull CPTQuickLookImageBlock renderBlock);

/// @}

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif

#endif
