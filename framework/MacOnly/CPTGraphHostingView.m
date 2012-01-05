#import "CPTGraphHostingView.h"

#import "CPTGraph.h"

///	@cond
// for MacOS 10.6 SDK compatibility
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
@interface NSWindow(CPTExtensions)

@property (readonly) CGFloat backingScaleFactor;

@end
#endif
#endif

///	@endcond

/**
 *	@brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/**	@property hostedGraph
 *	@brief The CPTGraph hosted inside this view.
 **/
@synthesize hostedGraph;

///	@cond

-(id)initWithFrame:(NSRect)frame
{
	if ( (self = [super initWithFrame:frame]) ) {
		hostedGraph = nil;
		CPTLayer *mainLayer = [(CPTLayer *)[CPTLayer alloc] initWithFrame:NSRectToCGRect(frame)];
		self.layer = mainLayer;
		[mainLayer release];
	}
	return self;
}

///	@endcond

-(void)dealloc
{
	[hostedGraph removeFromSuperlayer];
	[hostedGraph release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.hostedGraph forKey:@"CPTLayerHostingView.hostedGraph"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		CPTLayer *mainLayer = [(CPTLayer *)[CPTLayer alloc] initWithFrame:NSRectToCGRect(self.frame)];
		self.layer = mainLayer;
		[mainLayer release];

		hostedGraph		 = nil;
		self.hostedGraph = [coder decodeObjectForKey:@"CPTLayerHostingView.hostedGraph"]; // setup layers
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)drawRect:(NSRect)dirtyRect
{
	if ( self.hostedGraph ) {
		NSWindow *myWindow = self.window;
		// backingScaleFactor property is available in MacOS 10.7 and later
		if ( [myWindow respondsToSelector:@selector(backingScaleFactor)] ) {
			self.layer.contentsScale = myWindow.backingScaleFactor;
		}
		else {
			self.layer.contentsScale = 1.0;
		}
	}
}

///	@endcond

#pragma mark -
#pragma mark Mouse handling

///	@cond

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
	CPTGraph *theGraph = self.hostedGraph;

	if ( theGraph ) {
		CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
		CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
		[theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
	}
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	CPTGraph *theGraph = self.hostedGraph;

	if ( theGraph ) {
		CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
		CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
		[theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
	}
}

-(void)mouseUp:(NSEvent *)theEvent
{
	CPTGraph *theGraph = self.hostedGraph;

	if ( theGraph ) {
		CGPoint pointOfMouseUp	   = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
		CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
		[theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
	}
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setHostedGraph:(CPTGraph *)newGraph
{
	if ( newGraph != hostedGraph ) {
		self.wantsLayer = YES;
		[hostedGraph removeFromSuperlayer];
		[hostedGraph release];
		hostedGraph = [newGraph retain];
		if ( hostedGraph ) {
			CPTLayer *myLayer = (CPTLayer *)self.layer;

			NSWindow *myWindow = self.window;
			// backingScaleFactor property is available in MacOS 10.7 and later
			if ( [myWindow respondsToSelector:@selector(backingScaleFactor)] ) {
				myLayer.contentsScale = myWindow.backingScaleFactor;
			}
			else {
				myLayer.contentsScale = 1.0;
			}

			[myLayer addSublayer:hostedGraph];
		}
	}
}

///	@endcond

@end
