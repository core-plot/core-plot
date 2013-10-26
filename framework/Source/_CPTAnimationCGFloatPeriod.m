#import "_CPTAnimationCGFloatPeriod.h"

#import "NSNumberExtensions.h"

@implementation _CPTAnimationCGFloatPeriod

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGFloat start;
    [invocation getReturnValue:&start];

    self.startValue = @(start);
}

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CGFloat start;
    CGFloat end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    CGFloat tweenedValue = start + progress * (end - start);

    return @(tweenedValue);
}

@end
