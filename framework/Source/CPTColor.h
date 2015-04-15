@interface CPTColor : NSObject<NSCopying, NSCoding>

@property (nonatomic, readonly) CGColorRef cgColor;
@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;

/// @name Factory Methods
/// @{
+(instancetype)clearColor;
+(instancetype)whiteColor;
+(instancetype)lightGrayColor;
+(instancetype)grayColor;
+(instancetype)darkGrayColor;
+(instancetype)blackColor;
+(instancetype)redColor;
+(instancetype)greenColor;
+(instancetype)blueColor;
+(instancetype)cyanColor;
+(instancetype)yellowColor;
+(instancetype)magentaColor;
+(instancetype)orangeColor;
+(instancetype)purpleColor;
+(instancetype)brownColor;

+(instancetype)colorWithCGColor:(CGColorRef)newCGColor;
+(instancetype)colorWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+(instancetype)colorWithGenericGray:(CGFloat)gray;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithCGColor:(CGColorRef)cgColor NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;

-(instancetype)colorWithAlphaComponent:(CGFloat)alpha;
/// @}

@end
