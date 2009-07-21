#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"
#import "CPColor.h"

@interface CPLayer(CPPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(CPNativeImage *)imageOfLayer;
///	@}

@end

@interface CPColor(CPPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) NSColor *nsColor;

@end
