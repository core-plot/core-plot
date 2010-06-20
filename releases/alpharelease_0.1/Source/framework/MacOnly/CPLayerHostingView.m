#import "CPLayerHostingView.h"
#import "CPLayer.h"

/**	@brief A container view for displaying a CPLayer.
 **/
@implementation CPLayerHostingView

/**	@property hostedLayer
 *	@brief The CPLayer hosted inside this view.
 **/
@synthesize hostedLayer;

-(id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        hostedLayer = nil;
        CPLayer *mainLayer = [(CPLayer *)[CPLayer alloc] initWithFrame:NSRectToCGRect(frame)];
        self.layer = mainLayer;
        [mainLayer release];
    }
    return self;
}

-(void)dealloc
{
	[hostedLayer removeFromSuperlayer];
	[hostedLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Mouse handling

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
	CGPoint pointOfMouseDown = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfMouseDown toLayer:hostedLayer];
    [hostedLayer pointingDeviceDownEvent:theEvent atPoint:pointInHostedLayer];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint pointOfMouseDrag = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfMouseDrag toLayer:hostedLayer];
	[hostedLayer pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedLayer];
}

-(void)mouseUp:(NSEvent *)theEvent
{
	CGPoint pointOfMouseUp = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfMouseUp toLayer:hostedLayer];
	[hostedLayer pointingDeviceUpEvent:theEvent atPoint:pointInHostedLayer];
}

#pragma mark -
#pragma mark Accessors

-(void)setHostedLayer:(CPLayer *)newLayer
{
	if (newLayer != hostedLayer) {
        self.wantsLayer = YES;
		[hostedLayer removeFromSuperlayer];
		[hostedLayer release];
		hostedLayer = [newLayer retain];
		if (hostedLayer) {
			[self.layer addSublayer:hostedLayer];
		}
    }
}

@end
