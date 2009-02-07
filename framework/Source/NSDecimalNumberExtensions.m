

#import "NSDecimalNumberExtensions.h"


@implementation NSDecimalNumber (CPExtensions)

-(CGFloat)floatValue 
{
    return (CGFloat)[self doubleValue];
}

@end
