
#import <UIKit/UIKit.h>
#import "CPColor.h"
#import "CPLayer.h"
#import "CPPlatformSpecificDefines.h"

/**	@category CPColor(CPPlatformSpecificColorExtensions)
 *	@brief Platform-specific extensions to CPColor.
 **/
@interface CPColor(CPPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) UIColor *uiColor;

@end

/**	@category CPLayer(CPPlatformSpecificLayerExtensions)
 *	@brief Platform-specific extensions to CPLayer.
 **/
@interface CPLayer(CPPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(CPNativeImage *)imageOfLayer;
///	@}

@end

/**	@category NSNumber(CPPlatformSpecificNumberExtensions)
 *	@brief Platform-specific extensions to NSNumber.
 **/
@interface NSNumber(CPPlatformSpecificNumberExtensions)

-(BOOL)isLessThan:(NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other;
-(BOOL)isGreaterThan:(NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other;

@end
