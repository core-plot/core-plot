
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"

@interface CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer;

@end
