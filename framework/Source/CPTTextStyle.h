#include "CPTTextStylePlatformSpecific.h"

@class CPTColor;

@interface CPTTextStyle : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (readonly, copy, nonatomic, nullable) NSString *fontName;
@property (readonly, nonatomic) CGFloat fontSize;
@property (readonly, copy, nonatomic, nullable) CPTColor *color;
@property (readonly, nonatomic) CPTTextAlignment textAlignment;
@property (readonly, assign, nonatomic) NSLineBreakMode lineBreakMode;

/// @name Factory Methods
/// @{
+(nonnull instancetype)textStyle;
/// @}

@end

#pragma mark -

/** @category CPTTextStyle(CPTPlatformSpecificTextStyleExtensions)
 *  @brief Platform-specific extensions to CPTTextStyle.
 **/
@interface CPTTextStyle(CPTPlatformSpecificTextStyleExtensions)

@property (readonly, nonatomic, nonnull) NSDictionary *attributes;

/// @name Factory Methods
/// @{
+(nonnull instancetype)textStyleWithAttributes:(nullable NSDictionary *)attributes;
/// @}

@end

#pragma mark -

/** @category NSString(CPTTextStyleExtensions)
 *  @brief NSString extensions for drawing styled text.
 **/
@interface NSString(CPTTextStyleExtensions)

/// @name Measurement
/// @{
-(CGSize)sizeWithTextStyle:(nullable CPTTextStyle *)style;
/// @}

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect withTextStyle:(nullable CPTTextStyle *)style inContext:(nonnull CGContextRef)context;
/// @}

@end
