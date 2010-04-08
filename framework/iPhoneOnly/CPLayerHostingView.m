
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

	NSSet* myTouches = [event touchesForView:self];
	int count = [myTouches count];
    if (count <=1){
		CGPoint pointOfTouch = [[myTouches anyObject] locationInView:self];
		CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
		[hostedLayer pointingDeviceDownEvent:event atPoint:pointInHostedLayer];		
	} else if (count == 2){
		NSArray* tchs = [myTouches allObjects];	
		CGPoint pointOfTouch1 = [[tchs objectAtIndex:0] locationInView:self];
		CGPoint pointInHostedLayer1 = [self.layer convertPoint:pointOfTouch1 toLayer:hostedLayer];	
		
		CGPoint pointOfTouch2 = [[tchs objectAtIndex:1] locationInView:self];
		CGPoint pointInHostedLayer2 = [self.layer convertPoint:pointOfTouch2 toLayer:hostedLayer];	
		
		[hostedLayer pinchBegin:event atPoint1:pointInHostedLayer1 andPoint2:pointInHostedLayer2];
		
	}
	

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	NSSet* myTouches = [event touchesForView:self];
	int count = [myTouches count];
    if (count <=1){
		CGPoint pointOfTouch = [[myTouches anyObject] locationInView:self];
		CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
		[hostedLayer pointingDeviceDraggedEvent:event atPoint:pointInHostedLayer];
	} else if (count == 2){
		NSArray* tchs = [myTouches allObjects];	
		CGPoint pointOfTouch1 = [[tchs objectAtIndex:0] locationInView:self];
		CGPoint pointInHostedLayer1 = [self.layer convertPoint:pointOfTouch1 toLayer:hostedLayer];	
		
		CGPoint pointOfTouch2 = [[tchs objectAtIndex:1] locationInView:self];
		CGPoint pointInHostedLayer2 = [self.layer convertPoint:pointOfTouch2 toLayer:hostedLayer];	
		
		[hostedLayer pinch:event atPoint1:pointInHostedLayer1 andPoint2:pointInHostedLayer2];
		
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSSet* myTouches = [event touchesForView:self];
	int count = [myTouches count];
    if (count <=1){
		CGPoint pointOfTouch = [[myTouches anyObject] locationInView:self];
		CGPoint pointInHostedLayer = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
		[hostedLayer pointingDeviceUpEvent:event atPoint:pointInHostedLayer];
	} else if (count == 2){
		NSArray* tchs = [myTouches allObjects];	
		CGPoint pointOfTouch1 = [[tchs objectAtIndex:0] locationInView:self];
		CGPoint pointInHostedLayer1 = [self.layer convertPoint:pointOfTouch1 toLayer:hostedLayer];	
		
		CGPoint pointOfTouch2 = [[tchs objectAtIndex:1] locationInView:self];
		CGPoint pointInHostedLayer2 = [self.layer convertPoint:pointOfTouch2 toLayer:hostedLayer];	
		
		[hostedLayer pinchEnd:event atPoint1:pointInHostedLayer1 andPoint2:pointInHostedLayer2];
		
	}
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
