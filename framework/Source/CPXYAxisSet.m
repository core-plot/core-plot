
#import "CPXYAxisSet.h"
#import "CPLinearAxis.h"

@implementation CPXYAxisSet

- (id) init
{
	self = [super init];
	if (self != nil) {
		CPLinearAxis *xAxis = [[CPLinearAxis alloc] init];
        xAxis.angle = kCPHorizontalAxisAngle;
		CPLinearAxis *yAxis = [[CPLinearAxis alloc] init];
        yAxis.angle = kCPVerticalAxisAngle;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
	}
	return self;
}

@end
