#import "NSNumberExtensions.h"

/**	@brief Core Plot extensions to NSNumber.
 **/
@implementation NSNumber(CPExtensions)

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
