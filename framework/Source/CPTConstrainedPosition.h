#import <Foundation/Foundation.h>
#import "CPTDefinitions.h"

@interface CPTConstrainedPosition : NSObject {
	CGFloat position;
    CGFloat lowerBound;
    CGFloat upperBound;
    CPTConstraints constraints;
}

@property (nonatomic, readwrite, assign) CGFloat position;
@property (nonatomic, readwrite, assign) CGFloat lowerBound;
@property (nonatomic, readwrite, assign) CGFloat upperBound;
@property (nonatomic, readwrite, assign) CPTConstraints constraints;

-(id)initWithPosition:(CGFloat)newPosition lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;
-(id)initWithAlignment:(CPTAlignment)newAlignment lowerBound:(CGFloat)newLowerBound upperBound:(CGFloat)newUpperBound;

-(void)adjustPositionForOldLowerBound:(CGFloat)oldLowerBound oldUpperBound:(CGFloat)oldUpperBound;

@end
