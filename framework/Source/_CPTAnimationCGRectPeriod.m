#import "_CPTAnimationCGRectPeriod.h"

/// @cond
@interface _CPTAnimationCGRectPeriod()

CGRect currentRectValue(id boundObject, SEL boundGetter);

@end
/// @endcond

#pragma mark -

@implementation _CPTAnimationCGRectPeriod

CGRect currentRectValue(id boundObject, SEL boundGetter)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGRect value;
    [invocation getReturnValue:&value];

    return value;
}

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGRect start = currentRectValue(boundObject, boundGetter);

    self.startValue = [NSValue valueWithBytes:&start objCType:@encode(CGRect)];
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGRect current = currentRectValue(boundObject, boundGetter);
    CGRect start;
    CGRect end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    return ( ( (current.origin.x >= start.origin.x) && (current.origin.x <= end.origin.x) ) || ( (current.origin.x >= end.origin.x) && (current.origin.x <= start.origin.x) ) ) &&
           ( ( (current.origin.y >= start.origin.y) && (current.origin.y <= end.origin.y) ) || ( (current.origin.y >= end.origin.y) && (current.origin.y <= start.origin.y) ) ) &&
           ( ( (current.size.width >= start.size.width) && (current.size.width <= end.size.width) ) || ( (current.size.width >= end.size.width) && (current.size.width <= start.size.width) ) ) &&
           ( ( (current.size.height >= start.size.height) && (current.size.height <= end.size.height) ) || ( (current.size.height >= end.size.height) && (current.size.height <= start.size.height) ) );
}

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CGRect start;
    CGRect end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    CGFloat tweenedXValue = start.origin.x + progress * (end.origin.x - start.origin.x);
    CGFloat tweenedYValue = start.origin.y + progress * (end.origin.y - start.origin.y);
    CGFloat tweenedWidth  = start.size.width + progress * (end.size.width - start.size.width);
    CGFloat tweenedHeight = start.size.height + progress * (end.size.height - start.size.height);

    CGRect tweenedRect = CGRectMake(tweenedXValue, tweenedYValue, tweenedWidth, tweenedHeight);

    return [NSValue valueWithBytes:&tweenedRect objCType:@encode(CGRect)];
}

@end
