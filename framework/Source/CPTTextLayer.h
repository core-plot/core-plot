/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTBorderedLayer.h>
#import <CorePlot/CPTTextStyle.h>
#else
#import "CPTBorderedLayer.h"
#import "CPTTextStyle.h"
#endif

extern const CGFloat kCPTTextLayerMarginWidth; ///< Margin width around the text.

@interface CPTTextLayer : CPTBorderedLayer

@property (readwrite, copy, nonatomic, nullable) NSString *text;
@property (readwrite, strong, nonatomic, nullable) CPTTextStyle *textStyle;
@property (readwrite, copy, nonatomic, nullable) NSAttributedString *attributedText;
@property (readwrite, nonatomic) CGSize maximumSize;

/// @name Initialization
/// @{
-(nonnull instancetype)initWithText:(nullable NSString *)newText;
-(nonnull instancetype)initWithText:(nullable NSString *)newText style:(nullable CPTTextStyle *)newStyle;
-(nonnull instancetype)initWithAttributedText:(nullable NSAttributedString *)newText;
/// @}

/// @name Layout
/// @{
-(CGSize)sizeThatFits;
-(void)sizeToFit;
/// @}

@end
