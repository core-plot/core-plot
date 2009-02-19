
#import <Foundation/Foundation.h>


@interface CPLineStyle : NSObject {
	CGLineCap lineCap;
//	CGLineDash lineDash; // We should make a struct to keep this information
	CGLineJoin lineJoin;
	CGFloat lineWidth;
	CGSize patternPhase;
//	StrokePattern; // We should make a struct to keep this information
	CGColorRef lineColor;
}

+(CPLineStyle *)lineStyle;

@property (assign) CGLineCap lineCap;
@property (assign) CGLineJoin lineJoin;
@property (assign) CGFloat lineWidth;
@property (assign) CGSize patternPhase;
@property (assign) CGColorRef lineColor;

-(void)setLineStyleInContext:(CGContextRef)theContext;

@end
