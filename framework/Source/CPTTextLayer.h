#import "CPTBorderedLayer.h"
#import "CPTTextStyle.h"

/// @file

extern const CGFloat kCPTTextLayerMarginWidth; ///< Margin width around the text.

@interface CPTTextLayer : CPTBorderedLayer {
    @private
    NSString *text;
    CPTTextStyle *textStyle;
}

@property (readwrite, copy, nonatomic) NSString *text;
@property (readwrite, retain, nonatomic) CPTTextStyle *textStyle;

/// @name Initialization
/// @{
-(id)initWithText:(NSString *)newText;
-(id)initWithText:(NSString *)newText style:(CPTTextStyle *)newStyle;
/// @}

/// @name Layout
/// @{
-(CGSize)sizeThatFits;
-(void)sizeToFit;
/// @}

@end
