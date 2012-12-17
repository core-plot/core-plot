#import "_CPTAnimationCGPointPeriod.h"

@implementation _CPTAnimationCGPointPeriod

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CGPoint start;
    CGPoint end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    CGFloat tweenedXValue = start.x + progress * (end.x - start.x);
    CGFloat tweenedYValue = start.y + progress * (end.y - start.y);

    CGPoint tweenedPoint = CGPointMake(tweenedXValue, tweenedYValue);

    return [NSValue valueWithBytes:&tweenedPoint objCType:@encode(CGPoint)];
}

@end
