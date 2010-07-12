#import "CPPlotSpaceAnnotation.h"
#import "CPPlotSpace.h"
#import "CPPlotAreaFrame.h"
#import "CPPlotArea.h"

/**	@brief Positions a content layer relative to some anchor point in a plot space.
 *	@note Not implemented.
 *	@todo More documentation needed.
 *	@todo Implement CPPlotSpaceAnnotation.
 **/
@implementation CPPlotSpaceAnnotation

@synthesize anchorPlotPoint;
@synthesize plotSpace;

/** @brief Initializes a newly allocated CPPlotSpaceAnnotation object.
 *
 *	This is the designated initializer. The initialized layer will be anchored to
 *	a point in plot coordinates.
 *
 *	@param newPlotSpace The plot space which the anchor is defined in.
 *  @param newPlotPoint An array of NSDecimalNumbers giving the anchor plot coordinates.
 *  @return The initialized CPPlotSpaceAnnotation object.
 **/
-(id)initWithPlotSpace:(CPPlotSpace *)newPlotSpace anchorPlotPoint:(NSArray *)newPlotPoint
{
    if ( self = [super init] ) {
        plotSpace = [newPlotSpace retain];
        anchorPlotPoint = [newPlotPoint copy];
    }
    return self;
}

-(void)dealloc 
{
    [plotSpace release];
    [anchorPlotPoint release];
    [super dealloc];
}

#pragma mark -
#pragma mark Layout

-(void)positionContentLayer
{
	// Get plot area point
	NSDecimal *decimalPoint = malloc(sizeof(NSDecimal) * anchorPlotPoint.count);
    for ( NSUInteger i = 0; i < anchorPlotPoint.count; ++i ) decimalPoint[i] = [[anchorPlotPoint objectAtIndex:i] decimalValue];
	CGPoint plotAreaViewAnchorPoint = [plotSpace plotAreaViewPointForPlotPoint:decimalPoint];
    free(decimalPoint);

	CPPlotArea *plotArea = plotSpace.graph.plotAreaFrame.plotArea;
    CGPoint point = [plotArea convertPoint:plotAreaViewAnchorPoint toLayer:self.annotationHostLayer];
    point.x = round(point.x + self.displacement.x);
    point.y = round(point.y + self.displacement.y);
    self.contentLayer.position = point;
    [self.contentLayer pixelAlign];
}

@end
