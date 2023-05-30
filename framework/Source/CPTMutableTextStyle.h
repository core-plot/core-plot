/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTTextStyle.h>
#else
#import "CPTTextStyle.h"
#endif

@class CPTColor;

@interface CPTMutableTextStyle : CPTTextStyle

@property (readwrite, strong, nonatomic, nullable) CPTNativeFont *font;
@property (readwrite, copy, nonatomic, nullable) NSString *fontName;
@property (readwrite, assign, nonatomic) CGFloat fontSize;
@property (readwrite, copy, nonatomic, nullable) CPTColor *color;
@property (readwrite, assign, nonatomic) CPTTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) NSLineBreakMode lineBreakMode;

@end

/** @category CPTMutableTextStyle(CPTPlatformSpecificMutableTextStyleExtensions)
 *  @brief Platform-specific extensions to CPTMutableTextStyle
 *
 *  @see CPTMutableTextStyle
 **/
@interface CPTMutableTextStyle(CPTPlatformSpecificMutableTextStyleExtensions)

@end
