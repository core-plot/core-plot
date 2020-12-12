#import <TargetConditionals.h>

#import "CPTColor.h"
#import "CPTLayer.h"
#import "CPTPlatformSpecificDefines.h"

#if TARGET_OS_OSX

#pragma mark macOS
#pragma mark -

#pragma mark CPTLayer

/** @category CPTLayer(CPTPlatformSpecificLayerExtensions)
 *  @brief Platform-specific extensions to CPTLayer.
 **/
@interface CPTLayer(CPTPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(nonnull CPTNativeImage *)imageOfLayer;
/// @}

@end

#pragma mark - NSAttributedString

/** @category NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)
 *  @brief NSAttributedString extensions for drawing styled text.
 **/
@interface NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
/// @}

/// @name Measurement
/// @{
-(CGSize)sizeAsDrawn;
/// @}

@end

#else

#pragma mark - iOS, tvOS, Mac Catalyst

#pragma mark - CPTLayer

/** @category CPTLayer(CPTPlatformSpecificLayerExtensions)
 *  @brief Platform-specific extensions to CPTLayer.
 **/
@interface CPTLayer(CPTPlatformSpecificLayerExtensions)

/// @name Images
/// @{
-(nullable CPTNativeImage *)imageOfLayer;
/// @}

@end

#pragma mark - NSNumber

/** @category NSNumber(CPTPlatformSpecificNumberExtensions)
 *  @brief Platform-specific extensions to NSNumber.
 **/
@interface NSNumber(CPTPlatformSpecificNumberExtensions)

-(BOOL)isLessThan:(nonnull NSNumber *)other;
-(BOOL)isLessThanOrEqualTo:(nonnull NSNumber *)other;
-(BOOL)isGreaterThan:(nonnull NSNumber *)other;
-(BOOL)isGreaterThanOrEqualTo:(nonnull NSNumber *)other;

@end

#pragma mark - NSAttributedString

/** @category NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)
 *  @brief NSAttributedString extensions for drawing styled text.
 **/
@interface NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
/// @}

/// @name Measurement
/// @{
-(CGSize)sizeAsDrawn;
/// @}

@end

#endif
