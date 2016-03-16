#import "CPTMutablePlotRange.h"

#import "CPTUtilities.h"

/// @cond
@interface CPTMutablePlotRange()

@property (nonatomic, readwrite) BOOL inValueUpdate;

@end

/// @endcond

#pragma mark -

/** @brief Defines a mutable range of plot data.
 *
 *  If you need to change the plot range, you should use this class rather than the
 *  immutable super class.
 *
 **/
@implementation CPTMutablePlotRange

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

/** @property NSDecimal locationDecimal
 *  @brief The starting value of the range.
 *  @see @ref location, @ref locationDouble
 **/
@dynamic locationDecimal;

/** @property NSDecimal lengthDecimal
 *  @brief The length of the range.
 *  @see @ref length, @ref lengthDouble
 **/
@dynamic lengthDecimal;

/** @property double locationDouble
 *  @brief The starting value of the range as a @double.
 *  @see @ref location, @ref locationDecimal
 **/
@dynamic locationDouble;

/** @property double lengthDouble
 *  @brief The length of the range as a @double.
 *  @see @ref length, @ref lengthDecimal
 **/
@dynamic lengthDouble;

@dynamic inValueUpdate;

#pragma mark -
#pragma mark Combining ranges

/** @brief Extends the range to include another range. The sign of @ref length is unchanged.
 *  @param other The other plot range.
 **/
-(void)unionPlotRange:(nullable CPTPlotRange *)other
{
    if ( !other ) {
        return;
    }

    NSDecimal min1    = self.minLimitDecimal;
    NSDecimal min2    = other.minLimitDecimal;
    NSDecimal minimum = CPTDecimalLessThan(min1, min2) ? min1 : min2;

    NSDecimal max1    = self.maxLimitDecimal;
    NSDecimal max2    = other.maxLimitDecimal;
    NSDecimal maximum = CPTDecimalGreaterThan(max1, max2) ? max1 : max2;

    NSDecimal newLocation, newLength;
    if ( CPTDecimalGreaterThanOrEqualTo( self.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
        newLocation = minimum;
        newLength   = CPTDecimalSubtract(maximum, minimum);
    }
    else {
        newLocation = maximum;
        newLength   = CPTDecimalSubtract(minimum, maximum);
    }

    self.locationDecimal = newLocation;
    self.lengthDecimal   = newLength;
}

/** @brief Sets the messaged object to the intersection with another range. The sign of @ref length is unchanged.
 *  @param other The other plot range.
 **/
-(void)intersectionPlotRange:(nullable CPTPlotRange *)other
{
    if ( !other ) {
        return;
    }

    NSDecimal min1    = self.minLimitDecimal;
    NSDecimal min2    = other.minLimitDecimal;
    NSDecimal minimum = CPTDecimalGreaterThan(min1, min2) ? min1 : min2;

    NSDecimal max1    = self.maxLimitDecimal;
    NSDecimal max2    = other.maxLimitDecimal;
    NSDecimal maximum = CPTDecimalLessThan(max1, max2) ? max1 : max2;

    if ( CPTDecimalGreaterThanOrEqualTo(maximum, minimum) ) {
        NSDecimal newLocation, newLength;
        if ( CPTDecimalGreaterThanOrEqualTo( self.lengthDecimal, CPTDecimalFromInteger(0) ) ) {
            newLocation = minimum;
            newLength   = CPTDecimalSubtract(maximum, minimum);
        }
        else {
            newLocation = maximum;
            newLength   = CPTDecimalSubtract(minimum, maximum);
        }

        self.locationDecimal = newLocation;
        self.lengthDecimal   = newLength;
    }
    else {
        self.lengthDecimal = CPTDecimalFromInteger(0);
    }
}

#pragma mark -
#pragma mark Expanding/Contracting ranges

/** @brief Extends/contracts the range by a given factor.
 *  @param factor Factor used. A value of @num{1.0} gives no change.
 *  Less than @num{1.0} is a contraction, and greater than @num{1.0} is expansion.
 **/
-(void)expandRangeByFactor:(nonnull NSNumber *)factor
{
    NSDecimal oldLength      = self.lengthDecimal;
    NSDecimal newLength      = CPTDecimalMultiply(oldLength, factor.decimalValue);
    NSDecimal locationOffset = CPTDecimalDivide( CPTDecimalSubtract(oldLength, newLength), CPTDecimalFromInteger(2) );
    NSDecimal newLocation    = CPTDecimalAdd(self.locationDecimal, locationOffset);

    self.locationDecimal = newLocation;
    self.lengthDecimal   = newLength;
}

#pragma mark -
#pragma mark Shifting Range

/** @brief Moves the whole range so that the @ref location fits in other range.
 *  @param otherRange Other range.
 *  The minimum possible shift is made. The range @ref length is unchanged.
 **/
-(void)shiftLocationToFitInRange:(nonnull CPTPlotRange *)otherRange
{
    NSParameterAssert(otherRange);

    switch ( [otherRange compareToDecimal:self.locationDecimal] ) {
        case CPTPlotRangeComparisonResultNumberBelowRange:
            self.locationDecimal = otherRange.minLimitDecimal;
            break;

        case CPTPlotRangeComparisonResultNumberAboveRange:
            self.locationDecimal = otherRange.maxLimitDecimal;
            break;

        default:
            // in range--do nothing
            break;
    }
}

/** @brief Moves the whole range so that the @ref end point fits in other range.
 *  @param otherRange Other range.
 *  The minimum possible shift is made. The range @ref length is unchanged.
 **/
-(void)shiftEndToFitInRange:(nonnull CPTPlotRange *)otherRange
{
    NSParameterAssert(otherRange);

    switch ( [otherRange compareToDecimal:self.endDecimal] ) {
        case CPTPlotRangeComparisonResultNumberBelowRange:
            self.locationDecimal = CPTDecimalSubtract(otherRange.minLimitDecimal, self.lengthDecimal);
            break;

        case CPTPlotRangeComparisonResultNumberAboveRange:
            self.locationDecimal = CPTDecimalSubtract(otherRange.maxLimitDecimal, self.lengthDecimal);
            break;

        default:
            // in range--do nothing
            break;
    }
}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setLocation:(NSNumber *)newLocation
{
    self.inValueUpdate = YES;

    self.locationDecimal = newLocation.decimalValue;
    self.locationDouble  = newLocation.doubleValue;

    self.inValueUpdate = NO;
}

-(void)setLength:(NSNumber *)newLength
{
    self.inValueUpdate = YES;

    self.lengthDecimal = newLength.decimalValue;
    self.lengthDouble  = newLength.doubleValue;

    self.inValueUpdate = NO;
}

/// @endcond

@end
