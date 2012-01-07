#import "CPTXYAxisSet.h"

#import "CPTDefinitions.h"
#import "CPTLineStyle.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"

/**
 *	@brief A set of cartesian (X-Y) axes.
 **/
@implementation CPTXYAxisSet

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

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYAxisSet object with the provided frame rectangle.
 *
 *	This is the designated initializer. The @link CPTAxisSet::axes axes @endlink array
 *	will contain two new axes with the following properties:
 *
 *	<table>
 *	<tr><td>Axis</td><td>@link CPTAxis::coordinate coordinate @endlink</td><td>@link CPTAxis::tickDirection tickDirection @endlink</td></tr>
 *	<tr><td>@link CPTXYAxisSet::xAxis xAxis @endlink</td><td>#CPTCoordinateX</td><td>#CPTSignNegative</td></tr>
 *	<tr><td>@link CPTXYAxisSet::yAxis yAxis @endlink</td><td>#CPTCoordinateY</td><td>#CPTSignNegative</td></tr>
 *	</table>
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTXYAxisSet object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		CPTXYAxis *xAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:newFrame];
		xAxis.coordinate	= CPTCoordinateX;
		xAxis.tickDirection = CPTSignNegative;

		CPTXYAxis *yAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:newFrame];
		yAxis.coordinate	= CPTCoordinateY;
		yAxis.tickDirection = CPTSignNegative;

		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
		[xAxis release];
		[yAxis release];
	}
	return self;
}

///	@}

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}

	if ( self.borderLineStyle ) {
		[super renderAsVectorInContext:context];

		CALayer *superlayer = self.superlayer;
		CGRect borderRect	= CPTAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);

		[self.borderLineStyle setLineStyleInContext:context];

		CGContextStrokeRect(context, borderRect);
	}
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(CPTXYAxis *)xAxis
{
	return [self.axes objectAtIndex:CPTCoordinateX];
}

-(CPTXYAxis *)yAxis
{
	return [self.axes objectAtIndex:CPTCoordinateY];
}

///	@endcond

@end
