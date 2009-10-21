
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

/** @property end
 *  @brief The ending value of the range.
 **/
@dynamic end;

/** @property doublePrecisionLocation
 *  @brief The starting value of the range, as a double.
 **/
@synthesize doublePrecisionLocation;

/** @property doublePrecisionLength
 *  @brief The length of the range, as a double.
 **/
@synthesize doublePrecisionLength;

/** @property doublePrecisionEnd
 *  @brief The ending value of the range, as a double.
 **/
@dynamic doublePrecisionEnd;

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
		location = loc;
		length = len;
	}
	return self;	
}

#pragma mark -
#pragma mark Accessors

-(void)setLocation:(NSDecimal)newLocation;
{
	if (CPDecimalEquals(location, newLocation))
	{
		return;
	}
	
	location = newLocation;
	doublePrecisionLocation = [[NSDecimalNumber decimalNumberWithDecimal:location] doubleValue];
}

-(void)setLength:(NSDecimal)newLength;
{
	if (CPDecimalEquals(length, newLength))
	{
		return;
	}
	
	length = newLength;
	doublePrecisionLength = [[NSDecimalNumber decimalNumberWithDecimal:length] doubleValue];
}

-(NSDecimal)end 
{
    return CPDecimalAdd(self.location, self.length);
}

-(double)doublePrecisionEnd 
{
	return (self.doublePrecisionLocation + self.doublePrecisionLength);
}

#pragma mark -
#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone 
{
    CPPlotRange *newRange = [[CPPlotRange allocWithZone:zone] init];
    newRange.location = self.location;
    newRange.length = self.length;
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
	self = [super init];
    
    if (self) {
        self.location = [[decoder decodeObject] decimalValue];
        self.length = [[decoder decodeObject] decimalValue];
    }
    
    return self;
}

#pragma mark -
#pragma mark Checking Containership

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return True if <tt>location</tt> ≤ <tt>number</tt> ≤ <tt>end</tt>.
 **/
-(BOOL)contains:(NSDecimal)number
{
	return (CPDecimalGreaterThanOrEqualTo(number, location) && CPDecimalLessThanOrEqualTo(number, self.end));
}

#pragma mark -
#pragma mark Combining ranges

/** @brief Extends the range to include another range.
 *  @param other The other plot range.
 **/
-(void)unionPlotRange:(CPPlotRange *)other 
{
    NSDecimal newLocation = (CPDecimalLessThan(self.location, other.location) ? self.location : other.location);
    NSDecimal max1 = CPDecimalAdd(self.location, self.length);
    NSDecimal max2 = CPDecimalAdd(other.location, other.length);
    NSDecimal max = (CPDecimalGreaterThan(max1, max2) ? max1 : max2);
    NSDecimal newLength = CPDecimalSubtract(max, newLocation);
    self.location = newLocation;
    self.length = newLength;
}

#pragma mark -
#pragma mark Expanding/Contracting ranges

/** @brief Extends/contracts the range by a factor.
 *  @param factor Factor used. A value of 1.0 gives no change.
 *	Less than 1.0 is a contraction, and greater than 1.0 is expansion.
 **/
-(void)expandRangeByFactor:(NSDecimal)factor {
    NSDecimal newLength = CPDecimalMultiply(length, factor);
    NSDecimal locationOffset = CPDecimalDivide( CPDecimalSubtract(newLength, length), 
    	CPDecimalFromInt(2));
    NSDecimal newLocation = CPDecimalSubtract(location, locationOffset);
    self.location = newLocation;
    self.length = newLength;
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"{%@, %@}", NSDecimalString(&location, [NSLocale currentLocale]), NSDecimalString(&length, [NSLocale currentLocale])]; 
}

@end
