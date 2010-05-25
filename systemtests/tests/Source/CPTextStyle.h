
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;

@interface CPTextStyle : NSObject <NSCopying, NSCoding> {
	@private
    NSString *fontName;
	CGFloat fontSize;
    CPColor *color;
}

@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPColor *color;

/// @name Factory Methods
/// @{
+(CPTextStyle *)textStyle;
///	@}

@end

@interface NSString(CPTextStyleExtensions)

/// @name Measurement
/// @{
-(CGSize)sizeWithStyle:(CPTextStyle *)style;
///	@}

/// @name Drawing
/// @{
-(void)drawAtPoint:(CGPoint)point withStyle:(CPTextStyle *)style inContext:(CGContextRef)context;
///	@}

@end
