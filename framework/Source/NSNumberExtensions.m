#import "NSNumberExtensions.h"

@implementation NSNumber(CPTExtensions)

/**	@brief Creates and returns an NSNumber object containing a given value, treating it as a CGFloat.
 *	@param number The value for the new number.
 *	@return An NSNumber object containing value, treating it as a CGFloat.
 **/
+(NSNumber *)numberWithCGFloat:(CGFloat)number
{
#if CGFLOAT_IS_DOUBLE
	return [NSNumber numberWithDouble:number];

#else
	return [NSNumber numberWithFloat:number];
#endif
}

/**	@brief Returns the value of the receiver as a CGFloat.
 *	@return The value of the receiver as a CGFloat.
 **/
-(CGFloat)cgFloatValue
{
#if CGFLOAT_IS_DOUBLE
	return [self doubleValue];

#else
	return [self floatValue];
#endif
}

/**	@brief Returns an NSNumber object initialized to contain a given value, treated as a CGFloat.
 *	@param number The value for the new number.
 *	@return An NSNumber object containing value, treating it as a CGFloat.
 **/
-(id)initWithCGFloat:(CGFloat)number
{
#if CGFLOAT_IS_DOUBLE
	return [self initWithDouble:number];

#else
	return [self initWithFloat:number];
#endif
}

/**	@brief Returns the value of the receiver as an NSDecimalNumber.
 *	@return The value of the receiver as an NSDecimalNumber.
 **/
-(NSDecimalNumber *)decimalNumber
{
	if ( [self isMemberOfClass:[NSDecimalNumber class]] ) {
		return (NSDecimalNumber *)self;
	}
	return [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
}

@end
