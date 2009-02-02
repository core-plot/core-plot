
#import "CPUtilities.h"

int NSDecimalIntValue(NSDecimal dec)
{
	return [[NSDecimalNumber decimalNumberWithDecimal:dec] intValue]; 
}

CGFloat NSDecimalFloatValue(NSDecimal dec)
{
	return [[NSDecimalNumber decimalNumberWithDecimal:dec] floatValue]; 
}

double NSDecimalDoubleValue(NSDecimal dec)
{
	return [[NSDecimalNumber decimalNumberWithDecimal:dec] doubleValue]; 
}

NSDecimal NSDecimalFromInt(int i)
{
	return [[NSNumber numberWithInt:i] decimalValue]; 
}

NSDecimal NSDecimalFromFloat(CGFloat f)
{
	return [[NSNumber numberWithFloat:f] decimalValue]; 
}

NSDecimal NSDecimalFromDouble(double d)
{
	return [[NSNumber numberWithDouble:d] decimalValue]; 
}
