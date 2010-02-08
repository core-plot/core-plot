#import "CPConstrainedPosition.h"

/**	@brief Implements a spring and strut positioning algorithm for one dimension.
 **/
@implementation CPConstrainedPosition

@synthesize lowerBound, upperBound;
@synthesize constraints;
@synthesize position;

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

-(void)adjustPositionForOldLowerBound:(CGFloat)oldLowerBound oldUpperBound:(CGFloat)oldUpperBound
{
    if ( constraints.lower == constraints.upper ) {
        if ( upperBound - lowerBound > 1.e-3 && oldUpperBound - oldLowerBound > 1.e-3 ) {
            lowerRatio = (position - oldLowerBound) / (oldUpperBound - oldLowerBound);
        }
        self.position = lowerBound + lowerRatio * (upperBound - lowerBound);
    }
    else if ( constraints.lower == CPConstraintFixed ) {
        self.position = lowerBound + (position - oldLowerBound);
    }
    else {
        self.position = upperBound - (oldUpperBound - position);
    }
}

-(void)setLowerBound:(CGFloat)newLowerBound 
{
    if ( newLowerBound != lowerBound ) {
    	CGFloat oldLowerBound = lowerBound;
        lowerBound = newLowerBound;
        [self adjustPositionForOldLowerBound:oldLowerBound oldUpperBound:upperBound];
    }
}

-(void)setUpperBound:(CGFloat)newUpperBound 
{
    if ( newUpperBound != upperBound ) {
    	CGFloat oldUpperBound = upperBound;
        upperBound = newUpperBound;
        [self adjustPositionForOldLowerBound:lowerBound oldUpperBound:oldUpperBound];
    }
}

@end
