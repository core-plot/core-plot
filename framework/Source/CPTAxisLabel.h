#import "CPTDefinitions.h"

@class CPTLayer;
@class CPTTextStyle;

@interface CPTAxisLabel : NSObject<NSCoding>

@property (nonatomic, readwrite, strong) CPTLayer *contentLayer;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite, assign) CGFloat rotation;
@property (nonatomic, readwrite, assign) CPTAlignment alignment;
@property (nonatomic, readwrite) NSDecimal tickLocation;

/// @name Initialization
/// @{
-(instancetype)initWithText:(NSString *)newText textStyle:(CPTTextStyle *)style;
-(instancetype)initWithContentLayer:(CPTLayer *)layer;
/// @}

/// @name Layout
/// @{
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction;
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPTCoordinate)coordinate inDirection:(CPTSign)direction;
/// @}

@end
