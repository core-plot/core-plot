
#import "CPUtilities.h"

CGFloat NSDecimalFloatValue(NSDecimal dec)
{
	return [[NSDecimalNumber decimalNumberWithDecimal:dec] floatValue]; 
}