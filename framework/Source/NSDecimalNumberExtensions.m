#import "NSDecimalNumberExtensions.h"

@implementation NSDecimalNumber(CPTExtensions)

/** @brief Returns the value of the receiver as an NSDecimalNumber.
 *  @return The value of the receiver as an NSDecimalNumber.
 **/
-(NSDecimalNumber *)decimalNumber
{
    return [[self copy] autorelease];
}

@end
