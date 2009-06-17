
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
		self.overlayLayer = nil;
        self.needsDisplayOnBoundsChange = YES;
		self.overlayLayerInsetX = 0.0f;
		self.overlayLayerInsetY = 0.0f;
	}
	return self;
}

-(void)dealloc {
	[overlayLayer release];
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Labeling

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

-(void)setOverlayLayer:(CPLayer *)newLayer 
{		
	if ( newLayer != overlayLayer ) {
		[overlayLayer removeFromSuperlayer];
		[overlayLayer release];
		overlayLayer = [newLayer retain];
		if (overlayLayer) {
			overlayLayer.zPosition = CPDefaultZPositionAxisSetOverlay;
			[self addSublayer:overlayLayer];
		}
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Layout

-(void)setBounds:(CGRect)newBounds 
{
    if ( !CGRectEqualToRect(newBounds, self.bounds) ) {
        [super setBounds:newBounds];
        [self relabelAxes];
    }
}

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxisSet;
}

-(void)layoutSublayers 
{
	CGRect selfBounds = self.bounds;
	
	for ( CPAxis *axis in self.axes ) {
		axis.bounds = selfBounds;
		axis.anchorPoint = CGPointZero;
		axis.position = selfBounds.origin;
	}
	
	// Overlay
	self.overlayLayer.bounds = CGRectInset(self.graph.plotArea.bounds, self.overlayLayerInsetX, self.overlayLayerInsetY);
	self.overlayLayer.anchorPoint = CGPointZero;
	self.overlayLayer.position = CGPointMake(self.overlayLayerInsetX, self.overlayLayerInsetY);
}

@end
