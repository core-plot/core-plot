
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"
#import "CPPlotArea.h"
#import "CPGraph.h"

/**	@brief A container layer for the set of axes for a graph.
 **/
@implementation CPAxisSet

/**	@property axes
 *	@brief The axes in the axis set.
 **/
@synthesize axes;

/**	@property graph
 *	@brief The graph for the axis set.
 **/
@synthesize graph;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		axes = [[NSArray array] retain];
        self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Labeling

/**	@brief Updates the axis labels for each axis in the axis set.
 **/
-(void)relabelAxes
{
    for ( CPAxis *axis in self.axes ) {
        [axis setNeedsLayout];
        [axis setNeedsRelabel];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setGraph:(CPGraph *)newGraph
{
	if ( graph != newGraph ) {
		graph = newGraph;
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

-(void)setAxes:(NSArray *)newAxes 
{
    if ( newAxes != axes ) {
        for ( CPAxis *axis in axes ) {
            [axis removeFromSuperlayer];
        }
        [axes release];
        axes = [newAxes retain];
        for ( CPAxis *axis in axes ) {
            [self addSublayer:axis];
        }
		[self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxisSet;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	// nothing to draw
}

@end
