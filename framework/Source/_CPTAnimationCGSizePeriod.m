#import "_CPTAnimationCGSizePeriod.h"

/// @cond
@interface _CPTAnimationCGSizePeriod()

CGSize currentSizeValue(id boundObject, SEL boundGetter);

@end
/// @endcond

#pragma mark -

@implementation _CPTAnimationCGSizePeriod

CGSize currentSizeValue(id boundObject, SEL boundGetter)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

    [invocation setTarget:boundObject];
    [invocation setSelector:boundGetter];

    [invocation invoke];

    CGSize value;
    [invocation getReturnValue:&value];

    return value;
}

-(void)setStartValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGSize start = currentSizeValue(boundObject, boundGetter);

    self.startValue = [NSValue valueWithBytes:&start objCType:@encode(CGSize)];
}

-(BOOL)canStartWithValueFromObject:(id)boundObject propertyGetter:(SEL)boundGetter
{
    CGSize current = currentSizeValue(boundObject, boundGetter);
    CGSize start;
    CGSize end;

    [self.startValue getValue:&start];
    [self.endValue getValue:&end];

    return ( ( (current.width >= start.width) && (current.width <= end.width) ) || ( (current.width >= end.width) && (current.width <= start.width) ) ) &&
           ( ( (current.height >= start.height) && (current.height <= end.height) ) || ( (current.height >= end.height) && (current.height <= start.height) ) );
}

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
