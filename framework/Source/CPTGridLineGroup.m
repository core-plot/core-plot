#import "CPTAxis.h"
#import "CPTAxisSet.h"
#import "CPTGridLineGroup.h"
#import "CPTGridLines.h"
#import "CPTPlotArea.h"

/**	@brief A group of grid line layers.
 *
 *	When using separate axis layers, this layer serves as the common superlayer for the grid line layers.
 *	Otherwise, this layer handles the drawing for the grid lines. It supports mixing the two modes;
 *	some axes can use separate grid line layers while others are handled by the grid line group.
 **/
@implementation CPTGridLineGroup

/**	@property plotArea
 *  @brief The plot area that this grid line group belongs to.
 **/
@synthesize plotArea;

/**	@property major
 *	@brief If YES, draw the major grid lines, else draw the minor grid lines.
 **/
@synthesize major;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		plotArea = nil;
		major = NO;

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPTGridLineGroup *theLayer = (CPTGridLineGroup *)layer;
		
		plotArea = theLayer->plotArea;
		major = theLayer->major;
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	for ( CPTAxis *axis in self.plotArea.axisSet.axes ) {
		if ( !axis.separateLayers ) {
			[axis drawGridLinesInContext:theContext isMajor:self.major];
		}
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setPlotArea:(CPTPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		plotArea = newPlotArea;
		
		if ( plotArea ) {
			[self setNeedsDisplay];
		}
	}	
}

@end
