
#import "CPLayerHostingView.h"
#import "CPLayer.h"

/**	@brief A container view for displaying a CPLayer.
 **/
@implementation CPLayerHostingView

/**	@property hostedLayer
 *	@brief The CPLayer hosted inside this view.
 **/
@synthesize hostedLayer;

+(Class)layerClass
{
	return [CPLayer class];
}

-(id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
		hostedLayer = nil;
		
		// This undoes the normal coordinate space inversion that UIViews apply to their layers
		self.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);
//		self.layer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
		self.backgroundColor = [UIColor clearColor];		
    }
    return self;
}

// On the iPhone, the init method is not called when loading from a XIB
- (void)awakeFromNib
{
	hostedLayer = nil;
	
	// This undoes the normal coordinate space inversion that UIViews apply to their layers
	self.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);
	//		self.layer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
	self.backgroundColor = [UIColor clearColor];		
}

-(void)dealloc {
	[hostedLayer release];
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
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
    [hostedLayer pointingDeviceDownEvent:event atPoint:pointInHostedLayer];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
	[hostedLayer pointingDeviceDraggedEvent:event atPoint:pointInHostedLayer];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
    CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
	[hostedLayer pointingDeviceUpEvent:event atPoint:pointInHostedLayer];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[hostedLayer pointingDeviceCancelledEvent:event];
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
