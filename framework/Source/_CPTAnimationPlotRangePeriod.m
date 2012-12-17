#import "_CPTAnimationPlotRangePeriod.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"

@implementation _CPTAnimationPlotRangePeriod

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CPTPlotRange *start = (CPTPlotRange *)self.startValue;
    CPTPlotRange *end   = (CPTPlotRange *)self.endValue;

    NSDecimal progressDecimal = CPTDecimalFromCGFloat(progress);

    NSDecimal locationDiff    = CPTDecimalSubtract(end.location, start.location);
    NSDecimal tweenedLocation = CPTDecimalAdd( start.location, CPTDecimalMultiply(progressDecimal, locationDiff) );

    NSDecimal lengthDiff    = CPTDecimalSubtract(end.length, start.length);
    NSDecimal tweenedLength = CPTDecimalAdd( start.length, CPTDecimalMultiply(progressDecimal, lengthDiff) );

    return (NSValue *)[CPTPlotRange plotRangeWithLocation:tweenedLocation length:tweenedLength];
}

@end
