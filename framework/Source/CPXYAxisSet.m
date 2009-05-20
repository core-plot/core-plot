
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPDefinitions.h"

@implementation CPXYAxisSet

-(id)init
{
	if (self = [super init]) {
		CPXYAxis *xAxis = [[CPXYAxis alloc] init];
		xAxis.majorTickLength = 10.f;
		xAxis.minorTickLength = 5.f;
		xAxis.tickLabelOffset = 15.f;
		xAxis.coordinate = CPCoordinateX;
		
		CPXYAxis *yAxis = [[CPXYAxis alloc] init];
		yAxis.majorTickLength = 10.f;
		yAxis.minorTickLength = 5.f;
		yAxis.tickLabelOffset = 15.f;
		yAxis.coordinate = CPCoordinateY;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
		[xAxis release];
		[yAxis release];
	}
	return self;
}

-(CPXYAxis *)xAxis 
{
    return [self.axes objectAtIndex:CPCoordinateX];
}

-(CPXYAxis *)yAxis 
{
    return [self.axes objectAtIndex:CPCoordinateY];
}

@end
