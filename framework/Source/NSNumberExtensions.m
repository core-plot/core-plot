

#import "NSNumberExtensions.h"


@implementation NSNumber (CPExtensions)

-(NSDecimalNumber *)decimalNumber
{
    if ([self isMemberOfClass:[NSDecimalNumber class]]) {
        return (NSDecimalNumber *)self;
    }
    return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}

@end
