

#import "NSDecimalNumberExtensions.h"


@implementation NSDecimalNumber (CPExtensions)

-(CGFloat)floatValue 
{
    return (CGFloat)[self doubleValue];
}

-(NSDecimalNumber *)decimalNumber
{
    return [[self copy] autorelease];
}

@end
