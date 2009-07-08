
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

#pragma mark -
#pragma mark Quartz pixel-alignment functions

CGPoint alignPointToUserSpace(CGContextRef context, CGPoint p)
{
    // Compute the coordinates of the point in device space.
    p = CGContextConvertPointToDeviceSpace(context, p);
    // Ensure that coordinates are at exactly the corner
    // of a device pixel.
    p.x = floor(p.x);
    p.y = floor(p.y);
    // Convert the device aligned coordinate back to user space.
    return CGContextConvertPointToUserSpace(context, p);
}

CGSize alignSizeToUserSpace(CGContextRef context, CGSize s)
{
    // Compute the size in device space.
    s = CGContextConvertSizeToDeviceSpace(context, s);
    // Ensure that size is an integer multiple of device pixels.
    s.width = floor(s.width);
    s.height = floor(s.height);
    // Convert back to user space.
    return CGContextConvertSizeToUserSpace(context, s);
}

CGRect alignRectToUserSpace(CGContextRef context, CGRect r)
{
    // Compute the coordinates of the rectangle in device space.
    r = CGContextConvertRectToDeviceSpace(context, r);
    // Ensure that the x and y coordinates are at a pixel corner.
    r.origin.x = floor(r.origin.x);
    r.origin.y = floor(r.origin.y);
    // Ensure that the width and height are an integer number of
    // device pixels. Note that this produces a width and height
    // that is less than or equal to the original width. Another
    // approach is to use ceil to ensure that the new rectangle
    // encloses the original one.
    r.size.width = floor(r.size.width);
    r.size.height = floor(r.size.height);
    
    // Convert back to user space.
    return CGContextConvertRectToUserSpace(context, r);
}
