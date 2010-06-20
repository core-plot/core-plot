#import "CPDefinitions.h"
#import "CPLineStyle.h"
#import "CPUtilities.h"
#import "CPXYAxis.h"
#import "CPXYAxisSet.h"

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
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.borderLineStyle ) {
		[super renderAsVectorInContext:context];
		
		CALayer *superlayer = self.superlayer;
		CGRect borderRect = CPAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);
		
		[self.borderLineStyle setLineStyleInContext:context];
		
		CGContextStrokeRect(context, borderRect);
	}
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
