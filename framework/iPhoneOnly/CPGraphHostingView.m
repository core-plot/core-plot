
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
    if ( pinchClass ) {
        id pinchRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        self.gestureRecognizers = [NSArray arrayWithObjects:pinchRecognizer, nil];
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

-(void)handlePinchGesture:(id)pinchRecognizer 
{
    [pinchRecognizer setScale:1.0f];
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
