
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPTColor;

@interface CPTTextStyle : NSObject <NSCoding, NSCopying, NSMutableCopying> {
	@protected
    NSString *fontName;
	CGFloat fontSize;
    CPTColor *color;
}

@property(readonly, copy, nonatomic) NSString *fontName;
@property(readonly, assign, nonatomic) CGFloat fontSize; 
@property(readonly, copy, nonatomic) CPTColor *color;

/// @name Factory Methods
/// @{
+(id)textStyle;
///	@}

@end


/**	@category NSString(CPTTextStyleExtensions)
 *	@brief NSString extensions for drawing styled text.
 **/
@interface NSString(CPTTextStyleExtensions)

/// @name Measurement
/// @{
-(CGSize)sizeWithTextStyle:(CPTTextStyle *)style;
///	@}

/// @name Drawing
/// @{
-(void)drawAtPoint:(CGPoint)point withTextStyle:(CPTTextStyle *)style inContext:(CGContextRef)context;
///	@}

@end
