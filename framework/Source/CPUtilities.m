
#import "CPUtilities.h"

#pragma mark -
#pragma mark Decimal Numbers

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

#pragma mark -
#pragma mark Ranges

NSRange CPExpandedRange(NSRange range, NSInteger expandBy) 
{
    NSInteger loc = MAX(0, (int)range.location - expandBy);
    NSInteger lowerExpansion = range.location - loc;
    NSInteger length = range.length + lowerExpansion + expandBy;
    return NSMakeRange(loc, length);
}

#pragma mark -
#pragma mark Colors

CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor)
{
    NSColor *rgbColor = [nsColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    CGFloat r, g, b, a;
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    return CGColorCreateGenericRGB(r, g, b, a);
}