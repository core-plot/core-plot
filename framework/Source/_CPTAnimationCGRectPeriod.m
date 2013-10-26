#import "_CPTAnimationCGRectPeriod.h"

@implementation _CPTAnimationCGRectPeriod

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGRect start;
    [invocation getReturnValue:&start];

    self.startValue = [NSValue valueWithBytes:&start objCType:@encode(CGRect)];
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
