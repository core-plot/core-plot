#include "CPTTextStylePlatformSpecific.h"

@class CPTColor;

@interface CPTTextStyle : NSObject<NSCoding, NSCopying, NSMutableCopying> {
    @protected
    NSString *fontName;
    CGFloat fontSize;
    CPTColor *color;
    CPTTextAlignment textAlignment;
    NSLineBreakMode lineBreakMode;
}

@property (readonly, copy, nonatomic) NSString *fontName;
@property (readonly, assign, nonatomic) CGFloat fontSize;
@property (readonly, copy, nonatomic) CPTColor *color;
@property (readonly, assign, nonatomic) CPTTextAlignment textAlignment;
@property (readonly, assign, nonatomic) NSLineBreakMode lineBreakMode;

/// @name Factory Methods
/// @{
+(id)textStyle;
/// @}

@end

#pragma mark -

/** @category CPTTextStyle(CPTPlatformSpecificTextStyleExtensions)
 *  @brief Platform-specific extensions to CPTTextStyle.
 **/
@interface CPTTextStyle(CPTPlatformSpecificTextStyleExtensions)

@property (readonly, copy, nonatomic) NSDictionary *attributes;

/// @name Factory Methods
/// @{
+(id)textStyleWithAttributes:(NSDictionary *)attributes;
/// @}

@end

#pragma mark -

/** @category NSString(CPTTextStyleExtensions)
 *  @brief NSString extensions for drawing styled text.
 **/
@interface NSString(CPTTextStyleExtensions)

/// @name Measurement
/// @{
-(CGSize)sizeWithTextStyle:(CPTTextStyle *)style;
/// @}

/// @name Drawing
/// @{
-(void)drawInRect:(CGRect)rect withTextStyle:(CPTTextStyle *)style inContext:(CGContextRef)context;
/// @}

@end
