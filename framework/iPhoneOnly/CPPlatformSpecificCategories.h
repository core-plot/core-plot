
#import <UIKit/UIKit.h>
#import "CPLayer.h"
#import "CPPlatformSpecificDefines.h"

@interface CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer;

@end

@interface NSNumber (CPPlatformSpecificExtensions)

-(BOOL)isLessThan:(NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other;
-(BOOL)isGreaterThan:(NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other;

@end
