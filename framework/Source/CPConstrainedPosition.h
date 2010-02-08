
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@interface CPConstrainedPosition : NSObject {
	CGFloat position;
    CGFloat lowerBound;
    CGFloat upperBound;
    CGFloat lowerRatio;
    CPConstraints constraints;
}

@property (nonatomic, readwrite, assign) CGFloat position;
@property (nonatomic, readwrite, assign) CGFloat lowerBound;
@property (nonatomic, readwrite, assign) CGFloat upperBound;
@property (nonatomic, readonly, assign) CPConstraints constraints;

-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;

@end
