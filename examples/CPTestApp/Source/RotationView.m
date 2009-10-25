//
//  3DRotationView.m
//  CPTestApp
//

#import "RotationView.h"

static const CGFloat kMouseMovementScaleFactorForRotation = 1.0f;

@implementation RotationView

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFrame:(NSRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
		rotationTransform = CATransform3DIdentity;
        // Initialization code here.
    }
    return self;
}

#pragma mark -
#pragma mark Mouse handling methods

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	previousLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	CGFloat displacementInX = kMouseMovementScaleFactorForRotation * (currentLocation.x - previousLocation.x);
	CGFloat displacementInY = kMouseMovementScaleFactorForRotation * (previousLocation.y - currentLocation.y);
	
	CGFloat totalRotation = sqrt(displacementInX * displacementInX + displacementInY * displacementInY);
	
	rotationTransform = CATransform3DRotate(rotationTransform, totalRotation * M_PI / 180.0, 
															((displacementInX/totalRotation) * rotationTransform.m12 + (displacementInY/totalRotation) * rotationTransform.m11), 
															((displacementInX/totalRotation) * rotationTransform.m22 + (displacementInY/totalRotation) * rotationTransform.m21), 
															((displacementInX/totalRotation) * rotationTransform.m32 + (displacementInY/totalRotation) * rotationTransform.m31));
	[rotationDelegate rotateObjectUsingTransform:rotationTransform];
	previousLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];

}

- (void)mouseUp:(NSEvent *)theEvent
{
	previousLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

#pragma mark -
#pragma mark Accessors

@synthesize rotationTransform;
@synthesize rotationDelegate;

@end
