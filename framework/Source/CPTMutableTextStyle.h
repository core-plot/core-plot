#import "CPTTextStyle.h"

@class CPTColor;

@interface CPTMutableTextStyle : CPTTextStyle

@property (readwrite, copy, nonatomic) NSString *fontName;
@property (readwrite, assign, nonatomic) CGFloat fontSize;
@property (readwrite, copy, nonatomic) CPTColor *color;
@property (readwrite, assign, nonatomic) CPTTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) NSLineBreakMode lineBreakMode;

@end
