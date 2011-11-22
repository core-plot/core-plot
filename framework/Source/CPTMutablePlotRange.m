#import "CPTMutablePlotRange.h"

#import "CPTUtilities.h"

/** @brief Defines a mutable range of plot data.
 *
 *  If you need to change the plot range, you should use this class rather than the
 *  immutable super class.
 *
 **/
@implementation CPTMutablePlotRange

/** @property location
 *  @brief The starting value of the range.
 **/
@dynamic location;

/** @property length
 *  @brief The length of the range.
 **/
@dynamic length;

#pragma mark -
#pragma mark Combining ranges

/** @brief Extends the range to include another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)unionPlotRange:(CPTPlotRange *)other
{
	if ( !other ) {
		return;
	}

	NSDecimal min1	  = self.minLimit;
	NSDecimal min2	  = other.minLimit;
	NSDecimal minimum = CPTDecimalLessThan(min1, min2) ? min1 : min2;

	NSDecimal max1	  = self.maxLimit;
	NSDecimal max2	  = other.maxLimit;
	NSDecimal maximum = CPTDecimalGreaterThan(max1, max2) ? max1 : max2;

	NSDecimal newLocation, newLength;
	if ( CPTDecimalGreaterThanOrEqualTo( self.length, CPTDecimalFromInteger(0) ) ) {
		newLocation = minimum;
		newLength	= CPTDecimalSubtract(maximum, minimum);
	}
	else {
		newLocation = maximum;
		newLength	= CPTDecimalSubtract(minimum, maximum);
	}

	self.location = newLocation;
	self.length	  = newLength;
}

/** @brief Sets the messaged object to the intersection with another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)intersectionPlotRange:(CPTPlotRange *)other
{
	if ( !other ) {
		return;
	}

	NSDecimal min1	  = self.minLimit;
	NSDecimal min2	  = other.minLimit;
	NSDecimal minimum = CPTDecimalGreaterThan(min1, min2) ? min1 : min2;

	NSDecimal max1	  = self.maxLimit;
	NSDecimal max2	  = other.maxLimit;
	NSDecimal maximum = CPTDecimalLessThan(max1, max2) ? max1 : max2;

	if ( CPTDecimalGreaterThanOrEqualTo(maximum, minimum) ) {
		NSDecimal newLocation, newLength;
		if ( CPTDecimalGreaterThanOrEqualTo( self.length, CPTDecimalFromInteger(0) ) ) {
			newLocation = minimum;
			newLength	= CPTDecimalSubtract(maximum, minimum);
		}
		else {
			newLocation = maximum;
			newLength	= CPTDecimalSubtract(minimum, maximum);
		}

		self.location = newLocation;
		self.length	  = newLength;
	}
	else {
		self.length = CPTDecimalFromInteger(0);
	}
}

#pragma mark -
#pragma mark Expanding/Contracting ranges

/** @brief Extends/contracts the range by a factor.
 *  @param factor Factor used. A value of 1.0 gives no change.
 *	Less than 1.0 is a contraction, and greater than 1.0 is expansion.
 **/
-(void)expandRangeByFactor:(NSDecimal)factor
{
	NSDecimal oldLength		 = self.length;
	NSDecimal newLength		 = CPTDecimalMultiply(oldLength, factor);
	NSDecimal locationOffset = CPTDecimalDivide( CPTDecimalSubtract(oldLength, newLength), CPTDecimalFromInteger(2) );
	NSDecimal newLocation	 = CPTDecimalAdd(self.location, locationOffset);

	self.location = newLocation;
	self.length	  = newLength;
}

#pragma mark -
#pragma mark Shifting Range

/** @brief Moves the whole range so that the location fits in other range.
 *  @param otherRange Other range.
 *	The minimum possible shift is made. The range length is unchanged.
 **/
-(void)shiftLocationToFitInRange:(CPTPlotRange *)otherRange
{
	NSParameterAssert(otherRange);

	switch ( [otherRange compareToNumber:[NSDecimalNumber decimalNumberWithDecimal:self.location]] ) {
		case CPTPlotRangeComparisonResultNumberBelowRange:
			self.location = otherRange.minLimit;
			break;

		case CPTPlotRangeComparisonResultNumberAboveRange:
			self.location = otherRange.maxLimit;
			break;

		default:
			// in range--do nothing
			break;
	}
}

/** @brief Moves the whole range so that the end point fits in other range.
 *  @param otherRange Other range.
 *	The minimum possible shift is made. The range length is unchanged.
 **/
-(void)shiftEndToFitInRange:(CPTPlotRange *)otherRange
{
	NSParameterAssert(otherRange);

	switch ( [otherRange compareToNumber:[NSDecimalNumber decimalNumberWithDecimal:self.end]] ) {
		case CPTPlotRangeComparisonResultNumberBelowRange:
			self.location = CPTDecimalSubtract(otherRange.minLimit, self.length);
			break;

		case CPTPlotRangeComparisonResultNumberAboveRange:
			self.location = CPTDecimalSubtract(otherRange.maxLimit, self.length);
			break;

		default:
			// in range--do nothing
			break;
	}
}

@end
