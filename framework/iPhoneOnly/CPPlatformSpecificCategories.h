
#import <UIKit/UIKit.h>
#import "CPColor.h"
#import "CPLayer.h"
#import "CPPlatformSpecificDefines.h"

@interface CPColor (CPPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) UIColor *uiColor;

@end

@interface CPLayer (CPPlatformSpecificLayerExtensions)

-(CPNativeImage *)imageOfLayer;

@end

@interface NSNumber (CPPlatformSpecificExtensions)

-(BOOL)isLessThan:(NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other;
-(BOOL)isGreaterThan:(NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other;

@end
