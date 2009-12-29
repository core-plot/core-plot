#import "CPPlotSpace.h"
#import "CPLineStyle.h"
#import "CPPlotRange.h"
#import "CPPlottingArea.h"
#import "CPUtilities.h"
#import "CPXYAxis.h"
#import "CPXYGridLines.h"

///	@cond
@interface CPXYAxis ()

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 

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
    
	CPPlottingArea *plottingArea = self.plottingArea;
    NSDecimal plotPoint[2];
    plotPoint[self.coordinate] = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = self.constantCoordinateValue;
    CGPoint point = [self convertPoint:[self.plotSpace viewPointInLayer:plottingArea forPlotPoint:plotPoint] fromLayer:plottingArea];
    
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
				NSLog(@"Invalid sign in [CPXYAxis drawTicksInContext:]");
		}
		
        switch ( self.coordinate ) {
			case CPCoordinateX:
				startViewPoint.y += length * startFactor;
				endViewPoint.y += length * endFactor;
				break;
			case CPCoordinateY:
				startViewPoint.x += length * startFactor;
				endViewPoint.x += length * endFactor;
				break;
			default:
				NSLog(@"Invalid coordinate in [CPXYAxis drawTicksInContext:]");
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

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[super renderAsVectorInContext:theContext];
	
	[self relabel];
	
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
	
	return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
			[super description],
			range,
			CPStringFromPoint(startViewPoint),
			CPStringFromPoint(endViewPoint)];
};

#pragma mark -
#pragma mark Labels

-(NSDecimal)defaultTitleLocation;
{
	CPPlotRange *axisRange = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	
	return CPDecimalDivide(CPDecimalAdd(axisRange.location, axisRange.end), CPDecimalFromDouble(2.0));
}

#pragma mark -
#pragma mark Accessors

-(Class)gridLineClass
{
	return [CPXYGridLines class];
}

@end
