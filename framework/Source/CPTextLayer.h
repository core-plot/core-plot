#import "CPLayer.h"
#import "CPTextStyle.h"

///	@file

extern const CGFloat kCPTextLayerMarginWidth;	///< Margin width around the text.

@interface CPTextLayer : CPLayer <CPTextStyleDelegate> {
	@private
	NSString *text;
	CPTextStyle *textStyle;
}

@property(readwrite, copy, nonatomic) NSString *text;
@property(readwrite, retain, nonatomic) CPTextStyle *textStyle;

/// @name Initialization
/// @{
-(id)initWithText:(NSString *)newText;
-(id)initWithText:(NSString *)newText style:(CPTextStyle *)newStyle;
///	@}

/// @name Layout
/// @{
-(void)sizeToFit;
///	@}

@end
