
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

@interface CPAxisLabel : CPLayer {
    NSString *text;
    CPLayer *contentLayer;
    CGFloat offset;
    NSDecimalNumber *tickLocation;
}

@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readonly, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite, copy) NSDecimalNumber *tickLocation;

-(id)initWithText:(NSString *)newText;
-(id)initWithContentLayer:(CPLayer *)layer;

-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;

@end
