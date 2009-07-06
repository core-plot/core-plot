
#import "CPUtilities.h"

#pragma mark -
#pragma mark Decimal Numbers

/**
 *	@brief Converts an NSDecimal value to a CPInteger.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
CPInteger CPDecimalIntegerValue(NSDecimal decimalNumber)
{
	return (CPInteger)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] intValue]; 
}

/**
 *	@brief Converts an NSDecimal value to a CPFloat.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
CPFloat CPDecimalFloatValue(NSDecimal decimalNumber)
{
	return (CPFloat)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] floatValue]; 
}

/**
 *	@brief Converts an NSDecimal value to a CPDouble.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
CPDouble CPDecimalDoubleValue(NSDecimal decimalNumber)
{
	return (CPDouble)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] doubleValue]; 
}

/**
 *	@brief Converts a CPInteger value to an NSDecimal.
 *	@param i The CPInteger value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromInt(CPInteger i)
{
	return [[NSNumber numberWithInt:i] decimalValue]; 
}

/**
 *	@brief Converts a CPFloat value to an NSDecimal.
 *	@param f The CPFloat value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromFloat(CPFloat f)
{
	return [[NSNumber numberWithFloat:f] decimalValue]; 
}

/**
 *	@brief Converts a CPDouble value to an NSDecimal.
 *	@param d The CPDouble value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromDouble(CPDouble d)
{
	return [[NSNumber numberWithDouble:d] decimalValue]; 
}

#pragma mark -
#pragma mark Ranges

/**
 *	@brief Expands an NSRange by the given amount.
 *
 *	The <tt>location</tt> of the resulting NSRange will be non-negative.
 *
 *	@param range The NSRange to expand.
 *	@param expandBy The amount the expand the range by.
 *	@return The expanded range.
 **/
NSRange CPExpandedRange(NSRange range, NSInteger expandBy) 
{
    NSInteger loc = MAX(0, (int)range.location - expandBy);
    NSInteger lowerExpansion = range.location - loc;
    NSInteger length = range.length + lowerExpansion + expandBy;
    return NSMakeRange(loc, length);
}

#pragma mark -
#pragma mark Colors

/**
 *	@brief Extracts the color information from a CGColorRef and returns it as a CPRGBAColor.
 *
 *	Supports RGBA and grayscale colorspaces.
 *
 *	@param color The color.
 *	@return The RGBA components of the color.
 **/
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

/**
 *	@brief Determines the CPCoordinate that is orthogonal to the one provided.
 *
 *	The current implementation is two-dimensional--X is orthogonal to Y and Y is orthogonal to X.
 *
 *	@param coord The CPCoordinate.
 *	@return The orthogonal CPCoordinate.
 **/
CPCoordinate OrthogonalCoordinate(CPCoordinate coord)
{
	return ( coord == CPCoordinateX ? CPCoordinateY : CPCoordinateX );
}