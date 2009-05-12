
#import <UIKit/UIKit.h>
#import "CPLayer.h"
#import "CPPlatformSpecificDefines.h"

@interface CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer;

@end
