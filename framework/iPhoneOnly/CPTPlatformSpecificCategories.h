#import "CPTColor.h"
#import "CPTLayer.h"
#import "CPTPlatformSpecificDefines.h"

#pragma mark CPTColor

/** @category CPTColor(CPTPlatformSpecificColorExtensions)
 *  @brief Platform-specific extensions to CPTColor.
 **/
@interface CPTColor(CPTPlatformSpecificColorExtensions)

@property (nonatomic, readonly, retain) UIColor *uiColor;

@end

#pragma mark - CPTLayer

/** @category CPTLayer(CPTPlatformSpecificLayerExtensions)
 *  @brief Platform-specific extensions to CPTLayer.
 **/
@interface CPTLayer(CPTPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(CPTNativeImage *)imageOfLayer;
/// @}

@end

#pragma mark - NSNumber

/** @category NSNumber(CPTPlatformSpecificNumberExtensions)
 *  @brief Platform-specific extensions to NSNumber.
 **/
@interface NSNumber(CPTPlatformSpecificNumberExtensions)

-(BOOL)isLessThan:(NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other;
-(BOOL)isGreaterThan:(NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other;

@end

#pragma mark - NSAttributedString

/** @category NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)
 *  @brief NSAttributedString extensions for drawing styled text.
 **/
@interface NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;
/// @}

@end
