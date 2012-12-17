#import "_CPTAnimationCGFloatPeriod.h"

#import "NSNumberExtensions.h"

@implementation _CPTAnimationCGFloatPeriod

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
