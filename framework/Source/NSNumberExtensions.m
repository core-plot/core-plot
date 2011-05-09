#import "NSNumberExtensions.h"

@implementation NSNumber(CPTExtensions)

/**	@brief Returns the value of the receiver as an NSDecimalNumber.
 *	@return The value of the receiver as an NSDecimalNumber.
 **/
-(NSDecimalNumber *)decimalNumber
{
    if ([self isMemberOfClass:[NSDecimalNumber class]]) {
        return (NSDecimalNumber *)self;
    }
    return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}

@end
