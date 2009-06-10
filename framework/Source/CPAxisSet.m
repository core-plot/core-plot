
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"
#import "CPPlotArea.h"
#import "CPGraph.h"

@implementation CPAxisSet

@synthesize axes;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.axes = [NSArray array];
        self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc {
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

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
/*
-(void)positionInGraph:(CPGraph *)graph 
{    
    if ( graph.plotArea ) {
        // Set the bounds so that the axis set coordinates coincide with the 
        // plot area drawing coordinates.
        CGRect axisSetBounds = graph.bounds;
        axisSetBounds.origin = [graph convertPoint:graph.bounds.origin toLayer:graph.plotArea];
        self.bounds = axisSetBounds;
        self.anchorPoint = CGPointZero;
        self.position = graph.bounds.origin;
        
        // Set axes
        for ( CPAxis *axis in self.axes ) {
			axis.bounds = self.bounds;
			axis.anchorPoint = CGPointZero;
			axis.position = self.bounds.origin;
			[axis setNeedsDisplay];
        }
    }
}
*/
@end
