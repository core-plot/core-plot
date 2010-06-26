
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

typedef enum _CPAlignment {
    CPAlignmentLeft = 0,
    CPAlignmentCenter,
    CPAlignmentRight,
    CPAlignmentTop,
    CPAlignmentMiddle,
    CPAlignmentBottom
} CPAlignment;

@interface CPConstrainedPosition : NSObject {
	CGFloat position;
    CGFloat lowerBound;
    CGFloat upperBound;
    CPConstraints constraints;
}

@property (nonatomic, readwrite, assign) CGFloat position;
@property (nonatomic, readwrite, assign) CGFloat lowerBound;
@property (nonatomic, readwrite, assign) CGFloat upperBound;
@property (nonatomic, readwrite, assign) CPConstraints constraints;

-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;
-(id)initWithAlignment:(CPAlignment)newAlignment lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;

-(void)adjustPositionForOldLowerBound:(CGFloat)oldLowerBound oldUpperBound:(CGFloat)oldUpperBound;

@end
