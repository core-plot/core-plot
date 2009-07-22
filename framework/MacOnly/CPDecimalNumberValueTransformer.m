

#import "CPDecimalNumberValueTransformer.h"
#import "NSNumberExtensions.h"

/**	@brief A Cocoa Bindings value transformer for NSDecimalNumber objects.
 **/
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
    return [value decimalNumber];
}

@end
