
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

#pragma mark -
#pragma mark Quartz pixel-alignment functions

/**
 *	@brief Aligns a point in user space to integral coordinates in device space.
 *
 *	Ensures that the x and y coordinates are at a pixel corner in device space.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param p The point in user space.
 *	@return The device aligned point in user space.
 **/
CGPoint alignPointToUserSpace(CGContextRef context, CGPoint p)
{
    // Compute the coordinates of the point in device space.
    p = CGContextConvertPointToDeviceSpace(context, p);
    // Ensure that coordinates are at exactly the corner
    // of a device pixel.
    p.x = round(p.x) + 0.5f;
    p.y = round(p.y) + 0.5f;
    // Convert the device aligned coordinate back to user space.
    return CGContextConvertPointToUserSpace(context, p);
}

/**
 *	@brief Adjusts a size in user space to integral dimensions in device space.
 *
 *	Ensures that the width and height are an integer number of device pixels.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param s The size in user space.
 *	@return The device aligned size in user space.
 **/
CGSize alignSizeToUserSpace(CGContextRef context, CGSize s)
{
    // Compute the size in device space.
    s = CGContextConvertSizeToDeviceSpace(context, s);
    // Ensure that size is an integer multiple of device pixels.
    s.width = round(s.width);
    s.height = round(s.height);
    // Convert back to user space.
    return CGContextConvertSizeToUserSpace(context, s);
}

/**
 *	@brief Aligns a rectangle in user space to integral coordinates in device space.
 *
 *	Ensures that the x and y coordinates are at a pixel corner in device space
 *	and the width and height are an integer number of device pixels.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@note This function produces a width and height
 *	that is less than or equal to the original width.
 *	@param context The graphics context.
 *	@param r The rectangle in user space.
 *	@return The device aligned rectangle in user space.
 **/
CGRect alignRectToUserSpace(CGContextRef context, CGRect r)
{
    // Compute the coordinates of the rectangle in device space.
    r = CGContextConvertRectToDeviceSpace(context, r);
    // Ensure that the x and y coordinates are at a pixel corner.
    r.origin.x = round(r.origin.x) + 0.5f;
    r.origin.y = round(r.origin.y) + 0.5f;
    // Ensure that the width and height are an integer number of
    // device pixels. We now use ceil to make something at least as large as the original
    r.size.width = round(r.size.width);
    r.size.height = round(r.size.height);
    
    // Convert back to user space.
    return CGContextConvertRectToUserSpace(context, r);
}
