#import "_CPTAnimationCGPointPeriod.h"

/// @cond
@interface _CPTAnimationCGPointPeriod()

CGPoint currentPointValue(id boundObject, SEL boundGetter);

@end
/// @endcond

#pragma mark -

@implementation _CPTAnimationCGPointPeriod

CGPoint currentPointValue(id boundObject, SEL boundGetter)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    [invocation invoke];

    CGPoint value;
    [invocation getReturnValue:&value];

    return value;
}

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGPoint start = currentPointValue(boundObject, boundGetter);

    self.startValue = [NSValue valueWithBytes:&start objCType:@encode(CGPoint)];
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGPoint current = currentPointValue(boundObject, boundGetter);
    CGPoint start;
    CGPoint end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    return ( ( (current.x >= start.x) && (current.x <= end.x) ) || ( (current.x >= end.x) && (current.x <= start.x) ) ) &&
           ( ( (current.y >= start.y) && (current.y <= end.y) ) || ( (current.y >= end.y) && (current.y <= start.y) ) );
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
