#import "CPLayerHostingView.h"
#import "CPLayer.h"

///	@cond
@interface CPLayerHostingView()

@property (nonatomic, readwrite, assign) CPLayer *layerBeingClickedOn;

@end
///	@endcond

/**	@brief A container view for displaying a CPLayer.
 **/
@implementation CPLayerHostingView

/**	@property hostedLayer
 *	@brief The CPLayer hosted inside this view.
 **/
@synthesize hostedLayer;
@synthesize layerBeingClickedOn;

-(id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        hostedLayer = nil;
        layerBeingClickedOn = nil;
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
	layerBeingClickedOn = nil;
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
	CALayer *hitLayer = [self.layer hitTest:pointOfMouseDown];
	
	if ( (hitLayer != nil) && [hitLayer isKindOfClass:[CPLayer class]]) {
		self.layerBeingClickedOn = (CPLayer *)hitLayer;
		[(CPLayer *)hitLayer mouseOrFingerDownAtPoint:pointOfMouseDown];
	}
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	if (self.layerBeingClickedOn == nil) {
		return;
	}
	
	CGPoint pointOfMouseDrag = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
	
	[self.layerBeingClickedOn mouseOrFingerUpAtPoint:pointOfMouseDrag];
	self.layerBeingClickedOn = nil;	
}

-(void)mouseUp:(NSEvent *)theEvent
{
	if (self.layerBeingClickedOn == nil) {
		return;		
	}
	
	CGPoint pointOfMouseUp = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
	
	[self.layerBeingClickedOn mouseOrFingerUpAtPoint:pointOfMouseUp];
	self.layerBeingClickedOn = nil;	
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
