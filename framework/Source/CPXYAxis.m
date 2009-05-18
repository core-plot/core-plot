
#import "CPXYAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPXYAxis ()

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimal;
-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSArray *)locations withLength:(CGFloat)length; 

@end


@implementation CPXYAxis

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
    [plotPoint release];
	
    return point;
}

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSArray *)locations withLength:(CGFloat)length 
{
    for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
        CGPoint terminalViewPoint = baseViewPoint;
        if ( self.coordinate == CPCoordinateX ) 
            terminalViewPoint.y -= length;
        else
            terminalViewPoint.x -= length;
        
        // Stroke line
        CGContextBeginPath(theContext);
        CGContextMoveToPoint(theContext, baseViewPoint.x, baseViewPoint.y);
        CGContextAddLineToPoint(theContext, terminalViewPoint.x, terminalViewPoint.y);
        CGContextStrokePath(theContext);
    }    
}

-(void)drawInContext:(CGContextRef)theContext 
{
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength];
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength];

    // Axis Line
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.end];
    CGContextBeginPath(theContext);
	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	CGContextStrokePath(theContext);
}

@end
