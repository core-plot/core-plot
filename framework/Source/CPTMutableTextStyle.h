#import "CPTTextStyle.h"

@class CPTColor;

@interface CPTMutableTextStyle : CPTTextStyle

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_TV
@property (readwrite, strong, nonatomic, nullable) UIFont *font;
#else
@property (readwrite, strong, nonatomic, nullable) NSFont *font;
#endif
@property (readwrite, copy, nonatomic, nullable) NSString *fontName;
@property (readwrite, assign, nonatomic) CGFloat fontSize;
@property (readwrite, copy, nonatomic, nullable) CPTColor *color;
@property (readwrite, assign, nonatomic) CPTTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) NSLineBreakMode lineBreakMode;

@end
