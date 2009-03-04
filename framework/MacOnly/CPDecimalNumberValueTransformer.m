

#import "CPDecimalNumberValueTransformer.h"
#import "NSDecimalNumberExtensions.h"

@implementation CPDecimalNumberValueTransformer

+(BOOL)allowsReverseTransformation 
{
    return YES;
}

+(Class)transformedValueClass 
{
    return [NSNumber class];
}

-(id)transformedValue:(id)value {
    return [[value copy] autorelease];
}

-(id)reverseTransformedValue:(id)value {
    return [NSDecimalNumber decimalNumberWithNumber:value];
}

@end
