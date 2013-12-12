#import "_CPTAnimationPlotRangePeriod.h"

#import "CPTPlotRange.h"
#import "CPTUtilities.h"

@implementation _CPTAnimationPlotRangePeriod

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    IMP getterMethod = [boundObject methodForSelector:boundGetter];

    self.startValue = getterMethod(boundObject, boundGetter);
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    IMP getterMethod = [boundObject methodForSelector:boundGetter];

    CPTPlotRange *current = getterMethod(boundObject, boundGetter);
    CPTPlotRange *start   = (CPTPlotRange *)self.startValue;
    CPTPlotRange *end     = (CPTPlotRange *)self.endValue;

    NSDecimal currentLoc = current.location;
    NSDecimal startLoc   = start.location;
    NSDecimal endLoc     = end.location;

    return ( CPTDecimalGreaterThanOrEqualTo(currentLoc, startLoc) && CPTDecimalLessThanOrEqualTo(currentLoc, endLoc) ) ||
           ( CPTDecimalGreaterThanOrEqualTo(currentLoc, endLoc) && CPTDecimalLessThanOrEqualTo(currentLoc, startLoc) );
}

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
