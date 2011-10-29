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

#pragma mark -
#pragma mark Drawing

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

#pragma mark -
#pragma mark Accessors

-(CPTXYAxis *)xAxis
{
	return [self.axes objectAtIndex:CPTCoordinateX];
}

-(CPTXYAxis *)yAxis
{
	return [self.axes objectAtIndex:CPTCoordinateY];
}

@end
