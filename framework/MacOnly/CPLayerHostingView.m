#import "CPLayerHostingView.h"
#import "CPLayer.h"

@implementation CPLayerHostingView

@synthesize hostedLayer;

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		hostedLayer = nil;
		layerBeingClickedOn = nil;
		CPLayer *mainLayer = [[CPLayer alloc] initWithFrame:NSRectToCGRect(frame)];
		self.layer = mainLayer;
		[mainLayer release];
		[self setWantsLayer:YES];
    }
    return self;
}

- (void)dealloc
{
	[hostedLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Mouse handling

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
	return YES;
}

-(void)mouseDown:(NSEvent *)theEvent;
{
	CGPoint pointOfMouseDown = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
	CALayer *hitLayer = [self.layer hitTest:pointOfMouseDown];

	if ( (hitLayer != nil) && [hitLayer isKindOfClass:[CPLayer class]]) {
		layerBeingClickedOn = (CPLayer *)hitLayer;
		[(CPLayer *)hitLayer mouseOrFingerDownAtPoint:pointOfMouseDown];
	}
}

-(void)mouseDragged:(NSEvent *)theEvent;
{
	if (layerBeingClickedOn == nil){
		return;
	}
	
	CGPoint pointOfMouseDrag = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);

	[layerBeingClickedOn mouseOrFingerUpAtPoint:pointOfMouseDrag];
	layerBeingClickedOn = nil;	
}

-(void)mouseUp:(NSEvent *)theEvent;
{
	if (layerBeingClickedOn == nil) {
		return;		
	}
	
	CGPoint pointOfMouseUp = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);

	[layerBeingClickedOn mouseOrFingerUpAtPoint:pointOfMouseUp];
	layerBeingClickedOn = nil;	
}

#pragma mark -
#pragma mark Accessors

-(void)setHostedLayer:(CPLayer *)newLayer
{
	if (newLayer == hostedLayer) {
		return;
	}
	
	[hostedLayer removeFromSuperlayer];
	[hostedLayer release];
	hostedLayer = [newLayer retain];
	[self.layer addSublayer:hostedLayer];
}

@end
