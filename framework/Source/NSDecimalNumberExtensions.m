

#import "NSDecimalNumberExtensions.h"


@implementation NSDecimalNumber (CPExtensions)

+(NSDecimalNumber *)decimalNumberWithNumber:(NSNumber *)number
{
    return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
}

-(CGFloat)floatValue 
{
    return (CGFloat)[self doubleValue];
}

@end
