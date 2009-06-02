
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"
#import "CPPlotArea.h"
#import "CPGraph.h"

@implementation CPAxisSet

@synthesize axes;
@synthesize graph;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.axes = [NSArray array];
        self.needsDisplayOnBoundsChange = YES;
		self.layerAutoresizingMask = kCPLayerNotSizable;
	}
	return self;
}

-(void)dealloc {
    graph = nil;
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
			[axis setNeedsDisplay];
            [axis setNeedsLayout];
        }
        [self setNeedsLayout];
    }
}

-(void)setGraph:(CPGraph *)newGraph 
{
    if ( newGraph != graph ) {
        graph = newGraph;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers 
{
    // Use custom resizing, because the axis set coordinates must correspond to plot area's drawing coordinates
    if ( self.graph.plotArea ) {
        CGRect axisSetBounds = self.graph.bounds;
        axisSetBounds.origin = [self convertPoint:self.graph.bounds.origin toLayer:self.graph.plotArea];
        self.bounds = axisSetBounds;
        self.anchorPoint = CGPointZero;
        self.position = self.graph.bounds.origin;
        
        // Set axes
        for ( CPAxis *axis in axes ) {
			axis.bounds = self.bounds;
			axis.anchorPoint = CGPointZero;
			axis.position = self.bounds.origin;
			[axis setNeedsDisplay];
            [axis setNeedsLayout];
        }
    }
}

@end
