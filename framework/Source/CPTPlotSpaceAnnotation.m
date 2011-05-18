#import "CPTPlotSpaceAnnotation.h"
#import "CPTPlotSpace.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotArea.h"

/**	@brief Positions a content layer relative to some anchor point in a plot space.
 *	@todo More documentation needed.
 **/
@implementation CPTPlotSpaceAnnotation

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

/** @brief Initializes a newly allocated CPTPlotSpaceAnnotation object.
 *
 *	This is the designated initializer. The initialized layer will be anchored to
 *	a point in plot coordinates.
 *
 *	@param newPlotSpace The plot space which the anchor is defined in.
 *  @param newPlotPoint An array of NSDecimalNumbers giving the anchor plot coordinates.
 *  @return The initialized CPTPlotSpaceAnnotation object.
 **/
-(id)initWithPlotSpace:(CPTPlotSpace *)newPlotSpace anchorPlotPoint:(NSArray *)newPlotPoint
{
    if ( (self = [super init]) ) {
        plotSpace = [newPlotSpace retain];
        anchorPlotPoint = [newPlotPoint copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionContentLayer) name:CPTPlotSpaceCoordinateMappingDidChangeNotification object:plotSpace];
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
	CPTLayer *content = self.contentLayer;
	if ( content ) {
		CPTLayer *hostLayer = self.annotationHostLayer;
		if ( hostLayer ) {
			NSArray *plotAnchor = self.anchorPlotPoint;
			if ( plotAnchor ) {
				NSUInteger anchorCount = plotAnchor.count;
				CGFloat myRotation = self.rotation;
				CGPoint anchor = self.contentAnchorPoint;
				
				// Get plot area point
				NSDecimal *decimalPoint = malloc(sizeof(NSDecimal) * anchorCount);
				for ( NSUInteger i = 0; i < anchorCount; i++ ) {
					decimalPoint[i] = [[plotAnchor objectAtIndex:i] decimalValue];
				}
				CPTPlotSpace *thePlotSpace = self.plotSpace;
				CGPoint plotAreaViewAnchorPoint = [thePlotSpace plotAreaViewPointForPlotPoint:decimalPoint];
				free(decimalPoint);
				
				CPTPlotArea *plotArea = thePlotSpace.graph.plotAreaFrame.plotArea;
				CGPoint newPosition = [plotArea convertPoint:plotAreaViewAnchorPoint toLayer:hostLayer];
				CGPoint offset = self.displacement;
				newPosition.x = round(newPosition.x + offset.x);
				newPosition.y = round(newPosition.y + offset.y);
				
				// Pixel-align the label layer to prevent blurriness
				if ( myRotation == 0.0 ) {
					CGSize currentSize = content.bounds.size;
					
					newPosition.x = newPosition.x - round(currentSize.width * anchor.x) + (currentSize.width * anchor.x);
					newPosition.y = newPosition.y - round(currentSize.height * anchor.y) + (currentSize.height * anchor.y);
				}
				content.anchorPoint = anchor;
				content.position = newPosition;
				content.transform = CATransform3DMakeRotation(myRotation, 0.0, 0.0, 1.0);
				[content setNeedsDisplay];
			}
		}
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
