#import "CPTBorderedLayer.h"
#import "CPTTextStyle.h"

/// @file

extern const CGFloat kCPTTextLayerMarginWidth; ///< Margin width around the text.

@interface CPTTextLayer : CPTBorderedLayer

@property (readwrite, copy, nonatomic) NSString *text;
@property (readwrite, strong, nonatomic) CPTTextStyle *textStyle;
@property (readwrite, copy, nonatomic) NSAttributedString *attributedText;
@property (readwrite, nonatomic) CGSize maximumSize;

/// @name Initialization
/// @{
-(instancetype)initWithText:(NSString *)newText;
-(instancetype)initWithText:(NSString *)newText style:(CPTTextStyle *)newStyle;
-(instancetype)initWithAttributedText:(NSAttributedString *)newText;
/// @}

/// @name Layout
/// @{
-(CGSize)sizeThatFits;
-(void)sizeToFit;
/// @}

@end
