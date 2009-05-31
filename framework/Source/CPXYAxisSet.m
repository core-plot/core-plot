
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPDefinitions.h"

@implementation CPXYAxisSet

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		CPXYAxis *xAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
		xAxis.majorTickLength = 10.f;
		xAxis.minorTickLength = 5.f;
		xAxis.axisLabelOffset = 20.f;
		xAxis.coordinate = CPCoordinateX;
        xAxis.tickDirection = CPDirectionDown;
		
		CPXYAxis *yAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
		yAxis.majorTickLength = 10.f;
		yAxis.minorTickLength = 5.f;
		yAxis.axisLabelOffset = 20.f;
		yAxis.coordinate = CPCoordinateY;
        yAxis.tickDirection = CPDirectionLeft;
		
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
