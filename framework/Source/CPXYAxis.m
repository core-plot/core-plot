
#import "CPXYAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPTextLayer.h"

@interface CPXYAxis ()

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimal;
-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 
-(void)drawLabelsInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withOffset:(CGFloat)offset;

@end


@implementation CPXYAxis

@synthesize constantCoordinateValue;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if (self = [super init]) {
        self.constantCoordinateValue = CPDecimalFromInt(0);
	}
	return self;
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

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major
{
	[(major ? self.majorTickLineStyle : self.minorTickLineStyle) setLineStyleInContext:theContext];

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

-(void)drawLabelsInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withOffset:(CGFloat)offset
{
	// TODO: reposition existing labels instead of creating new CPTextLayers each time
	for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
        CGPoint terminalViewPoint = baseViewPoint;
		
		NSString *tickLabel = [NSString stringWithFormat:@"%@", [self.tickLabelFormatter stringForObjectValue:tickLocation]];
		CPTextLayer *labelLayer = [[CPTextLayer alloc] initWithString:tickLabel fontSize:10.f];

        if ( self.coordinate == CPCoordinateX ) { 
            terminalViewPoint.y -= offset;
			labelLayer.anchorPoint = CGPointMake(0.5f, 1.0f);
        } else {
            terminalViewPoint.x -= offset;
			labelLayer.anchorPoint = CGPointMake(1.0f, 0.5f);
		}
		labelLayer.position = terminalViewPoint;
		[self.plotSpace addSublayer:labelLayer];
		
		[labelLayer release];
	}
}

-(void)drawInContext:(CGContextRef)theContext 
{
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength isMajor:YES];
    [self drawLabelsInContext:theContext atLocations:self.majorTickLocations withOffset:self.tickLabelOffset];
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength isMajor:NO];

    // Axis Line
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
    [self.axisLineStyle setLineStyleInContext:theContext];
    CGContextBeginPath(theContext);
	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	CGContextStrokePath(theContext);
}

@end
