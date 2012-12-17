#import "_CPTAnimationCGSizePeriod.h"

@implementation _CPTAnimationCGSizePeriod

-(NSValue *)tweenedValueForProgress:(CGFloat)progress
{
    CGSize start;
    CGSize end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    CGFloat tweenedWidth  = start.width + progress * (end.width - start.width);
    CGFloat tweenedHeight = start.height + progress * (end.height - start.height);

    CGSize tweenedSize = CGSizeMake(tweenedWidth, tweenedHeight);

    return [NSValue valueWithBytes:&tweenedSize objCType:@encode(CGSize)];
}

@end
