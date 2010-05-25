
#import "CPLayerHostingView.h"
#import "CPLayer.h"

@implementation CPLayerHostingView

@synthesize hostedLayer;

+(Class)layerClass
{
	return [CPLayer class];
}

-(id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
		hostedLayer = nil;
		layerBeingTouched = nil;
		
		// This undoes the normal coordinate space inversion that UIViews apply to their layers
		self.layer.sublayerTransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
//		self.layer.transform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
		self.backgroundColor = [UIColor clearColor];		
    }
    return self;
}

// On the iPhone, the init method is not called when loading from a XIB
- (void)awakeFromNib
{
	hostedLayer = nil;
	layerBeingTouched = nil;
	
	// This undoes the normal coordinate space inversion that UIViews apply to their layers
	self.layer.sublayerTransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
	//		self.layer.transform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
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
	CALayer *hitLayer = [self.layer hitTest:pointOfTouch];
	
	if ( (hitLayer != nil) && [hitLayer isKindOfClass:[CPLayer class]]) {
		layerBeingTouched = (CPLayer *)hitLayer;
		[(CPLayer *)hitLayer mouseOrFingerDownAtPoint:pointOfTouch];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if (layerBeingTouched == nil) {
		return;
	}
	
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	
	[layerBeingTouched mouseOrFingerDraggedAtPoint:pointOfTouch];
	layerBeingTouched = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (layerBeingTouched == nil) {
		return;		
	}
	
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];

	[layerBeingTouched mouseOrFingerUpAtPoint:pointOfTouch];
	layerBeingTouched = nil;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	// Ignore pinch or other multitouch gestures
	if (layerBeingTouched == nil) {
		return;		
	}
	
	[layerBeingTouched mouseOrFingerCancelled];
	layerBeingTouched = nil;
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
