#import "CPTColor.h"
#import "CPTLayer.h"
#import "CPTPlatformSpecificDefines.h"
#import <UIKit/UIKit.h>

/**	@category CPTColor(CPTPlatformSpecificColorExtensions)
 *	@brief Platform-specific extensions to CPTColor.
 **/
@interface CPTColor(CPTPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) UIColor *uiColor;

@end

/**	@category CPTLayer(CPTPlatformSpecificLayerExtensions)
 *	@brief Platform-specific extensions to CPTLayer.
 **/
@interface CPTLayer(CPTPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(CPTNativeImage *)imageOfLayer;
///	@}

@end

/**	@category NSNumber(CPTPlatformSpecificNumberExtensions)
 *	@brief Platform-specific extensions to NSNumber.
 **/
@interface NSNumber(CPTPlatformSpecificNumberExtensions)

-(BOOL)isLessThan:(NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other;
-(BOOL)isGreaterThan:(NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other;

@end
