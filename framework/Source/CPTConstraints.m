#import "CPTConstraints.h"

#import "NSCoderExtensions.h"
#import "_CPTConstraintsFixed.h"
#import "_CPTConstraintsRelative.h"

/** @brief Implements a one-dimensional constrained position within a given numeric range.
 *
 *  Supports fixed distance from either end of the range and a proportional fraction of the range.
 **/
@implementation CPTConstraints

#pragma mark -
#pragma mark Factory methods

/** @brief Creates and returns a new CPTConstraints instance initialized with a fixed offset from the lower bound.
 *  @param newOffset The offset.
 *  @return A new CPTConstraints instance initialized with the given offset.
 **/
+(CPTConstraints *)constraintWithLowerOffset:(CGFloat)newOffset
{
    return [[(_CPTConstraintsFixed *)[_CPTConstraintsFixed alloc] initWithLowerOffset : newOffset] autorelease];
}

/** @brief Creates and returns a new CPTConstraints instance initialized with a fixed offset from the upper bound.
 *  @param newOffset The offset.
 *  @return A new CPTConstraints instance initialized with the given offset.
 **/
+(CPTConstraints *)constraintWithUpperOffset:(CGFloat)newOffset
{
    return [[(_CPTConstraintsFixed *)[_CPTConstraintsFixed alloc] initWithUpperOffset : newOffset] autorelease];
}

/** @brief Creates and returns a new CPTConstraints instance initialized with a proportional offset relative to the bounds.
 *
 *  For example, an offset of @num{0.0} will return a position equal to the lower bound, @num{1.0} will return the upper bound,
 *  and @num{0.5} will return a point midway between the two bounds.
 *
 *  @param newOffset The offset.
 *  @return A new CPTConstraints instance initialized with the given offset.
 **/
+(CPTConstraints *)constraintWithRelativeOffset:(CGFloat)newOffset
{
    return [[(_CPTConstraintsRelative *)[_CPTConstraintsRelative alloc] initWithRelativeOffset : newOffset] autorelease];
}

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTConstraints instance initialized with a fixed offset from the lower bound.
 *  @param newOffset The offset.
 *  @return The initialized CPTConstraints object.
 **/
-(id)initWithLowerOffset:(CGFloat)newOffset
{
    [self release];

    self = [(_CPTConstraintsFixed *)[_CPTConstraintsFixed alloc] initWithLowerOffset : newOffset];

    return self;
}

/** @brief Initializes a newly allocated CPTConstraints instance initialized with a fixed offset from the upper bound.
 *  @param newOffset The offset.
 *  @return The initialized CPTConstraints object.
 **/
-(id)initWithUpperOffset:(CGFloat)newOffset
{
    [self release];

    self = [(_CPTConstraintsFixed *)[_CPTConstraintsFixed alloc] initWithUpperOffset : newOffset];

    return self;
}

/** @brief Initializes a newly allocated CPTConstraints instance initialized with a proportional offset relative to the bounds.
 *
 *  For example, an offset of @num{0.0} will return a position equal to the lower bound, @num{1.0} will return the upper bound,
 *  and @num{0.5} will return a point midway between the two bounds.
 *
 *  @param newOffset The offset.
 *  @return The initialized CPTConstraints object.
 **/
-(id)initWithRelativeOffset:(CGFloat)newOffset
{
    [self release];

    self = [(_CPTConstraintsRelative *)[_CPTConstraintsRelative alloc] initWithRelativeOffset : newOffset];

    return self;
}

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    // do nothing--implemented in subclasses
    return nil;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    // do nothing--implemented in subclasses
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( [coder containsValueForKey:@"_CPTConstraintsFixed.offset"] ) {
        CGFloat offset      = [coder decodeCGFloatForKey:@"_CPTConstraintsFixed.offset"];
        BOOL isFixedToLower = [coder decodeBoolForKey:@"_CPTConstraintsFixed.isFixedToLower"];
        if ( isFixedToLower ) {
            return [self initWithLowerOffset:offset];
        }
        else {
            return [self initWithUpperOffset:offset];
        }
    }
    else if ( [coder containsValueForKey:@"_CPTConstraintsRelative.offset"] ) {
        CGFloat offset = [coder decodeCGFloatForKey:@"_CPTConstraintsRelative.offset"];
        return [self initWithRelativeOffset:offset];
    }

    return self;
}

/// @endcond

@end

#pragma mark -

@implementation CPTConstraints(AbstractMethods)

#pragma mark -
#pragma mark Comparison

/** @brief Determines whether a given constraint is equal to the receiver.
 *  @param otherConstraint The constraint to check.
 *  @return @YES if the constraints are equal.
 **/
-(BOOL)isEqualToConstraint:(CPTConstraints *)otherConstraint
{
    // subclasses override to do comparison here
    return [super isEqual:otherConstraint];
}

#pragma mark -
#pragma mark Positioning

/** @brief Compute the position given a range of values.
 *  @param lowerBound The lower bound; must be less than or equal to the @par{upperBound}.
 *  @param upperBound The upper bound; must be greater than or equal to the @par{lowerBound}.
 *  @return The calculated position.
 **/
-(CGFloat)positionForLowerBound:(CGFloat)lowerBound upperBound:(CGFloat)upperBound
{
    // subclasses override to do position calculation here
    return NAN;
}

@end
