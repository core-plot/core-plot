#import "CPTDecimalNumberValueTransformer.h"
#import "NSNumberExtensions.h"

/**
 *  @brief A Cocoa Bindings value transformer for NSDecimalNumber objects.
 **/
@implementation CPTDecimalNumberValueTransformer

/**
 *  @brief Indicates that the receiver can reverse a transformation.
 *  @return @YES, the transformation is reversible.
 **/
+(BOOL)allowsReverseTransformation
{
    return YES;
}

/**
 *  @brief The class of the value returned for a forward transformation.
 *  @return Transformed values will be instances of NSNumber.
 **/
+(Class)transformedValueClass
{
    return [NSNumber class];
}

/// @cond

-(id)transformedValue:(id)value
{
    return [[value copy] autorelease];
}

-(id)reverseTransformedValue:(id)value
{
    return [value decimalNumber];
}

/// @endcond

@end
