
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPDefinitions.h"
#import "CPPlotArea.h"
#import "CPBorderedLayer.h"

@implementation CPXYAxisSet

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		CPBorderedLayer *newOverlayLayer = [[CPBorderedLayer alloc] init];
		self.overlayLayer = newOverlayLayer;
		[newOverlayLayer release];
		
		CPXYAxis *xAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
		xAxis.coordinate = CPCoordinateX;
        xAxis.tickDirection = CPSignNegative;
		
		CPXYAxis *yAxis = [[CPXYAxis alloc] initWithFrame:newFrame];
		yAxis.coordinate = CPCoordinateY;
        yAxis.tickDirection = CPSignNegative;
		
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
