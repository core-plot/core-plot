/// @file

@class CPTGradient;
@class CPTImage;
@class CPTColor;
@class CPTFill;

/**
 *  @brief An array of fills.
 **/
typedef NSArray<CPTFill *> CPTFillArray;

/**
 *  @brief A mutable array of fills.
 **/
typedef NSMutableArray<CPTFill *> CPTMutableFillArray;

@interface CPTFill : NSObject<NSCopying, NSCoding, NSSecureCoding>

/// @name Factory Methods
/// @{
+(nonnull instancetype)fillWithColor:(nullable CPTColor *)aColor;
+(nonnull instancetype)fillWithGradient:(nullable CPTGradient *)aGradient;
+(nonnull instancetype)fillWithImage:(nullable CPTImage *)anImage;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initWithColor:(nullable CPTColor *)aColor;
-(nonnull instancetype)initWithGradient:(nullable CPTGradient *)aGradient;
-(nonnull instancetype)initWithImage:(nullable CPTImage *)anImage;
/// @}

@end

/** @category CPTFill(AbstractMethods)
 *  @brief CPTFill abstract methods—must be overridden by subclasses
 **/
@interface CPTFill(AbstractMethods)

@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;
@property (nonatomic, readonly, nullable) CGColorRef cgColor;

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
-(void)fillPathInContext:(nonnull CGContextRef)context;
/// @}

@end
