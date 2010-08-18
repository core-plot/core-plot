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

#pragma mark -
#pragma mark Init/Dealloc

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
    [plotSpace release];
    [anchorPlotPoint release];
    [super dealloc];
}

#pragma mark -
#pragma mark Layout

-(void)positionContentLayer
{
	CPLayer *content = self.contentLayer;
	if ( content ) {
		NSArray *anchor = self.anchorPlotPoint;
		NSUInteger anchorCount = anchor.count;
		
		// Get plot area point
		NSDecimal *decimalPoint = malloc(sizeof(NSDecimal) * anchorCount);
		for ( NSUInteger i = 0; i < anchorCount; i++ ) {
			decimalPoint[i] = [[anchor objectAtIndex:i] decimalValue];
		}
		CPPlotSpace *thePlotSpace = self.plotSpace;
		CGPoint plotAreaViewAnchorPoint = [thePlotSpace plotAreaViewPointForPlotPoint:decimalPoint];
		free(decimalPoint);
		
		CPPlotArea *plotArea = thePlotSpace.graph.plotAreaFrame.plotArea;
		CGPoint point = [plotArea convertPoint:plotAreaViewAnchorPoint toLayer:self.annotationHostLayer];
		CGPoint offset = self.displacement;
		point.x = round(point.x + offset.x);
		point.y = round(point.y + offset.y);
		
		content.position = point;
		[content pixelAlign];
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setAnchorPlotPoint:(NSArray *)newPlotPoint
{
	if ( anchorPlotPoint != newPlotPoint ) {
		[anchorPlotPoint release];
		anchorPlotPoint = [newPlotPoint copy];
		[self positionContentLayer];
	}
}

@end
