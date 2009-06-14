
#import "CPXYAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPAxisLabel.h"

@interface CPXYAxis ()

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 

@end


@implementation CPXYAxis

@synthesize constantCoordinateValue;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
        self.constantCoordinateValue = [NSDecimalNumber zero];
		self.needsDisplayOnBoundsChange = YES;
		self.tickDirection = CPSignNone;
	}
	return self;
}

-(void)dealloc 
{
    self.constantCoordinateValue = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimalNumber
{
    CPCoordinate orthogonalCoordinate = (self.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    
    NSMutableArray *plotPoint = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
    [plotPoint replaceObjectAtIndex:self.coordinate withObject:coordinateDecimalNumber];
    [plotPoint replaceObjectAtIndex:orthogonalCoordinate withObject:self.constantCoordinateValue];
    
    CGPoint point = [self.plotSpace viewPointForPlotPoint:plotPoint];
    
    [plotPoint release];
	
    return point;
}

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major
{
	[(major ? self.majorTickLineStyle : self.minorTickLineStyle) setLineStyleInContext:theContext];

    for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
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
        
        // Stroke line
        CGContextBeginPath(theContext);
        CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
        CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
        CGContextStrokePath(theContext);
    }    
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext {
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength isMajor:YES];
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength isMajor:NO];

    // Axis Line
	if ( self.drawsAxisLine ) {
		CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
		CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
		CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
		[self.axisLineStyle setLineStyleInContext:theContext];
		CGContextBeginPath(theContext);
		CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
		CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
		CGContextStrokePath(theContext);
	}
}

-(NSString *)description
{
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
	return [NSString stringWithFormat:@"CPXYAxis from (%@, %@) viewCoordinates: (%f, %f)-(%f, %f)", range.location, range.end, startViewPoint.x, startViewPoint.y, endViewPoint.x, endViewPoint.y];
};

@end
