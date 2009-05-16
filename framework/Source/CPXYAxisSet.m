
#import "CPXYAxisSet.h"
#import "CPLinearAxis.h"
#import "CPDefinitions.h"

@implementation CPXYAxisSet

-(id)init
{
	if (self = [super init]) {
		CPLinearAxis *xAxis = [[CPLinearAxis alloc] init];
		xAxis.majorTickLength = 10.f;
		xAxis.coordinate = CPCoordinateX;
		
		CPLinearAxis *yAxis = [[CPLinearAxis alloc] init];
		yAxis.majorTickLength = 10.f;
		yAxis.coordinate = CPCoordinateY;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
		[xAxis release];
		[yAxis release];
	}
	return self;
}

-(CPAxis *)xAxis 
{
    return [self.axes objectAtIndex:CPCoordinateX];
}

-(CPAxis *)yAxis 
{
    return [self.axes objectAtIndex:CPCoordinateY];
}

@end
