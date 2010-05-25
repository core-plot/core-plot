
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

@property (nonatomic, readwrite, assign) CGLineCap lineCap;
@property (nonatomic, readwrite, assign) CGLineJoin lineJoin;
@property (nonatomic, readwrite, assign) CGFloat miterLimit;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, assign) CGSize patternPhase;
@property (nonatomic, readwrite, retain) CPColor *lineColor;

/// @name Factory Methods
/// @{
+(CPLineStyle *)lineStyle;
///	@}

/// @name Drawing
/// @{
-(void)setLineStyleInContext:(CGContextRef)theContext;
///	@}

@end
