
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPDefinitions.h"
#import "CPPlotArea.h"
#import "CPBorderedLayer.h"

/**	@brief A set of cartesian (X-Y) axes.
 **/
@implementation CPXYAxisSet

/**	@property xAxis
 *	@brief The x-axis.
 **/
@dynamic xAxis;

/**	@property yAxis
 *	@brief The y-axis.
 **/
@dynamic yAxis;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		CPXYAxis *xAxis = [(CPXYAxis *)[CPXYAxis alloc] initWithFrame:newFrame];
		xAxis.coordinate = CPCoordinateX;
        xAxis.tickDirection = CPSignNegative;
		
		CPXYAxis *yAxis = [(CPXYAxis *)[CPXYAxis alloc] initWithFrame:newFrame];
		yAxis.coordinate = CPCoordinateY;
        yAxis.tickDirection = CPSignNegative;
		
		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
		[xAxis release];
		[yAxis release];
	}
	return self;
}

#pragma mark -
#pragma mark Accessors

-(CPXYAxis *)xAxis 
{
    return [self.axes objectAtIndex:CPCoordinateX];
}

-(CPXYAxis *)yAxis 
{
    return [self.axes objectAtIndex:CPCoordinateY];
}

@end
