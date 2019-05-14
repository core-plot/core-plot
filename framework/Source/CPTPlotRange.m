#import "CPTPlotRange.h"

#import "CPTMutablePlotRange.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"

/// @cond
@interface CPTPlotRange()

@property (nonatomic, readwrite) NSDecimal locationDecimal;
@property (nonatomic, readwrite) NSDecimal lengthDecimal;
@property (nonatomic, readwrite) double locationDouble;
@property (nonatomic, readwrite) double lengthDouble;

@property (nonatomic, readwrite) BOOL inValueUpdate;

@end

/// @endcond

#pragma mark -

/**
 *  @brief Defines an immutable range of plot data.
 **/
@implementation CPTPlotRange

/** @property nonnull NSNumber *location
 *  @brief The starting value of the range.
 *  @see @ref locationDecimal, @ref locationDouble
 **/
@dynamic location;

/** @property nonnull NSNumber *length
 *  @brief The length of the range.
 *  @see @ref lengthDecimal, @ref lengthDouble
 **/
@dynamic length;

/** @property nonnull NSNumber *end;
 *  @brief The ending value of the range, equivalent to @ref location + @ref length.
 **/
@dynamic end;

/** @property NSDecimal locationDecimal
 *  @brief The starting value of the range.
 *  @see @ref location, @ref locationDouble
 **/
@synthesize locationDecimal;

/** @property NSDecimal lengthDecimal
 *  @brief The length of the range.
 *  @see @ref length, @ref lengthDouble
 **/
@synthesize lengthDecimal;

/** @property NSDecimal endDecimal;
 *  @brief The ending value of the range, equivalent to @ref locationDecimal + @ref lengthDecimal.
 **/
@dynamic endDecimal;

/** @property double locationDouble
 *  @brief The starting value of the range as a @double.
 *  @see @ref location, @ref locationDecimal
 **/
@synthesize locationDouble;

/** @property double lengthDouble
 *  @brief The length of the range as a @double.
 *  @see @ref length, @ref lengthDecimal
 **/
@synthesize lengthDouble;

/** @property double endDouble
 *  @brief The ending value of the range as a @double, equivalent to @ref locationDouble + @ref lengthDouble.
 **/
@dynamic endDouble;

/** @property nonnull NSNumber *minLimit
 *  @brief The minimum extreme value of the range.
 **/
@dynamic minLimit;

/** @property NSDecimal minLimitDecimal
 *  @brief The minimum extreme value of the range.
 **/
@dynamic minLimitDecimal;

/** @property double minLimitDouble
 *  @brief The minimum extreme value of the range as a @double.
 **/
@dynamic minLimitDouble;

/** @property nonnull NSNumber *midPoint
 *  @brief The middle value of the range.
 **/
@dynamic midPoint;

/** @property NSDecimal midPointDecimal
 *  @brief The middle value of the range.
 **/
@dynamic midPointDecimal;

/** @property double midPointDouble
 *  @brief The middle value of the range as a @double.
 **/
@dynamic midPointDouble;

/** @property nonnull NSNumber *maxLimit
 *  @brief The maximum extreme value of the range.
 **/
@dynamic maxLimit;

/** @property NSDecimal maxLimitDecimal
 *  @brief The maximum extreme value of the range.
 **/
@dynamic maxLimitDecimal;

/** @property double maxLimitDouble
 *  @brief The maximum extreme value of the range as a @double.
 **/
@dynamic maxLimitDouble;

@synthesize inValueUpdate;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPTPlotRange instance initialized with the provided location and length.
 **/
+(nonnull instancetype)plotRangeWithLocation:(nonnull NSNumber *)loc length:(nonnull NSNumber *)len
{
    return [[self alloc] initWithLocation:loc length:len];
}

/** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return A new CPTPlotRange instance initialized with the provided location and length.
 **/
+(nonnull instancetype)plotRangeWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len
{
    return [[self alloc] initWithLocationDecimal:loc lengthDecimal:len];
}

/** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPTPlotRange object.
 **/
-(nonnull instancetype)initWithLocation:(nonnull NSNumber *)loc length:(nonnull NSNumber *)len
{
    NSParameterAssert(loc);
    NSParameterAssert(len);

    return [self initWithLocationDecimal:loc.decimalValue
                           lengthDecimal:len.decimalValue];
}

/** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
 *  @param loc The starting location of the range.
 *  @param len The length of the range.
 *  @return The initialized CPTPlotRange object.
 **/
-(nonnull instancetype)initWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len
{
    if ( (self = [super init]) ) {
        self.locationDecimal = loc;
        self.lengthDecimal   = len;
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
-(nonnull instancetype)init
{
    return [self initWithLocation:@0.0 length:@0.0];
}

/// @}

#pragma mark -
#pragma mark Accessors

/// @cond

-(NSNumber *)location
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.locationDecimal];
}

-(void)setLocationDecimal:(NSDecimal)newLocation
{
    if ( !CPTDecimalEquals(locationDecimal, newLocation) ) {
        locationDecimal = newLocation;

        if ( !self.inValueUpdate ) {
            self.locationDouble = [NSDecimalNumber decimalNumberWithDecimal:newLocation].doubleValue;
        }
    }
}

-(void)setLocationDouble:(double)newLocation
{
    if ( locationDouble != newLocation ) {
        locationDouble = newLocation;

        if ( !self.inValueUpdate ) {
            self.locationDecimal = @(newLocation).decimalValue;
        }
    }
}

-(NSNumber *)length
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.lengthDecimal];
}

-(void)setLengthDecimal:(NSDecimal)newLength
{
    if ( !CPTDecimalEquals(lengthDecimal, newLength) ) {
        lengthDecimal = newLength;

        if ( !self.inValueUpdate ) {
            self.lengthDouble = [NSDecimalNumber decimalNumberWithDecimal:newLength].doubleValue;
        }
    }
}

-(void)setLengthDouble:(double)newLength
{
    if ( lengthDouble != newLength ) {
        lengthDouble = newLength;

        if ( !self.inValueUpdate ) {
            self.lengthDecimal = @(newLength).decimalValue;
        }
    }
}

-(NSNumber *)end
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.endDecimal];
}

-(NSDecimal)endDecimal
{
    return CPTDecimalAdd(self.locationDecimal, self.lengthDecimal);
}

-(double)endDouble
{
    return self.locationDouble + self.lengthDouble;
}

-(NSNumber *)minLimit
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.minLimitDecimal];
}

-(NSDecimal)minLimitDecimal
{
    NSDecimal loc = self.locationDecimal;
    NSDecimal len = self.lengthDecimal;

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

-(NSNumber *)midPoint
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.midPointDecimal];
}

-(NSDecimal)midPointDecimal
{
    return CPTDecimalAdd( self.locationDecimal, CPTDecimalDivide( self.lengthDecimal, CPTDecimalFromInteger(2) ) );
}

-(double)midPointDouble
{
    return fma(self.lengthDouble, 0.5, self.locationDouble);
}

-(NSNumber *)maxLimit
{
    return [NSDecimalNumber decimalNumberWithDecimal:self.maxLimitDecimal];
}

-(NSDecimal)maxLimitDecimal
{
    NSDecimal loc = self.locationDecimal;
    NSDecimal len = self.lengthDecimal;

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

-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
    CPTPlotRange *newRange = [[CPTPlotRange allocWithZone:zone] init];

    if ( newRange ) {
        newRange.locationDecimal = self.locationDecimal;
        newRange.lengthDecimal   = self.lengthDecimal;
        newRange.locationDouble  = self.locationDouble;
        newRange.lengthDouble    = self.lengthDouble;
    }
    return newRange;
}

/// @endcond

#pragma mark -
#pragma mark NSMutableCopying Methods

/// @cond

-(nonnull id)mutableCopyWithZone:(nullable NSZone *)zone
{
    CPTPlotRange *newRange = [[CPTMutablePlotRange allocWithZone:zone] init];

    if ( newRange ) {
        newRange.locationDecimal = self.locationDecimal;
        newRange.lengthDecimal   = self.lengthDecimal;
        newRange.locationDouble  = self.locationDouble;
        newRange.lengthDouble    = self.lengthDouble;
    }
    return newRange;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)encoder
{
    [encoder encodeDecimal:self.locationDecimal forKey:@"CPTPlotRange.location"];
    [encoder encodeDecimal:self.lengthDecimal forKey:@"CPTPlotRange.length"];
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param decoder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder
{
    if ( (self = [super init]) ) {
        self.locationDecimal = [decoder decodeDecimalForKey:@"CPTPlotRange.location"];
        self.lengthDecimal   = [decoder decodeDecimalForKey:@"CPTPlotRange.length"];
    }

    return self;
}

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Checking Containership

/** @brief Determines whether a given number is inside the range.
 *  @param number The number to check.
 *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
 **/
-(BOOL)contains:(NSDecimal)number
{
    return CPTDecimalGreaterThanOrEqualTo(number, self.minLimitDecimal) && CPTDecimalLessThanOrEqualTo(number, self.maxLimitDecimal);
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
-(BOOL)containsNumber:(nullable NSNumber *)number
{
    if ( [number isKindOfClass:[NSDecimalNumber class]] ) {
        NSDecimal numericValue = number.decimalValue;
        return CPTDecimalGreaterThanOrEqualTo(numericValue, self.minLimitDecimal) && CPTDecimalLessThanOrEqualTo(numericValue, self.maxLimitDecimal);
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
-(BOOL)isEqualToRange:(nullable CPTPlotRange *)otherRange
{
    if ( otherRange ) {
        return CPTDecimalEquals(self.locationDecimal, otherRange.locationDecimal) && CPTDecimalEquals(self.lengthDecimal, otherRange.lengthDecimal);
    }
    else {
        return NO;
    }
}

/** @brief Determines whether the receiver entirely contains another range.
 *  @param otherRange The range to check.
 *  @return @YES if the other range fits entirely within the range of the receiver.
 **/
-(BOOL)containsRange:(nullable CPTPlotRange *)otherRange
{
    if ( otherRange ) {
        return CPTDecimalGreaterThanOrEqualTo(otherRange.minLimitDecimal, self.minLimitDecimal) && CPTDecimalLessThanOrEqualTo(otherRange.maxLimitDecimal, self.maxLimitDecimal);
    }
    else {
        return NO;
    }
}

/** @brief Determines whether a given range intersects the receiver.
 *  @param otherRange The range to check.
 *  @return @YES if the ranges intersect.
 **/
-(BOOL)intersectsRange:(nullable CPTPlotRange *)otherRange
{
    if ( !otherRange ) {
        return NO;
    }

    NSDecimal min1    = self.minLimitDecimal;
    NSDecimal min2    = otherRange.minLimitDecimal;
    NSDecimal minimum = CPTDecimalGreaterThan(min1, min2) ? min1 : min2;

    NSDecimal max1    = self.maxLimitDecimal;
    NSDecimal max2    = otherRange.maxLimitDecimal;
    NSDecimal maximum = CPTDecimalLessThan(max1, max2) ? max1 : max2;

    return CPTDecimalGreaterThanOrEqualTo(maximum, minimum);
}

/** @brief Compares a number to the range, determining if it is in the range, or above or below it.
 *  @param number The number to check.
 *  @return The comparison result.
 **/
-(CPTPlotRangeComparisonResult)compareToNumber:(nonnull NSNumber *)number
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
    else if ( CPTDecimalLessThan(number, self.minLimitDecimal) ) {
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

-(BOOL)isEqual:(nullable id)object
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
    NSDecimalNumber *locationNumber = [NSDecimalNumber decimalNumberWithDecimal:self.locationDecimal];
    NSDecimalNumber *lengthNumber   = [NSDecimalNumber decimalNumberWithDecimal:self.lengthDecimal];

    return locationNumber.hash + lengthNumber.hash;
}

/// @endcond

#pragma mark -
#pragma mark Description

/// @cond

-(nullable NSString *)description
{
    NSDecimal myLocation = self.locationDecimal;
    NSDecimal myLength   = self.lengthDecimal;

    return [NSString stringWithFormat:@"<%@ {%@, %@}>",
            super.description,
            NSDecimalString(&myLocation, [NSLocale currentLocale]),
            NSDecimalString(&myLength, [NSLocale currentLocale])];
}

/// @endcond

#pragma mark -
#pragma mark Debugging

/// @cond

-(nullable id)debugQuickLookObject
{
    NSDecimal myLocation = self.locationDecimal;
    NSDecimal myLength   = self.lengthDecimal;

    return [NSString stringWithFormat:@"Location: %@\nLength:   %@",
            NSDecimalString(&myLocation, [NSLocale currentLocale]),
            NSDecimalString(&myLength, [NSLocale currentLocale])];
}

/// @endcond

@end
