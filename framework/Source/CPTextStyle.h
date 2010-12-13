
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;

@interface CPTextStyle : NSObject <NSCoding, NSCopying, NSMutableCopying> {
	@protected
    NSString *fontName;
	CGFloat fontSize;
    CPColor *color;
}

@property(readonly, copy, nonatomic) NSString *fontName;
@property(readonly, assign, nonatomic) CGFloat fontSize; 
@property(readonly, copy, nonatomic) CPColor *color;

/// @name Factory Methods
/// @{
+(id)textStyle;
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
