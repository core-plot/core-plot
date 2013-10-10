#import "_CPTAnimationNSDecimalPeriod.h"

#import "CPTUtilities.h"

@implementation _CPTAnimationNSDecimalPeriod

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    NSDecimal start = [(NSDecimalNumber *)self.startValue decimalValue];
    NSDecimal end   = [(NSDecimalNumber *)self.endValue decimalValue];

    NSDecimal length       = CPTDecimalSubtract(end, start);
    NSDecimal tweenedValue = CPTDecimalAdd( start, CPTDecimalMultiply(CPTDecimalFromCGFloat(progress), length) );

    return [NSDecimalNumber decimalNumberWithDecimal:tweenedValue];
}

@end
