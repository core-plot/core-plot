#import "CPConstrainedPosition.h"

///	@cond
@interface CPConstrainedPosition ()

@property (nonatomic, readwrite, assign) CGFloat lowerRatio;

@end
///	@endcond

/**	@brief Implements a spring and strut positioning algorithm for one dimension.
 **/
@implementation CPConstrainedPosition

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

/**	@property lowerRatio
 *	@brief The current position, normalized to a range of 0 to 1 between the lower and upper bounds.
 **/
@synthesize lowerRatio;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPConstrainedPosition object with the provided position and bounds. This is the designated initializer.
 *	@param newPosition The position.
 *	@param newLowerBound The lower bound.
 *	@param newUpperBound The upper bound.
 **/
-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound
{
    if ( self = [super init] ) {
        position = newPosition;
        lowerBound = newLowerBound;
        upperBound = newUpperBound;
        constraints.lower = CPConstraintNone;
        constraints.upper = CPConstraintNone;
        lowerRatio = (position - lowerBound) / MAX(1.e-6, upperBound - lowerBound);
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
        if ( self.upperBound - self.lowerBound > 1.e-3 && oldUpperBound - oldLowerBound > 1.e-3 ) {
            self.lowerRatio = (self.position - oldLowerBound) / (oldUpperBound - oldLowerBound);
        }
        self.position = self.lowerBound + self.lowerRatio * (self.upperBound - self.lowerBound);
    }
    else if ( self.constraints.lower == CPConstraintFixed ) {
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
