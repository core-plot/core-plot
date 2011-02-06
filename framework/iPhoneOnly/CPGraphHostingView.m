
#import "CPGraphHostingView.h"
#import "CPGraph.h"

/**	@brief A container view for displaying a CPGraph.
 **/
@implementation CPGraphHostingView

/**	@property hostedGraph
 *	@brief The CPLayer hosted inside this view.
 **/
@synthesize hostedGraph;

/**	@property collapsesLayers
 *	@brief Whether view draws all graph layers into a single layer.
 *  Collapsing layers may improve performance in some cases.
 **/
@synthesize collapsesLayers;

+(Class)layerClass
{
	return [CALayer class];
}

-(void)commonInit
{
    hostedGraph = nil;
    collapsesLayers = NO;
    
    self.backgroundColor = [UIColor clearColor];	
    
    // This undoes the normal coordinate space inversion that UIViews apply to their layers
    self.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);	
    
    // Register for pinches
    Class pinchClass = NSClassFromString(@"UIPinchGestureRecognizer");
    if ( pinchClass )
    {
      id pinchRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
      [self addGestureRecognizer:pinchRecognizer];
      [pinchRecognizer release];
    }
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		[self commonInit];
    }
    return self;
}

// On the iPhone, the init method is not called when loading from a XIB
-(void)awakeFromNib
{
    [self commonInit];
}

-(void)dealloc {
	[hostedGraph release];
    [super dealloc];
}

#pragma mark -
#pragma mark Touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Ignore pinch or other multitouch gestures
	if ([[event allTouches] count] > 1) {
		return;		
	}
	
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceDownEvent:event atPoint:pointOfTouch];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceDraggedEvent:event atPoint:pointOfTouch];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedGraph];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedGraph pointingDeviceUpEvent:event atPoint:pointOfTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[hostedGraph pointingDeviceCancelledEvent:event];
}

#pragma mark -
#pragma mark Gestures

-(void) handlePinchGesture:(id)pinchGestureRecognizer
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
  CGPoint interactionPoint = [pinchGestureRecognizer locationInView:self];


	if (!collapsesLayers)
		interactionPoint = [self.layer convertPoint:interactionPoint toLayer:hostedGraph];
	else
		interactionPoint.y = self.frame.size.height-interactionPoint.y;
 // reset only scale if pinch gesture has been processed: a receiver might have refused to handle the
 // pinch gesture because of a too small scale difference compared with 1.0; if the scale is reset
 // the receiver will very likely never have the chance to interfere but by letting the scale increase
 // in case of unhandled gestures the scale value might become larger than the receiver's interaction
 // threshold value
  if ([hostedGraph recognizer:pinchGestureRecognizer atPoint:interactionPoint withScale:[(UIPinchGestureRecognizer*)pinchGestureRecognizer scale]])
    [pinchGestureRecognizer setScale:1.0f];
#endif
}

#pragma mark -
#pragma mark Drawing

-(void)drawRect:(CGRect)rect
{
    if ( !collapsesLayers ) return;
    
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

#pragma mark -
#pragma mark Accessors

-(void)updateNotifications
{
    if ( collapsesLayers ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if ( hostedGraph ) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphNeedsRedraw:) name:CPGraphNeedsRedrawNotification object:hostedGraph];
        }
    }
}

-(void)setHostedGraph:(CPGraph *)newLayer
{
	if (newLayer == hostedGraph) return;
    
	[hostedGraph removeFromSuperlayer];
	[hostedGraph release];
	hostedGraph = [newLayer retain];
	if ( !collapsesLayers ) {
    	hostedGraph.frame = self.layer.bounds;
        [self.layer addSublayer:hostedGraph];
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
        if ( !collapsesLayers ) 
        	[self.layer addSublayer:hostedGraph];
        else {
            [hostedGraph removeFromSuperlayer];
            [self setNeedsDisplay];
        }
        [self updateNotifications];
    }
}

-(void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    if ( !collapsesLayers ) 
    	hostedGraph.frame = self.bounds;
    else 
    	[self setNeedsDisplay];
}

-(void)setBounds:(CGRect)newBounds
{
    [super setBounds:newBounds];
    if ( collapsesLayers ) [self setNeedsDisplay];
}

@end
