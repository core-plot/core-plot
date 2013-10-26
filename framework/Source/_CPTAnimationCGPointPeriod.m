#import "_CPTAnimationCGPointPeriod.h"

@implementation _CPTAnimationCGPointPeriod

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGPoint start;
    [invocation getReturnValue:&start];

    self.startValue = [NSValue valueWithBytes:&start objCType:@encode(CGPoint)];
}

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
