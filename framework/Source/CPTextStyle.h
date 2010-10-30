#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;
@class CPTextStyle;

/**	@brief A text style delegate.
 **/
@protocol CPTextStyleDelegate <NSObject>

/**	@brief This method is called when the text style changes.
 *	@param textStyle The text style that changed.
 **/
-(void)textStyleDidChange:(CPTextStyle *)textStyle;

@end

@interface CPTextStyle : NSObject <NSCopying, NSCoding> {
	@private
	__weak id <CPTextStyleDelegate> delegate;
    NSString *fontName;
	CGFloat fontSize;
    CPColor *color;
}

@property(readwrite, assign, nonatomic) __weak id <CPTextStyleDelegate> delegate; 
@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPColor *color;

/// @name Factory Methods
/// @{
+(CPTextStyle *)textStyle;
///	@}

@end

/**	@category NSString(CPTextStyleExtensions)
 *	@brief NSString extensions for drawing styled text.
 **/
@interface NSString(CPTextStyleExtensions)

/// @name Measurement
/// @{
-(CGSize)sizeWithTextStyle:(CPTextStyle *)style;
///	@}

/// @name Drawing
/// @{
-(void)drawAtPoint:(CGPoint)point withTextStyle:(CPTextStyle *)style inContext:(CGContextRef)context;
///	@}

@end
