
#import <Foundation/Foundation.h>

@class CPColor;

@interface CPLineStyle : NSObject <NSCopying> {
	@private
	CGLineCap lineCap;
//	CGLineDash lineDash; // We should make a struct to keep this information
	CGLineJoin lineJoin;
	CGFloat lineWidth;
	CGSize patternPhase;
//	StrokePattern; // We should make a struct to keep this information
    CPColor *lineColor;
}

+(CPLineStyle *)lineStyle;

@property (assign) CGLineCap lineCap;
@property (assign) CGLineJoin lineJoin;
@property (assign) CGFloat lineWidth;
@property (assign) CGSize patternPhase;
@property (retain) CPColor *lineColor;

-(void)setLineStyleInContext:(CGContextRef)theContext;
-(id)copyWithZone:(NSZone *)zone;

@end
