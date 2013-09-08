#import "CPTLineStyle.h"

@class CPTColor;

@interface CPTMutableLineStyle : CPTLineStyle

@property (nonatomic, readwrite, assign) CGLineCap lineCap;
@property (nonatomic, readwrite, assign) CGLineJoin lineJoin;
@property (nonatomic, readwrite, assign) CGFloat miterLimit;
@property (nonatomic, readwrite, assign) CGFloat lineWidth;
@property (nonatomic, readwrite, strong) NSArray *dashPattern;
@property (nonatomic, readwrite, assign) CGFloat patternPhase;
@property (nonatomic, readwrite, strong) CPTColor *lineColor;
@property (nonatomic, readwrite, strong) CPTFill *lineFill;
@property (nonatomic, readwrite, strong) CPTGradient *lineGradient;

@end
