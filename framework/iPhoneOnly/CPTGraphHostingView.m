#import "CPTGraphHostingView.h"

#import "CPTGraph.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"
#import "NSNumberExtensions.h"

///	@cond
@interface CPTGraphHostingView()

@property (nonatomic, readwrite, assign) __weak id pinchGestureRecognizer;

-(void)updateNotifications;
-(void)graphNeedsRedraw:(NSNotification *)notification;

@end

///	@endcond

#pragma mark -

/**
 *	@brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/**	@property hostedGraph
 *	@brief The CPTLayer hosted inside this view.
 **/
@synthesize hostedGraph;

/**	@property collapsesLayers
 *	@brief Whether view draws all graph layers into a single layer.
 *  Collapsing layers may improve performance in some cases.
 **/
@synthesize collapsesLayers;

/**	@property allowPinchScaling
 *	@brief Whether a pinch will trigger plot space scaling.
 *  Default is YES. This causes gesture recognizers to be added to identify pinches.
 **/
@synthesize allowPinchScaling;

///	@cond

/**	@internal
 *	@property pinchGestureRecognizer
 *	@brief The pinch gesture recognizer for this view.
 **/
@synthesize pinchGestureRecognizer;

///	@endcond

#pragma mark -
#pragma mark init/dealloc

///	@cond

+(Class)layerClass
{
	return [CALayer class];
}

-(void)commonInit
{
	hostedGraph		= nil;
	collapsesLayers = NO;

	self.backgroundColor = [UIColor clearColor];

	self.allowPinchScaling = YES;

	// This undoes the normal coordinate space inversion that UIViews apply to their layers
	self.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);
}

-(id)initWithFrame:(CGRect)frame
{
	if ( (self = [super initWithFrame:frame]) ) {
		[self commonInit];
	}
	return self;
}

///	@endcond

// On iOS, the init method is not called when loading from a XIB
-(void)awakeFromNib
{
	[self commonInit];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[hostedGraph release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeBool:self.collapsesLayers forKey:@"CPTGraphHostingView.collapsesLayers"];
	[coder encodeObject:self.hostedGraph forKey:@"CPTGraphHostingView.hostedGraph"];
	[coder encodeBool:self.allowPinchScaling forKey:@"CPTGraphHostingView.allowPinchScaling"];

	// No need to archive these properties:
	// pinchGestureRecognizer
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		collapsesLayers	 = [coder decodeBoolForKey:@"CPTGraphHostingView.collapsesLayers"];
		hostedGraph		 = nil;
		self.hostedGraph = [coder decodeObjectForKey:@"CPTGraphHostingView.hostedGraph"]; // setup layers

		allowPinchScaling	   = NO;
		pinchGestureRecognizer = nil;

		self.allowPinchScaling = [coder decodeBoolForKey:@"CPTGraphHostingView.allowPinchScaling"]; // set gesture recognizer if needed
	}
	return self;
}

#pragma mark -
#pragma mark Touch handling

///	@cond

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Ignore pinch or other multitouch gestures
	if ( [[event allTouches] count] > 1 ) {
		return;
	}

	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if ( !collapsesLayers ) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	}
	else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceDownEvent:event atPoint:pointOfTouch];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if ( !collapsesLayers ) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	}
	else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceDraggedEvent:event atPoint:pointOfTouch];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];

	if ( !collapsesLayers ) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	}
	else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceUpEvent:event atPoint:pointOfTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[hostedGraph pointingDeviceCancelledEvent:event];
}

///	@endcond

#pragma mark -
#pragma mark Gestures

///	@cond

-(void)setAllowPinchScaling:(BOOL)yn
{
	if ( allowPinchScaling != yn ) {
		allowPinchScaling = yn;
		if ( allowPinchScaling ) {
			// Register for pinches
			Class pinchClass = NSClassFromString(@"UIPinchGestureRecognizer");
			if ( pinchClass ) {
				pinchGestureRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
				[self addGestureRecognizer:pinchGestureRecognizer];
				[pinchGestureRecognizer release];
			}
		}
		else {
			if ( pinchGestureRecognizer ) {
				[self removeGestureRecognizer:pinchGestureRecognizer];
			}
			pinchGestureRecognizer = nil;
		}
	}
}

-(void)handlePinchGesture:(id)aPinchGestureRecognizer
{
	CGPoint interactionPoint = [aPinchGestureRecognizer locationInView:self];

	if ( !collapsesLayers ) {
		interactionPoint = [self.layer convertPoint:interactionPoint toLayer:hostedGraph];
	}
	else {
		interactionPoint.y = self.frame.size.height - interactionPoint.y;
	}

	CGPoint pointInPlotArea = [hostedGraph convertPoint:interactionPoint toLayer:hostedGraph.plotAreaFrame.plotArea];

	for ( CPTPlotSpace *space in hostedGraph.allPlotSpaces ) {
		if ( space.allowsUserInteraction ) {
			[space scaleBy:[[pinchGestureRecognizer valueForKey:@"scale"] cgFloatValue] aboutPoint:pointInPlotArea];
		}
	}

	[pinchGestureRecognizer setScale:1.0f];
}

///	@endcond

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)drawRect:(CGRect)rect
{
	if ( !collapsesLayers ) {
		return;
	}

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1, -1);
	hostedGraph.frame = self.bounds;
	[hostedGraph layoutAndRenderInContext:context];
}

-(void)graphNeedsRedraw:(NSNotification *)notification
{
	[self setNeedsDisplay];
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)updateNotifications
{
	if ( collapsesLayers ) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		if ( hostedGraph ) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphNeedsRedraw:) name:CPTGraphNeedsRedrawNotification object:hostedGraph];
		}
	}
}

-(void)setHostedGraph:(CPTGraph *)newLayer
{
	if ( newLayer == hostedGraph ) {
		return;
	}

	[hostedGraph removeFromSuperlayer];
	[hostedGraph release];
	hostedGraph = [newLayer retain];

	// Screen scaling
	UIScreen *screen = [UIScreen mainScreen];
	// scale property is available in iOS 4.0 and later
	if ( [screen respondsToSelector:@selector(scale)] ) {
		hostedGraph.contentsScale = screen.scale;
	}
	else {
		hostedGraph.contentsScale = 1.0;
	}

	if ( !collapsesLayers ) {
		if ( hostedGraph ) {
			hostedGraph.frame = self.layer.bounds;
			[self.layer addSublayer:hostedGraph];
		}
	}
	else {
		[self setNeedsDisplay];
	}

	[self updateNotifications];
}

-(void)setCollapsesLayers:(BOOL)yn
{
	if ( yn != collapsesLayers ) {
		collapsesLayers = yn;
		if ( collapsesLayers ) {
			[hostedGraph removeFromSuperlayer];
			[self setNeedsDisplay];
		}
		else {
			if ( hostedGraph ) {
				[self.layer addSublayer:hostedGraph];
			}
		}
		[self updateNotifications];
	}
}

-(void)setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];

	[hostedGraph setNeedsLayout];

	if ( collapsesLayers ) {
		[self setNeedsDisplay];
	}
	else {
		hostedGraph.frame = self.bounds;
	}
}

-(void)setBounds:(CGRect)newBounds
{
	[super setBounds:newBounds];

	[hostedGraph setNeedsLayout];

	if ( collapsesLayers ) {
		[self setNeedsDisplay];
	}
	else {
		hostedGraph.frame = newBounds;
	}
}

///	@endcond

@end
