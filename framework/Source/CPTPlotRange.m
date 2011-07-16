#import "CPTPlotRange.h"
#import "CPTPlatformSpecificCategories.h"
#import "NSDecimalNumberExtensions.h"
#import "CPTUtilities.h"
#import "CPTDefinitions.h"
#import "NSCoderExtensions.h"

/** @brief Defines a range of plot data
 **/
@implementation CPTPlotRange

/** @property location
 *  @brief The starting value of the range.
 **/
@synthesize location;

/** @property length
 *  @brief The length of the range.
 **/
@synthesize length;

/** @property locationDouble
 *  @brief The starting value of the range as a <code>double</code>.
 **/
@synthesize locationDouble;

/** @property lengthDouble
 *  @brief The length of the range as a <code>double</code>.
 **/
@synthesize lengthDouble;

/** @property end
 *  @brief The ending value of the range.
 **/
@dynamic end;

/** @property endDouble
 *  @brief The ending value of the range as a <code>double</code>.
 **/
@dynamic endDouble;

/** @property minLimit
 *  @brief The minimum extreme value of the range.
 **/
@dynamic minLimit;

/** @property minLimitDouble
 *  @brief The minimum extreme value of the range as a <code>double</code>.
 **/
@dynamic minLimitDouble;

/** @property midPoint
 *  @brief The middle value of the range.
 **/
@dynamic midPoint;

/** @property midPointDouble
 *  @brief The middle value of the range as a <code>double</code>.
 **/
@dynamic midPointDouble;

/** @property maxLimit
 *  @brief The maximum extreme value of the range.
 **/
@dynamic maxLimit;

/** @property maxLimitDouble
 *  @brief The maximum extreme value of the range as a <code>double</code>.
 **/
@dynamic maxLimitDouble;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPTPlotRange instance initialized with the provided location and length.
 **/
+(CPTPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	return [[[CPTPlotRange alloc] initWithLocation:loc length:len] autorelease];
}

/** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPTPlotRange object.
 **/
-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
	if ( (self = [super init]) ) {
    	self.location = loc;
        self.length = len;
	}
	return self;	
}

-(id)init
{
	NSDecimal zero = CPTDecimalFromInteger(0);
	return [self initWithLocation:zero length:zero];
}

#pragma mark -
#pragma mark Accessors

-(void)setLocation:(NSDecimal)newLocation
{
	if ( !CPTDecimalEquals(location, newLocation) ) {
		location = newLocation;
		locationDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLocation] doubleValue];
	}
}

-(void)setLength:(NSDecimal)newLength
{
	if ( !CPTDecimalEquals(length, newLength) ) {
		length = newLength;
		lengthDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLength] doubleValue];
	}
}

-(NSDecimal)end 
{
    return CPTDecimalAdd(self.location, self.length);
}

-(double)endDouble 
{
	return (self.locationDouble + self.lengthDouble);
}

-(NSDecimal)minLimit 
{
	NSDecimal loc = self.location;
	NSDecimal len = self.length;
	if ( CPTDecimalLessThan(len, CPTDecimalFromInteger(0)) ) {
		return CPTDecimalAdd(loc, len);
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

-(NSDecimal)midPoint 
{
	return CPTDecimalAdd(self.location, CPTDecimalDivide(self.length, CPTDecimalFromInteger(2)));
}

-(double)midPointDouble 
{
	return fma(self.lengthDouble, 0.5, self.locationDouble);
}

-(NSDecimal)maxLimit 
{
	NSDecimal loc = self.location;
	NSDecimal len = self.length;
	if ( CPTDecimalGreaterThan(len, CPTDecimalFromInteger(0)) ) {
		return CPTDecimalAdd(loc, len);
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
    CPTPlotRange *newRange = [[CPTPlotRange allocWithZone:zone] init];
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
    [encoder encodeDecimal:self.location forKey:@"CPTPlotRange.location"];
    [encoder encodeDecimal:self.length forKey:@"CPTPlotRange.length"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ( (self = [super init]) ) {
        self.location = [decoder decodeDecimalForKey:@"CPTPlotRange.location"];
        self.length = [decoder decodeDecimalForKey:@"CPTPlotRange.length"];
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
	return (CPTDecimalGreaterThanOrEqualTo(number, self.minLimit) && CPTDecimalLessThanOrEqualTo(number, self.maxLimit));
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
-(BOOL)isEqualToRange:(CPTPlotRange *)otherRange
{
	return (CPTDecimalEquals(self.location, otherRange.location) && CPTDecimalEquals(self.length, otherRange.length));
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPTPlotRangeComparisonResult)compareToNumber:(NSNumber *)number
{
    CPTPlotRangeComparisonResult result;
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
-(CPTPlotRangeComparisonResult)compareToDecimal:(NSDecimal)number
{
    CPTPlotRangeComparisonResult result;
	if ( [self contains:number] ) {
		result = CPTPlotRangeComparisonResultNumberInRange;
	}
	else if ( CPTDecimalLessThan(number, self.minLimit) ) {
		result = CPTPlotRangeComparisonResultNumberBelowRange;
	}
	else {
		result = CPTPlotRangeComparisonResultNumberAboveRange;
	}
    return result;
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPTPlotRangeComparisonResult)compareToDouble:(double)number
{
    CPTPlotRangeComparisonResult result;
	if ( number < self.minLimitDouble ) {
		result = CPTPlotRangeComparisonResultNumberBelowRange;
	}
	else if ( number > self.maxLimitDouble ) {
		result = CPTPlotRangeComparisonResultNumberAboveRange;
	}
	else {
		result = CPTPlotRangeComparisonResultNumberInRange;
	}
    return result;
}

#pragma mark -
#pragma mark Combining ranges

/** @brief Extends the range to include another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)unionPlotRange:(CPTPlotRange *)other 
{
	if ( !other ) return;

	NSDecimal min1 = self.minLimit;
	NSDecimal min2 = other.minLimit;
	NSDecimal minimum = CPTDecimalLessThan(min1, min2) ? min1 : min2;
	
	NSDecimal max1 = self.maxLimit;
	NSDecimal max2 = other.maxLimit;
	NSDecimal maximum = CPTDecimalGreaterThan(max1, max2) ? max1 : max2;
	
	NSDecimal newLocation, newLength;
	if ( CPTDecimalGreaterThanOrEqualTo(self.length, CPTDecimalFromInteger(0)) ) {
		newLocation = minimum;
		newLength = CPTDecimalSubtract(maximum, minimum);
	}
	else {
		newLocation = maximum;
		newLength = CPTDecimalSubtract(minimum, maximum);
	}

    self.location = newLocation;
    self.length = newLength;
}

/** @brief Sets the messaged object to the intersection with another range. The sign of <code>length</code> is unchanged.
 *  @param other The other plot range.
 **/
-(void)intersectionPlotRange:(CPTPlotRange *)other
{
	if ( !other ) return;
	
	NSDecimal min1 = self.minLimit;
	NSDecimal min2 = other.minLimit;
	NSDecimal minimum = CPTDecimalGreaterThan(min1, min2) ? min1 : min2;
	
	NSDecimal max1 = self.maxLimit;
	NSDecimal max2 = other.maxLimit;
	NSDecimal maximum = CPTDecimalLessThan(max1, max2) ? max1 : max2;
	
	if ( CPTDecimalGreaterThanOrEqualTo(maximum, minimum) ) {
		NSDecimal newLocation, newLength;
		if ( CPTDecimalGreaterThanOrEqualTo(self.length, CPTDecimalFromInteger(0)) ) {
			newLocation = minimum;
			newLength = CPTDecimalSubtract(maximum, minimum);
		}
		else {
			newLocation = maximum;
			newLength = CPTDecimalSubtract(minimum, maximum);
		}
		
		self.location = newLocation;
		self.length = newLength;
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
	NSDecimal oldLength = self.length;
	NSDecimal newLength = CPTDecimalMultiply(oldLength, factor);
	NSDecimal locationOffset = CPTDecimalDivide(CPTDecimalSubtract(oldLength, newLength), CPTDecimalFromInteger(2));
	NSDecimal newLocation = CPTDecimalAdd(self.location, locationOffset);

    self.location = newLocation;
    self.length = newLength;
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
