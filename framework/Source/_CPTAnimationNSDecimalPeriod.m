#import "_CPTAnimationNSDecimalPeriod.h"

#import "CPTUtilities.h"

@implementation _CPTAnimationNSDecimalPeriod

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    NSDecimal start;
    NSDecimal end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    NSDecimal length       = CPTDecimalSubtract(end, start);
    NSDecimal tweenedValue = CPTDecimalAdd( start, CPTDecimalMultiply(CPTDecimalFromCGFloat(progress), length) );

    return [NSDecimalNumber decimalNumberWithDecimal:tweenedValue];
}

@end
