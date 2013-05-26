@class CPTColor;
@class CPTFill;

@interface CPTLineStyle : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly, assign) CGLineCap lineCap;
@property (nonatomic, readonly, assign) CGLineJoin lineJoin;
@property (nonatomic, readonly, assign) CGFloat miterLimit;
@property (nonatomic, readonly, assign) CGFloat lineWidth;
@property (nonatomic, readonly, strong) NSArray *dashPattern;
@property (nonatomic, readonly, assign) CGFloat patternPhase;
@property (nonatomic, readonly, strong) CPTColor *lineColor;
@property (nonatomic, readonly, strong) CPTFill *lineFill;

/// @name Factory Methods
/// @{
+(id)lineStyle;
/// @}

/// @name Drawing
/// @{
-(void)setLineStyleInContext:(CGContextRef)context;
-(void)strokePathInContext:(CGContextRef)context;
-(void)strokeRect:(CGRect)rect inContext:(CGContextRef)context;
/// @}

@end
