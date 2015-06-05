@class CPTColor;
@class CPTFill;
@class CPTGradient;

@interface CPTLineStyle : NSObject<NSCoding, NSCopying, NSMutableCopying>

@property (nonatomic, readonly) CGLineCap lineCap;
@property (nonatomic, readonly) CGLineJoin lineJoin;
@property (nonatomic, readonly) CGFloat miterLimit;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly, nullable) NSArray *dashPattern;
@property (nonatomic, readonly) CGFloat patternPhase;
@property (nonatomic, readonly, nullable) CPTColor *lineColor;
@property (nonatomic, readonly, nullable) CPTFill *lineFill;
@property (nonatomic, readonly, nullable) CPTGradient *lineGradient;
@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;

/// @name Factory Methods
/// @{
+(nonnull instancetype)lineStyle;
/// @}

/// @name Drawing
/// @{
-(void)setLineStyleInContext:(nonnull CGContextRef)context;
-(void)strokePathInContext:(nonnull CGContextRef)context;
-(void)strokeRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
/// @}

@end
