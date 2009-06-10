
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPDefinitions.h"
#import "CPPlotArea.h"

@implementation CPXYAxisSet

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		CPXYAxis *xAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
		xAxis.coordinate = CPCoordinateX;
        xAxis.tickDirection = CPDirectionDown;
		
		CPXYAxis *yAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
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
