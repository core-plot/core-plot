#import "CPTDefinitions.h"

@class CPTLayer;
@class CPTTextStyle;

@interface CPTAxisLabel : NSObject<NSCoding>

@property (nonatomic, readwrite, strong, nullable) CPTLayer *contentLayer;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite, assign) CGFloat rotation;
@property (nonatomic, readwrite, assign) CPTAlignment alignment;
@property (nonatomic, readwrite, strong, nullable) NSNumber *tickLocation;

/// @name Initialization
/// @{
-(nonnull instancetype)initWithText:(nullable NSString *)newText textStyle:(nullable CPTTextStyle *)style;
-(nonnull instancetype)initWithContentLayer:(nonnull CPTLayer *)layer NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Layout
/// @{
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction;
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction;
/// @}

@end
