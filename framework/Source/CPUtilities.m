
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

CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color)
{
	CPRGBAColor rgbColor;
	
	size_t numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 2) {
		const CGFloat *components = CGColorGetComponents(color);
		float all = components[0];
		rgbColor.red = all;
		rgbColor.green = all;
		rgbColor.blue = all;
		rgbColor.alpha = components[1];
	} else {
		const CGFloat *components = CGColorGetComponents(color);
		rgbColor.red = components[0];
		rgbColor.green = components[1];
		rgbColor.blue = components[2];
		rgbColor.alpha = components[3];
	}

	return rgbColor;
}

#pragma mark -
#pragma mark Coordinates

CPCoordinate OrthogonalCoordinate(CPCoordinate coord)
{
	return ( coord == CPCoordinateX ? CPCoordinateY : CPCoordinateX );
}