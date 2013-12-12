#import "_CPTAnimationNSDecimalPeriod.h"

#import "CPTUtilities.h"

/// @cond
@interface _CPTAnimationNSDecimalPeriod()

NSDecimal currentDecimalValue(id boundObject, SEL boundGetter);

@end
/// @endcond

#pragma mark -

@implementation _CPTAnimationNSDecimalPeriod

NSDecimal currentDecimalValue(id boundObject, SEL boundGetter)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    NSDecimal value;
    [invocation getReturnValue:&value];

    return value;
}

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSDecimal start = currentDecimalValue(boundObject, boundGetter);

    self.startValue = [NSDecimalNumber decimalNumberWithDecimal:start];
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    NSDecimal current = currentDecimalValue(boundObject, boundGetter);
    NSDecimal start   = [(NSDecimalNumber *)self.startValue decimalValue];
    NSDecimal end     = [(NSDecimalNumber *)self.endValue decimalValue];

    return ( CPTDecimalGreaterThanOrEqualTo(current, start) && CPTDecimalLessThanOrEqualTo(current, end) ) ||
           ( CPTDecimalGreaterThanOrEqualTo(current, end) && CPTDecimalLessThanOrEqualTo(current, start) );
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
