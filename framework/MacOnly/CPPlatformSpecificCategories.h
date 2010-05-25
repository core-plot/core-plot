#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"
#import "CPColor.h"

/**	@category CPLayer(CPPlatformSpecificLayerExtensions)
 *	@brief Platform-specific extensions to CPLayer.
 **/
@interface CPLayer(CPPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(CPNativeImage *)imageOfLayer;
///	@}

@end

/**	@category CPColor(CPPlatformSpecificColorExtensions)
 *	@brief Platform-specific extensions to CPColor.
 **/
@interface CPColor(CPPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) NSColor *nsColor;

@end
