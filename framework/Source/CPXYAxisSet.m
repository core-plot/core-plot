
#import "CPXYAxisSet.h"
#import "CPLinearAxis.h"

@implementation CPXYAxisSet

- (id) init
{
	if (self = [super init]) {
		CPLinearAxis *xAxis = [[CPLinearAxis alloc] init];
        xAxis.independentRangeIndex = 1;
		xAxis.majorTickLength = 10.f;
		CPLinearAxis *yAxis = [[CPLinearAxis alloc] init];
        yAxis.independentRangeIndex = 0;
		yAxis.majorTickLength = -10.f;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
		[xAxis release];
		[yAxis release];
	}
	return self;
}

@end
