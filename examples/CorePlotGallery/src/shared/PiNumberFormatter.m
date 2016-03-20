#import "PiNumberFormatter.h"

double gcd(double a, double b);

/** @brief A number formatter that converts numbers to multiples of π.
**/
@implementation PiNumberFormatter

#pragma mark -
#pragma mark Formatting

/// @name Formatting
/// @{

/**
 *  @brief Converts a number into multiples of π. Use the @link NSNumberFormatter::multiplier multiplier @endlink to control the maximum fraction denominator.
 *  @param coordinateValue The numeric value.
 *  @return The formatted string.
 **/
-(nullable NSString *)stringForObjectValue:(nonnull id)coordinateValue
{
    NSString *string = nil;

    if ( [coordinateValue respondsToSelector:@selector(doubleValue)] ) {
        double value = ( (NSNumber *)coordinateValue ).doubleValue / M_PI;

        double factor = round(self.multiplier.doubleValue);
        if ( factor == 0.0 ) {
            factor = 1.0;
        }

        double numerator   = round(value * factor);
        double denominator = factor;
        double fraction    = numerator / denominator;
        double divisor     = ABS( gcd(numerator, denominator) );

        if ( fraction == 0.0 ) {
            string = @"0";
        }
        else if ( ABS(fraction) == 1.0 ) {
            string = [NSString stringWithFormat:@"%@π", signbit(fraction) ? self.minusSign : @""];
        }
        else if ( ABS(numerator) == 1.0 ) {
            string = [NSString stringWithFormat:@"%@π/%g", signbit(numerator) ? self.minusSign : @"", denominator];
        }
        else if ( ABS(numerator / divisor) == 1.0 ) {
            string = [NSString stringWithFormat:@"%@π/%g", signbit(numerator) ? self.minusSign : @"", denominator / divisor];
        }
        else if ( round(fraction) == fraction ) {
            string = [NSString stringWithFormat:@"%g π", fraction];
        }
        else if ( divisor != denominator ) {
            string = [NSString stringWithFormat:@"%g π/%g", numerator / divisor, denominator / divisor];
        }
        else {
            string = [NSString stringWithFormat:@"%g π/%g", numerator, denominator];
        }
    }

    return string;
}

/// @}

double gcd(double a, double b)
{
    double c;

    a = round(a);

    while ( a != 0.0 ) {
        c = a;
        a = round( fmod(b, a) );
        b = c;
    }

    return b;
}

@end
