#import "_CPTAnimationCGFloatPeriod.h"

#import "NSNumberExtensions.h"

/// @cond
@interface _CPTAnimationCGFloatPeriod()

CGFloat currentFloatValue(id boundObject, SEL boundGetter);

@end
/// @endcond

#pragma mark -

@implementation _CPTAnimationCGFloatPeriod

CGFloat currentFloatValue(id boundObject, SEL boundGetter)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGFloat value;
    [invocation getReturnValue:&value];

    return value;
}

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    self.startValue = [NSNumber numberWithCGFloat:currentFloatValue(boundObject, boundGetter)];
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGFloat current = currentFloatValue(boundObject, boundGetter);
    CGFloat start;
    CGFloat end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    return ( (current >= start) && (current <= end) ) || ( (current >= end) && (current <= start) );
}

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CGFloat start;
    CGFloat end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    CGFloat tweenedValue = start + progress * (end - start);

    return [NSNumber numberWithCGFloat:tweenedValue];
}

@end
