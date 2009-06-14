
#import "CPLayer.h"

@class CPTextStyle;

extern CGFloat kCPTextLayerMarginWidth;

@interface CPTextLayer : CPLayer {
	NSString *text;
	CPTextStyle *textStyle;
}

@property(readwrite, copy, nonatomic) NSString *text;
@property(readwrite, retain, nonatomic) CPTextStyle *textStyle;

// Initialization and teardown
-(id)initWithText:(NSString *)newText;
-(id)initWithText:(NSString *)newText style:(CPTextStyle *)newStyle;

// Layout
-(void)sizeToFit;

@end
