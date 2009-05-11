
#import "CPXYAxisSet.h"
#import "CPAxis.h"


@implementation CPXYAxisSet

- (id) init
{
	self = [super init];
	if (self != nil) {
		CPAxis* xAxis = [[CPAxis alloc] init];
		[xAxis setAngle:kCPHorizontalAxisAngle];
		CPAxis* yAxis = [[CPAxis alloc] init];
		[yAxis setAngle:kCPVerticalAxisAngle];
		
		self.axes = [NSArray arrayWithObjects:xAxis,yAxis,nil];
	}
	return self;
}

@end
