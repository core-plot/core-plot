
#import "CPLinearAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPLinearAxis ()

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimal;

@end


@implementation CPLinearAxis

@synthesize coordinate;
@synthesize constantCoordinateValue;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if (self = [super init]) {
        self.coordinate = CPCoordinateX;
        self.constantCoordinateValue = CPDecimalFromInt(0);
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimalNumber
{
    CPCoordinate orthogonalCoordinate = (self.coordinate == CPCoordinateX ? CPCoordinateY : CPCoordinateX);
    NSDecimalNumber *constCoordNumber = [[NSDecimalNumber alloc] initWithDecimal:self.constantCoordinateValue];
    
    NSMutableArray *plotPoint = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], nil];
    [plotPoint replaceObjectAtIndex:self.coordinate withObject:coordinateDecimalNumber];
    [plotPoint replaceObjectAtIndex:orthogonalCoordinate withObject:constCoordNumber];
    
    CGPoint point = [self.plotSpace viewPointForPlotPoint:plotPoint];
    
    [constCoordNumber release];
    
    return point;
}

-(void)drawInContext:(CGContextRef)theContext {

    // Ticks
    for ( NSDecimalNumber *tickLocation in self.majorTickLocations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
        CGPoint terminalViewPoint = baseViewPoint;
        if ( self.coordinate == CPCoordinateX ) 
            terminalViewPoint.y -= self.majorTickLength;
        else
            terminalViewPoint.x -= self.majorTickLength;

        // Stroke line
        CGContextMoveToPoint(theContext, baseViewPoint.x, baseViewPoint.y);
        CGContextBeginPath(theContext);
        CGContextAddLineToPoint(theContext, terminalViewPoint.x, terminalViewPoint.y);
        CGContextStrokePath(theContext);
    }

    // Axis Line
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.end];
	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
    CGContextBeginPath(theContext);
	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	CGContextStrokePath(theContext);
}

@end
