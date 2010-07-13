#import "CPPlotSpaceAnnotation.h"
#import "CPPlotSpace.h"
#import "CPPlotAreaFrame.h"
#import "CPPlotArea.h"

/**	@brief Positions a content layer relative to some anchor point in a plot space.
 *	@todo More documentation needed.
 **/
@implementation CPPlotSpaceAnnotation

/** @property anchorPlotPoint
 *	@brief An array of NSDecimalNumbers giving the anchor plot coordinates.
 **/
@synthesize anchorPlotPoint;

/** @property plotSpace
 *	@brief The plot space which the anchor is defined in.
 **/
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionContentLayer) name:CPPlotSpaceCoordinateMappingDidChangeNotification object:plotSpace];
    }
    return self;
}

-(void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [plotSpace release]; plotSpace = nil;
    [anchorPlotPoint release]; anchorPlotPoint = nil;
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
