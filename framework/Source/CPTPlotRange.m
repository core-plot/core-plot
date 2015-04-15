#import "CPTPlotRange.h"

#import "CPTMutablePlotRange.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"

/// @cond
@interface CPTPlotRange()

@property (nonatomic, readwrite) NSDecimal location;
@property (nonatomic, readwrite) NSDecimal length;
@property (nonatomic, readwrite) double locationDouble;
@property (nonatomic, readwrite) double lengthDouble;

@end

/// @endcond

/**
 *  @brief Defines an immutable range of plot data.
 **/
@implementation CPTPlotRange

/** @property NSDecimal location
 *  @brief The starting value of the range.
 *  @see locationDouble
 **/
@synthesize location;

/** @property NSDecimal length
 *  @brief The length of the range.
 *  @see lengthDouble
 **/
@synthesize length;

/** @property NSDecimal end;
 *  @brief The ending value of the range, equivalent to @ref location + @ref length.
 **/
@dynamic end;

/** @property double locationDouble
 *  @brief The starting value of the range as a @double.
 *  @see location
 **/
@synthesize locationDouble;

/** @property double lengthDouble
 *  @brief The length of the range as a @double.
 *  @see length
 **/
@synthesize lengthDouble;

/** @property double endDouble
 *  @brief The ending value of the range as a @double, equivalent to @ref locationDouble + @ref lengthDouble.
 **/
@dynamic endDouble;

/** @property NSDecimal minLimit
 *  @brief The minimum extreme value of the range.
 **/
@dynamic minLimit;

/** @property double minLimitDouble
 *  @brief The minimum extreme value of the range as a @double.
 **/
@dynamic minLimitDouble;

/** @property NSDecimal midPoint
 *  @brief The middle value of the range.
 **/
@dynamic midPoint;

/** @property double midPointDouble
 *  @brief The middle value of the range as a @double.
 **/
@dynamic midPointDouble;

/** @property NSDecimal maxLimit
 *  @brief The maximum extreme value of the range.
 **/
@dynamic maxLimit;

/** @property double maxLimitDouble
 *  @brief The maximum extreme value of the range as a @double.
 **/
@dynamic maxLimitDouble;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPTPlotRange instance initialized with the provided location and length.
 **/
+(instancetype)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
    return [[self alloc] initWithLocation:loc length:len];
}

/** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPTPlotRange object.
 **/
-(instancetype)initWithLocation:(NSDecimal)loc length:(NSDecimal)len
{
    if ( (self = [super init]) ) {
        self.location = loc;
        self.length   = len;
    }
    return self;
}

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotRange object.
 *
 *  The initialized object will have the following properties:
 *  - @ref location = @num{0.0}
 *  - @ref length = @num{0.0}
 *
 *  @return The initialized object.
 **/
-(instancetype)init
{
    NSDecimal zero = CPTDecimalFromInteger(0);

    return [self initWithLocation:zero length:zero];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setLocation:(NSDecimal)newLocation
{
    if ( !CPTDecimalEquals(location, newLocation) ) {
        location            = newLocation;
        self.locationDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLocation] doubleValue];
    }
}

-(void)setLength:(NSDecimal)newLength
{
    if ( !CPTDecimalEquals(length, newLength) ) {
        length            = newLength;
        self.lengthDouble = [[NSDecimalNumber decimalNumberWithDecimal:newLength] doubleValue];
    }
}

-(NSDecimal)end
{
    return CPTDecimalAdd(self.location, self.length);
}

-(double)endDouble
{
    return self.locationDouble + self.lengthDouble;
}

-(NSDecimal)minLimit
{
    NSDecimal loc = self.location;
    NSDecimal len = self.length;

    if ( CPTDecimalLessThan( len, CPTDecimalFromInteger(0) ) ) {
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
    return CPTDecimalAdd( self.location, CPTDecimalDivide( self.length, CPTDecimalFromInteger(2) ) );
}

-(double)midPointDouble
{
    return fma(self.lengthDouble, 0.5, self.locationDouble);
}

-(NSDecimal)maxLimit
{
    NSDecimal loc = self.location;
    NSDecimal len = self.length;

    if ( CPTDecimalGreaterThan( len, CPTDecimalFromInteger(0) ) ) {
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

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTPlotRange *newRange = [[CPTPlotRange allocWithZone:zone] init];

    if ( newRange ) {
        newRange.location       = self.location;
        newRange.length         = self.length;
        newRange.locationDouble = self.locationDouble;
        newRange.lengthDouble   = self.lengthDouble;
    }
    return newRange;
}

/// @endcond

#pragma mark -
#pragma mark NSMutableCopying Methods

/// @cond

-(id)mutableCopyWithZone:(NSZone *)zone
{
    CPTPlotRange *newRange = [[CPTMutablePlotRange allocWithZone:zone] init];

    if ( newRange ) {
        newRange.location       = self.location;
        newRange.length         = self.length;
        newRange.locationDouble = self.locationDouble;
        newRange.lengthDouble   = self.lengthDouble;
    }
    return newRange;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDecimal:self.location forKey:@"CPTPlotRange.location"];
    [encoder encodeDecimal:self.length forKey:@"CPTPlotRange.length"];
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param decoder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(instancetype)initWithCoder:(NSCoder *)decoder
{
    if ( (self = [super init]) ) {
        self.location = [decoder decodeDecimalForKey:@"CPTPlotRange.location"];
        self.length   = [decoder decodeDecimalForKey:@"CPTPlotRange.length"];
    }

    return self;
}

#pragma mark -
#pragma mark Checking Containership

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
 **/
-(BOOL)contains:(NSDecimal)number
{
    return CPTDecimalGreaterThanOrEqualTo(number, self.minLimit) && CPTDecimalLessThanOrEqualTo(number, self.maxLimit);
}

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return @YES if @ref locationDouble ≤ @par{number} ≤ @ref endDouble.
 **/
-(BOOL)containsDouble:(double)number
{
    return (number >= self.minLimitDouble) && (number <= self.maxLimitDouble);
}

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
 **/
-(BOOL)containsNumber:(NSNumber *)number
{
    if ( [number isKindOfClass:[NSDecimalNumber class]] ) {
        NSDecimal numericValue = number.decimalValue;
        return CPTDecimalGreaterThanOrEqualTo(numericValue, self.minLimit) && CPTDecimalLessThanOrEqualTo(numericValue, self.maxLimit);
    }
    else {
        double numericValue = number.doubleValue;
        return (numericValue >= self.minLimitDouble) && (numericValue <= self.maxLimitDouble);
    }
}

/** @brief Determines whether a given range is equal to the range of the receiver.
 *  @param otherRange The range to check.
 *  @return @YES if the ranges both have the same location and length.
 **/
-(BOOL)isEqualToRange:(CPTPlotRange *)otherRange
{
    if ( otherRange ) {
        return CPTDecimalEquals(self.location, otherRange.location) && CPTDecimalEquals(self.length, otherRange.length);
    }
    else {
        return NO;
    }
}

/** @brief Determines whether the receiver entirely contains another range.
 *  @param otherRange The range to check.
 *  @return @YES if the other range fits entirely within the range of the receiver.
 **/
-(BOOL)containsRange:(CPTPlotRange *)otherRange
{
    if ( otherRange ) {
        return CPTDecimalGreaterThanOrEqualTo(otherRange.minLimit, self.minLimit) && CPTDecimalLessThanOrEqualTo(otherRange.maxLimit, self.maxLimit);
    }
    else {
        return NO;
    }
}

/** @brief Determines whether a given range intersects the receiver.
 *  @param otherRange The range to check.
 *  @return @YES if the ranges intersect.
 **/
-(BOOL)intersectsRange:(CPTPlotRange *)otherRange
{
    if ( !otherRange ) {
        return NO;
    }

    NSDecimal min1    = self.minLimit;
    NSDecimal min2    = otherRange.minLimit;
    NSDecimal minimum = CPTDecimalGreaterThan(min1, min2) ? min1 : min2;

    NSDecimal max1    = self.maxLimit;
    NSDecimal max2    = otherRange.maxLimit;
    NSDecimal maximum = CPTDecimalLessThan(max1, max2) ? max1 : max2;

    return CPTDecimalGreaterThanOrEqualTo(maximum, minimum);
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
#pragma mark Label comparison

/// @cond

-(BOOL)isEqual:(id)object
{
    if ( self == object ) {
        return YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        return [self isEqualToRange:object];
    }
    else {
        return NO;
    }
}

-(NSUInteger)hash
{
    NSDecimalNumber *locationNumber = [NSDecimalNumber decimalNumberWithDecimal:self.location];
    NSDecimalNumber *lengthNumber   = [NSDecimalNumber decimalNumberWithDecimal:self.length];

    return locationNumber.hash + lengthNumber.hash;
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(NSString *)description
{
    NSDecimal myLocation = self.location;
    NSDecimal myLength   = self.length;

    return [NSString stringWithFormat:@"<%@ {%@, %@}>",
            [super description],
            NSDecimalString(&myLocation, [NSLocale currentLocale]),
            NSDecimalString(&myLength, [NSLocale currentLocale])];
}

/// @endcond

@end
