//
//  3DRotationView.m
//  CPTTestApp
//

#import "RotationView.h"

static const CGFloat kMouseMovementScaleFactorForRotation = 1.0;

@interface RotationView()

@property (nonatomic, readwrite) NSPoint previousLocation;

@end

@implementation RotationView

#pragma mark -
#pragma mark Initialization and teardown

-(instancetype)initWithFrame:(NSRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        rotationTransform = CATransform3DIdentity;
        // Initialization code here.
    }
    return self;
}

#pragma mark -
#pragma mark Mouse handling methods

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    self.previousLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    CGFloat displacementInX = kMouseMovementScaleFactorForRotation * (currentLocation.x - self.previousLocation.x);
    CGFloat displacementInY = kMouseMovementScaleFactorForRotation * (self.previousLocation.y - currentLocation.y);

    CGFloat totalRotation = sqrt(displacementInX * displacementInX + displacementInY * displacementInY);

    CATransform3D oldTransform = self.rotationTransform;
    CATransform3D newTransform = CATransform3DRotate( oldTransform, totalRotation * M_PI / 180.0,
                                                      ( (displacementInX / totalRotation) * oldTransform.m12 + (displacementInY / totalRotation) * oldTransform.m11 ),
                                                      ( (displacementInX / totalRotation) * oldTransform.m22 + (displacementInY / totalRotation) * oldTransform.m21 ),
                                                      ( (displacementInX / totalRotation) * oldTransform.m32 + (displacementInY / totalRotation) * oldTransform.m31 ) );

    id<CPTRotationDelegate> theDelegate = self.rotationDelegate;
    [theDelegate rotateObjectUsingTransform:newTransform];

    self.rotationTransform = newTransform;
    self.previousLocation  = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    self.previousLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

#pragma mark -
#pragma mark Accessors

@synthesize rotationTransform;
@synthesize rotationDelegate;

@synthesize previousLocation;

@end
