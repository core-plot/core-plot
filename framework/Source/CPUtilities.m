
#import "CPUtilities.h"

CPInteger CPDecimalIntegerValue(NSDecimal dec)
{
	return (CPInteger)[[NSDecimalNumber decimalNumberWithDecimal:dec] intValue]; 
}

CPFloat CPDecimalFloatValue(NSDecimal dec)
{
	return (CPFloat)[[NSDecimalNumber decimalNumberWithDecimal:dec] floatValue]; 
}

CPDouble CPDecimalDoubleValue(NSDecimal dec)
{
	return (CPDouble)[[NSDecimalNumber decimalNumberWithDecimal:dec] doubleValue]; 
}

NSDecimal CPDecimalFromInt(CPInteger i)
{
	return [[NSNumber numberWithInt:i] decimalValue]; 
}

NSDecimal CPDecimalFromFloat(CPFloat f)
{
	return [[NSNumber numberWithFloat:f] decimalValue]; 
}

NSDecimal CPDecimalFromDouble(CPDouble d)
{
	return [[NSNumber numberWithDouble:d] decimalValue]; 
}

CPPlotRange* CPMakePlotRange(CPDouble location, CPDouble length)
/*"
** This method is simply a convenience function call to the class method
** +plotRangeWithDoubleLocation:andLength:. It returns an autoreleased
** CPPlotRange instance that you are going to need to retain if you want
** to keep this guy around.
"*/
{
    return [CPPlotRange plotRangeWithDoubleLocation:location andLength:length];
}