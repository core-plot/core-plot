
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;

@interface CPLineStyle : NSObject <NSCopying> {
@private
	CGLineCap lineCap;
//	CGLineDash lineDash; // We should make a struct to keep this information
	CGLineJoin lineJoin;
	CGFloat miterLimit;
	CGFloat lineWidth;
	CGSize patternPhase;
//	StrokePattern; // We should make a struct to keep this information
    CPColor *lineColor;
}

@property (assign) CGLineCap lineCap;
@property (assign) CGLineJoin lineJoin;
@property (assign) CGFloat miterLimit;
@property (assign) CGFloat lineWidth;
@property (assign) CGSize patternPhase;
@property (retain) CPColor *lineColor;

/// @name Factory Methods
/// @{
+(CPLineStyle *)lineStyle;
///	@}

/// @name Drawing
/// @{
-(void)setLineStyleInContext:(CGContextRef)theContext;
///	@}

@end
