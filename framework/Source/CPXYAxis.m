#import "CPXYAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPAxisLabel.h"

///	@cond
@interface CPXYAxis ()

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 
-(void)drawGridLinesInContext:(CGContextRef)theContext atLocations:(NSSet *)locations isMajor:(BOOL)major;

-(void)terminalPointsForGridLineWithCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint;

@end
///	@endcond

/**	@brief A 2-dimensional cartesian (X-Y) axis class.
 **/
@implementation CPXYAxis

/**	@property constantCoordinateValue
 *	@brief The data coordinate value where the axis crosses the orthogonal axis.
 **/
@synthesize constantCoordinateValue;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
        constantCoordinateValue = [[NSDecimalNumber zero] decimalValue];
		
		self.tickDirection = CPSignNone;
		self.needsDisplayOnBoundsChange = YES;
}
	return self;
}

#pragma mark -
#pragma mark Drawing

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{
    CPCoordinate orthogonalCoordinate = (self.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    
    NSDecimal plotPoint[2];
    plotPoint[self.coordinate] = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = self.constantCoordinateValue;
    CGPoint point = [self.plotSpace viewPointInLayer:self forPlotPoint:plotPoint];
    
    return point;
}

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major
{
	[(major ? self.majorTickLineStyle : self.minorTickLineStyle) setLineStyleInContext:theContext];
	CGContextBeginPath(theContext);

    for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:[tickLocation decimalValue]];
		CGPoint startViewPoint = baseViewPoint;
        CGPoint endViewPoint = baseViewPoint;
		
		CGFloat startFactor, endFactor;
		switch ( self.tickDirection ) {
			case CPSignPositive:
				startFactor = 0;
				endFactor = 1;
				break;
			case CPSignNegative:
				startFactor = 0;
				endFactor = -1;
				break;
			case CPSignNone:
				startFactor = -0.5;
				endFactor = 0.5;
				break;
			default:
				NSLog(@"Invalid sign in drawTicksInContext...");
				break;
		}
		
        if ( self.coordinate == CPCoordinateX ) {
			startViewPoint.y += length * startFactor;
			endViewPoint.y += length * endFactor;
		}
        else {
			startViewPoint.x += length * startFactor;
			endViewPoint.x += length * endFactor;
		}
        
		startViewPoint = CPAlignPointToUserSpace(theContext, startViewPoint);
		endViewPoint = CPAlignPointToUserSpace(theContext, endViewPoint);
		
        // Add tick line
        CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
        CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
    }    
	// Stroke tick line
	CGContextStrokePath(theContext);
}

-(void)terminalPointsForGridLineWithCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint
{
    CPCoordinate orthogonalCoordinate = (self.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    CPPlotRange *orthogonalRange = [self.plotSpace plotRangeForCoordinate:orthogonalCoordinate];
    
    // Start point
    NSDecimal plotPoint[2];
    plotPoint[self.coordinate] = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = orthogonalRange.location;
    *startPoint = [self.plotSpace viewPointInLayer:self forPlotPoint:plotPoint];
    
    // End point
    plotPoint[orthogonalCoordinate] = orthogonalRange.end;
    *endPoint = [self.plotSpace viewPointInLayer:self forPlotPoint:plotPoint];
}

-(void)drawGridLinesInContext:(CGContextRef)theContext atLocations:(NSSet *)locations isMajor:(BOOL)major
{
	if ( major && !self.majorGridLineStyle ) return;
    if ( !major && !self.minorGridLineStyle ) return; 
    
	[(major ? self.majorGridLineStyle : self.minorGridLineStyle) setLineStyleInContext:theContext];
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
    
	// Stroke grid line
	CGContextStrokePath(theContext);
}

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[super renderAsVectorInContext:theContext];
	
    // Grid Lines
    [self drawGridLinesInContext:theContext atLocations:self.minorTickLocations isMajor:NO];
    [self drawGridLinesInContext:theContext atLocations:self.majorTickLocations isMajor:YES];
	
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength isMajor:NO];
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength isMajor:YES];
    
    // Axis Line
	if ( self.axisLineStyle ) {
		CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
		CGPoint startViewPoint = CPAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.location]);
		CGPoint endViewPoint = CPAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.end]);
		[self.axisLineStyle setLineStyleInContext:theContext];
		CGContextBeginPath(theContext);
		CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
		CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
		CGContextStrokePath(theContext);
	}
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
	
	return [NSString stringWithFormat:@"CPXYAxis with range %@ viewCoordinates: {%f, %f} to {%f, %f}", range, startViewPoint.x, startViewPoint.y, endViewPoint.x, endViewPoint.y];
};

#pragma mark -
#pragma mark Labels

-(NSDecimal)axisTitleLocation
{
	// Find the longest range, before or after the constant coordinate location, and divide that by two
    CPPlotRange *axisRange = [self.plotSpace plotRangeForCoordinate:self.coordinate];

	NSDecimal distanceAfterConstantCoordinate = CPDecimalSubtract(axisRange.end, self.constantCoordinateValue);
	NSDecimal distanceBeforeConstantCoordinate = CPDecimalSubtract(self.constantCoordinateValue, axisRange.location);
	
	if (CPDecimalLessThan(distanceAfterConstantCoordinate, distanceBeforeConstantCoordinate)) {
		return CPDecimalDivide(CPDecimalAdd(self.constantCoordinateValue, axisRange.location), CPDecimalFromDouble(2.0));
	}
	else {
		return CPDecimalDivide(CPDecimalAdd(axisRange.end, self.constantCoordinateValue), CPDecimalFromDouble(2.0));
	}
}

@end
