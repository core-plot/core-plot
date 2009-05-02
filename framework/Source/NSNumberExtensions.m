

#import "NSNumberExtensions.h"


@implementation NSNumber (CPExtensions)

-(NSDecimalNumber *)decimalNumber
{
    return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}

@end
