#import "CPPlotRange.h"
#import "CPPlatformSpecificCategories.h"
#import "NSDecimalNumberExtensions.h"
#import "CPUtilities.h"
#import "CPDefinitions.h"

/** @brief Defines a range of plot data
 **/
@implementation CPPlotRange

/** @property location
 *  @brief The starting value of the range.
 **/
@synthesize location;

/** @property length
 *  @brief The length of the range.
 **/
@synthesize length;

/** @property locationDouble
 *  @brief The starting value of the range as a double.
 **/
@synthesize locationDouble;

/** @property lengthDouble
 *  @brief The length of the range as a double.
 **/
@synthesize lengthDouble;

/** @property end
 *  @brief The ending value of the range.
 **/
@dynamic end;

/** @property endDouble
 *  @brief The ending value of the range as a double.
 **/
@dynamic endDouble;

/** @property minLimit
 *  @brief The minimum extreme value of the range.
 **/
@dynamic minLimit;

/** @property minLimitDouble
 *  @brief The minimum extreme value of the range as a double.
 **/
@dynamic minLimitDouble;

/** @property maxLimit
 *  @brief The maximum extreme value of the range.
 **/
@dynamic maxLimit;

/** @property maxLimitDouble
 *  @brief The maximum extreme value of the range as a double.
 **/
@dynamic maxLimitDouble;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPPlotRange instance initialized with the provided location and length.
 **/
+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	return [[[CPPlotRange alloc] initWithLocation:loc length:len] autorelease];
}

/** @brief Initializes a newly allocated CPPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPPlotRange object.
 **/
-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	if ( self = [super init] ) {
    	self.location = loc;
        self.length = len;
	}
	return self;	
}

-(id)init
{
	NSDecimal zero = CPDecimalFromInteger(0);
	return [self initWithLocation:zero length:zero];
}

#pragma mark -
#pragma mark Accessors

-(void)setLocation:(NSDecimal)newLocation
{
	if ( !CPDecimalEquals(location, newLocation) ) {
		location = newLocation;
		locationDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLocation] doubleValue];
	}
}

-(void)setLength:(NSDecimal)newLength
{
	if ( !CPDecimalEquals(length, newLength) ) {
		length = newLength;
		lengthDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLength] doubleValue];
	}
}

-(NSDecimal)end 
{
    return CPDecimalAdd(self.location, self.length);
}

-(double)endDouble 
{
	return (self.locationDouble + self.lengthDouble);
}

-(NSDecimal)minLimit 
{
	NSDecimal loc = self.location;
	NSDecimal len = self.length;
	if ( CPDecimalLessThan(len, CPDecimalFromInteger(0)) ) {
		return CPDecimalAdd(loc, len);
	}
	else {
		return loc;
	}
}

-(double)minLimitDouble 
{
	double doubleLoc = self.locationDouble;
	double doubleLen = self.lengthDouble;
	if ( doubleLen < 0.0 ) {
		return doubleLoc + doubleLen;
	}
	else {
		return doubleLoc;
	}
}

-(NSDecimal)maxLimit 
{
	NSDecimal loc = self.location;
	NSDecimal len = self.length;
	if ( CPDecimalGreaterThan(len, CPDecimalFromInteger(0)) ) {
		return CPDecimalAdd(loc, len);
	}
	else {
		return loc;
	}
}

-(double)maxLimitDouble 
{
	double doubleLoc = self.locationDouble;
	double doubleLen = self.lengthDouble;
	if ( doubleLen > 0.0 ) {
		return doubleLoc + doubleLen;
	}
	else {
		return doubleLoc;
	}
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone 
{
    CPPlotRange *newRange = [[CPPlotRange allocWithZone:zone] init];
	if ( newRange ) {
		newRange->location = self->location;
		newRange->length = self->length;
		newRange->locationDouble = self->locationDouble;
		newRange->lengthDouble = self->lengthDouble;
	}
    return newRange;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:[NSDecimalNumber decimalNumberWithDecimal:self.location]];
    [encoder encodeObject:[NSDecimalNumber decimalNumberWithDecimal:self.length]];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ( self = [super init] ) {
        self.location = [[decoder decodeObject] decimalValue];
        self.length = [[decoder decodeObject] decimalValue];
    }
    
    return self;
}

#pragma mark -
#pragma mark Checking Containership

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return True if <code>location</code> ≤ <code>number</code> ≤ <code>end</code>.
 **/
-(BOOL)contains:(NSDecimal)number
{
	return (CPDecimalGreaterThanOrEqualTo(number, self.minLimit) && CPDecimalLessThanOrEqualTo(number, self.maxLimit));
}

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return True if <code>location</code> ≤ <code>number</code> ≤ <code>end</code>.
 **/
-(BOOL)containsDouble:(double)number
{
	return ((number >= self.minLimitDouble) && (number <= self.maxLimitDouble));
}

/** @brief Determines whether a given range is equal to the range of the receiver.
 *  @param otherRange The range to check.
 *  @return True if the ranges both have the same location and length.
 **/
-(BOOL)isEqualToRange:(CPPlotRange *)otherRange
{
	return (CPDecimalEquals(self.location, otherRange.location) && CPDecimalEquals(self.length, otherRange.length));
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPPlotRangeComparisonResult)compareToNumber:(NSNumber *)number
{
    CPPlotRangeComparisonResult result;
	if ( [number isKindOfClass:[NSDecimalNumber class]] ) {
		result = [self compareToDecimal:number.decimalValue];
    }
    else {
		result = [self compareToDouble:number.doubleValue];
    }
    return result;
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPPlotRangeComparisonResult)compareToDecimal:(NSDecimal)number
{
    CPPlotRangeComparisonResult result;
	if ( [self contains:number] ) {
		result = CPPlotRangeComparisonResultNumberInRange;
	}
	else if ( CPDecimalLessThan(number, self.minLimit) ) {
		result = CPPlotRangeComparisonResultNumberBelowRange;
	}
	else {
		result = CPPlotRangeComparisonResultNumberAboveRange;
	}
    return result;
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPPlotRangeComparisonResult)compareToDouble:(double)number
{
    CPPlotRangeComparisonResult result;
	if ( number < self.minLimitDouble ) {
		result = CPPlotRangeComparisonResultNumberBelowRange;
	}
	else if ( number > self.maxLimitDouble ) {
		result = CPPlotRangeComparisonResultNumberAboveRange;
	}
	else {
		result = CPPlotRangeComparisonResultNumberInRange;
	}
    return result;
}

#pragma mark -
#pragma mark Combining ranges

/** @brief Extends the range to include another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)unionPlotRange:(CPPlotRange *)other 
{
	NSParameterAssert(other);

	NSDecimal min1 = self.minLimit;
	NSDecimal min2 = other.minLimit;
	NSDecimal minimum = CPDecimalLessThan(min1, min2) ? min1 : min2;
	
	NSDecimal max1 = self.maxLimit;
	NSDecimal max2 = other.maxLimit;
	NSDecimal maximum = CPDecimalGreaterThan(max1, max2) ? max1 : max2;
	
	NSDecimal newLocation, newLength;
	if ( CPDecimalGreaterThanOrEqualTo(self.length, CPDecimalFromInteger(0)) ) {
		newLocation = minimum;
		newLength = CPDecimalSubtract(maximum, minimum);
	}
	else {
		newLocation = maximum;
		newLength = CPDecimalSubtract(minimum, maximum);
	}

    self.location = newLocation;
    self.length = newLength;
}

/** @brief Sets the messaged object to the intersection with another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)intersectionPlotRange:(CPPlotRange *)other
{
	NSParameterAssert(other);
	
	NSDecimal min1 = self.minLimit;
	NSDecimal min2 = other.minLimit;
	NSDecimal minimum = CPDecimalGreaterThan(min1, min2) ? min1 : min2;
	
	NSDecimal max1 = self.maxLimit;
	NSDecimal max2 = other.maxLimit;
	NSDecimal maximum = CPDecimalLessThan(max1, max2) ? max1 : max2;
	
	if ( CPDecimalGreaterThanOrEqualTo(maximum, minimum) ) {
		NSDecimal newLocation, newLength;
		if ( CPDecimalGreaterThanOrEqualTo(self.length, CPDecimalFromInteger(0)) ) {
			newLocation = minimum;
			newLength = CPDecimalSubtract(maximum, minimum);
		}
		else {
			newLocation = maximum;
			newLength = CPDecimalSubtract(minimum, maximum);
		}
		
		self.location = newLocation;
		self.length = newLength;
	}
	else {
		self.length = CPDecimalFromInteger(0);
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
	NSDecimal oldLength = self.length;
	NSDecimal newLength = CPDecimalMultiply(oldLength, factor);
	NSDecimal locationOffset = CPDecimalDivide(CPDecimalSubtract(oldLength, newLength), CPDecimalFromInteger(2));
	NSDecimal newLocation = CPDecimalAdd(self.location, locationOffset);

    self.location = newLocation;
    self.length = newLength;
}

#pragma mark -
#pragma mark Shifting Range

/** @brief Moves the whole range so that the location fits in other range.
 *  @param otherRange Other range.
 *	The minimum possible shift is made. The range length is unchanged.
 **/
-(void)shiftLocationToFitInRange:(CPPlotRange *)otherRange 
{
	NSParameterAssert(otherRange);
	
	switch ( [otherRange compareToNumber:[NSDecimalNumber decimalNumberWithDecimal:self.location]] ) {
		case CPPlotRangeComparisonResultNumberBelowRange:
			self.location = otherRange.minLimit;
			break;
		case CPPlotRangeComparisonResultNumberAboveRange:
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
-(void)shiftEndToFitInRange:(CPPlotRange *)otherRange
{
	NSParameterAssert(otherRange);

	switch ( [otherRange compareToNumber:[NSDecimalNumber decimalNumberWithDecimal:self.end]] ) {
		case CPPlotRangeComparisonResultNumberBelowRange:
			self.location = CPDecimalSubtract(otherRange.minLimit, self.length);
			break;
		case CPPlotRangeComparisonResultNumberAboveRange:
			self.location = CPDecimalSubtract(otherRange.maxLimit, self.length);
			break;
		default:
			// in range--do nothing
			break;
	}
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ {%@, %@}>",
			[super description],
			NSDecimalString(&location, [NSLocale currentLocale]),
			NSDecimalString(&length, [NSLocale currentLocale])]; 
}

@end
