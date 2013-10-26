#import "_CPTAnimationNSDecimalPeriod.h"

#import "CPTUtilities.h"

@implementation _CPTAnimationNSDecimalPeriod

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    NSDecimal start;
    [invocation getReturnValue:&start];

    self.startValue = [NSDecimalNumber decimalNumberWithDecimal:start];
}

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    NSDecimal start = [(NSDecimalNumber *)self.startValue decimalValue];
    NSDecimal end   = [(NSDecimalNumber *)self.endValue decimalValue];

    NSDecimal length       = CPTDecimalSubtract(end, start);
    NSDecimal tweenedValue = CPTDecimalAdd( start, CPTDecimalMultiply(CPTDecimalFromCGFloat(progress), length) );

    return [NSDecimalNumber decimalNumberWithDecimal:tweenedValue];
}

@end
