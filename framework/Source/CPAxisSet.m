
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"
#import "CPPlotArea.h"
#import "CPGraph.h"

@implementation CPAxisSet

@synthesize axes;
@synthesize overlayLayer;
@synthesize graph;
@synthesize overlayLayerInsetX, overlayLayerInsetY;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.axes = [NSArray array];
        self.needsDisplayOnBoundsChange = YES;
		self.layerAutoresizingMask = kCPLayerNotSizable;
		self.overlayLayerInsetX = 0.0f;
		self.overlayLayerInsetY = 0.0f;
	}
	return self;
}

-(void)dealloc {
	graph = nil;
	[overlayLayer release];
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setGraph:(CPGraph *)newGraph
{
	if ( graph != newGraph ) {
		graph = newGraph;
		[self setNeedsLayout];
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
        [self setNeedsLayout];
    }
}

-(void)setOverlayLayer:(CPLayer *)newLayer 
{		
	if ( newLayer != overlayLayer ) {
		[overlayLayer removeFromSuperlayer];
		[overlayLayer release];
		overlayLayer = [newLayer retain];
		overlayLayer.layerAutoresizingMask = kCPLayerNotSizable;
		overlayLayer.zPosition = CPDefaultZPositionAxisSetOverlay;
		[self addSublayer:newLayer];
		[self positionInGraph];
	}
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxisSet;
}

-(void)positionInGraph
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
        for ( CPAxis *axis in axes ) {
			axis.bounds = self.bounds;
			axis.anchorPoint = CGPointZero;
			axis.position = self.bounds.origin;
			[axis setNeedsDisplay];
            [axis setNeedsLayout];
        }
		
		// Overlay
		overlayLayer.bounds = CGRectInset(self.graph.plotArea.bounds, self.overlayLayerInsetX, self.overlayLayerInsetY);
		overlayLayer.anchorPoint = CGPointZero;
		overlayLayer.position = CGPointMake(self.overlayLayerInsetX, self.overlayLayerInsetY);
    }
}

@end
