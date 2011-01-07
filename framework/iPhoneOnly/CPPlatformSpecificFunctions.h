#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

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

#if __cplusplus
}
#endif
