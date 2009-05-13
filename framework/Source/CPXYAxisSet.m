
#import "CPXYAxisSet.h"
#import "CPLinearAxis.h"

@implementation CPXYAxisSet

- (id) init
{
	self = [super init];
	if (self != nil) {
		CPLinearAxis *xAxis = [[CPLinearAxis alloc] init];
        xAxis.independentRangeIndex = 1;
		xAxis.majorTickLength = 10.f;
		CPLinearAxis *yAxis = [[CPLinearAxis alloc] init];
        yAxis.independentRangeIndex = 0;
		yAxis.majorTickLength = -10.f;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
	}
	return self;
}

@end
