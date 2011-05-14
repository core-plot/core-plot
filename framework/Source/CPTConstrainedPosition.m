#import "CPTConstrainedPosition.h"
#import "CPTExceptions.h"

/**	@brief Implements a spring and strut positioning algorithm for one dimension.
 **/
@implementation CPTConstrainedPosition

/**	@property lowerBound
 *	@brief The lower bound.
 **/
@synthesize lowerBound;

/**	@property upperBound
 *	@brief The upper bound.
 **/
@synthesize upperBound;

/**	@property constraints
 *	@brief The positioning constraints.
 **/
@synthesize constraints;

/**	@property position
 *	@brief The current position.
 **/
@synthesize position;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPTConstrainedPosition object with the provided position and bounds. This is the designated initializer.
 *	@param newPosition The position.
 *	@param newLowerBound The lower bound.
 *	@param newUpperBound The upper bound.
 *  @return A CPTConstrainedPosition instance initialized with the provided position and bounds.
 **/
-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound
{
    if ( self = [super init] ) {
        position = newPosition;
        lowerBound = newLowerBound;
        upperBound = newUpperBound;
        constraints.lower = CPTConstraintNone;
        constraints.upper = CPTConstraintNone;
    }
    return self;
}

/** @brief Initializes a newly allocated CPTConstrainedPosition object with the provided alignment and bounds. 
 *	@param newAlignment The alignment.
 *	@param newLowerBound The lower bound.
 *	@param newUpperBound The upper bound.
 *  @return A CPTConstrainedPosition instance initialized with the provided alignment and bounds.
 **/
-(id)initWithAlignment:(CPTAlignment)newAlignment lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound
{
	CGFloat newPosition;
    CPTConstraint lowerConstraint;
    CPTConstraint upperConstraint;
    switch ( newAlignment ) {
        case CPTAlignmentLeft:
        case CPTAlignmentBottom:
            newPosition = newLowerBound;
            lowerConstraint = CPTConstraintFixed;
            upperConstraint = CPTConstraintNone;
            break;
        case CPTAlignmentRight:
        case CPTAlignmentTop:
            newPosition = newUpperBound;
            lowerConstraint = CPTConstraintNone;
            upperConstraint = CPTConstraintFixed;
            break;
        case CPTAlignmentCenter:
        case CPTAlignmentMiddle:
            newPosition = (newUpperBound - newLowerBound) * 0.5 + newLowerBound;
            lowerConstraint = CPTConstraintNone;
            upperConstraint = CPTConstraintNone;
            break;
        default:
        	[NSException raise:CPTException format:@"Invalid alignment in initWithAlignment..."];
            break;
    }
    
    if ( self = [self initWithPosition:newPosition lowerBound:newLowerBound upperBound:newUpperBound] ) {
        constraints.lower = lowerConstraint;
        constraints.upper = upperConstraint;
    }
    
    return self;
}

#pragma mark -
#pragma mark Positioning

/**	@brief Adjust the position given the previous bounds.
 *	@param oldLowerBound The old lower bound.
 *	@param oldUpperBound The old upper bound.
 **/
-(void)adjustPositionForOldLowerBound:(CGFloat)oldLowerBound oldUpperBound:(CGFloat)oldUpperBound
{
    if ( self.constraints.lower == self.constraints.upper ) {
        CGFloat lowerRatio = 0.0;
		if ( (oldUpperBound - oldLowerBound) != 0.0 ) {
            lowerRatio = (self.position - oldLowerBound) / (oldUpperBound - oldLowerBound);
        }
        self.position = self.lowerBound + lowerRatio * (self.upperBound - self.lowerBound);
    }
    else if ( self.constraints.lower == CPTConstraintFixed ) {
        self.position = self.lowerBound + (self.position - oldLowerBound);
    }
    else {
        self.position = self.upperBound - (oldUpperBound - self.position);
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setLowerBound:(CGFloat)newLowerBound 
{
    if ( newLowerBound != lowerBound ) {
    	CGFloat oldLowerBound = lowerBound;
        lowerBound = newLowerBound;
        [self adjustPositionForOldLowerBound:oldLowerBound oldUpperBound:self.upperBound];
    }
}

-(void)setUpperBound:(CGFloat)newUpperBound 
{
    if ( newUpperBound != upperBound ) {
    	CGFloat oldUpperBound = upperBound;
        upperBound = newUpperBound;
        [self adjustPositionForOldLowerBound:self.lowerBound oldUpperBound:oldUpperBound];
    }
}

@end
