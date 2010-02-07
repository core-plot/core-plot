
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@interface CPConstrainedPosition : NSObject {
	CGFloat position;
    CGFloat lowerBound;
    CGFloat upperBound;
    CGFloat lowerRatio;
    CPConstraint lowerConstraint;
    CPConstraint upperConstraint;
}

@property (nonatomic, readwrite, assign) CGFloat position;
@property (nonatomic, readwrite, assign) CGFloat lowerBound;
@property (nonatomic, readwrite, assign) CGFloat upperBound;
@property (nonatomic, readonly, assign) CPConstraint lowerConstraint;
@property (nonatomic, readonly, assign) CPConstraint upperConstraint;

-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;

@end
