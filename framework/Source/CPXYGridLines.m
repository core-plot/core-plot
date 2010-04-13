#import "CPXYGridLines.h"
#import "CPAxis.h"
#import "CPLineStyle.h"
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPUtilities.h"

///	@cond
@interface CPXYGridLines ()

-(void)terminalPointsForGridLineWithCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint;

@end
///	@endcond

/**	@brief A class that draws grid lines for a Cartesian (X-Y) axis.
 **/
@implementation CPXYGridLines

#pragma mark -
#pragma mark Drawing

-(void)terminalPointsForGridLineWithCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint
{
	CPAxis *axis = self.axis;
    CPCoordinate orthogonalCoordinate = (axis.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    CPPlotRange *orthogonalRange = [axis.plotSpace plotRangeForCoordinate:orthogonalCoordinate];
    
	CPPlotArea *plotArea = axis.plotArea;

    // Start point
    NSDecimal plotPoint[2];
    plotPoint[axis.coordinate] = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = orthogonalRange.location;
    *startPoint = [self convertPoint:[axis.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:plotArea];
    
    // End point
    plotPoint[orthogonalCoordinate] = orthogonalRange.end;
    *endPoint = [self convertPoint:[axis.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:plotArea];
}

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	CPAxis *axis = self.axis;
	CPLineStyle *lineStyle = (self.major ? axis.majorGridLineStyle : axis.minorGridLineStyle);
	
	if ( lineStyle ) {
		[super renderAsVectorInContext:theContext];
		
		[axis relabel];
		
		NSSet *locations = (self.major ? axis.majorTickLocations : axis.minorTickLocations);
		
		CGContextBeginPath(theContext);
		
		for ( NSDecimalNumber *location in locations ) {
			CGPoint startViewPoint;
			CGPoint endViewPoint;
			[self terminalPointsForGridLineWithCoordinateDecimalNumber:[location decimalValue] startPoint:&startViewPoint endPoint:&endViewPoint];
			
			// Align to pixels
			startViewPoint = CPAlignPointToUserSpace(theContext, startViewPoint);
			endViewPoint = CPAlignPointToUserSpace(theContext, endViewPoint);
			
			// Add grid line 
			CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
			CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
		}
		
		// Stroke grid lines
		[lineStyle setLineStyleInContext:theContext];
		CGContextStrokePath(theContext);
	}
}

@end
