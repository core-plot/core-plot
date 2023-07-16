//
// RotationView.h
// CPTTestApp
//

@import Cocoa;
@import QuartzCore;

@protocol CPTRotationDelegate;

@interface RotationView : NSView

@property (nonatomic, readwrite) CATransform3D rotationTransform;
@property (nonatomic, readwrite, weak, nullable) id<CPTRotationDelegate> rotationDelegate;

@end

@protocol CPTRotationDelegate<NSObject>
-(void)rotateObjectUsingTransform:(CATransform3D)rotationTransform;

@end
