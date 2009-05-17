//
//  RotationView.h
//  CPTestApp
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@protocol CPRotationDelegate;

@interface RotationView : NSView {
	id<CPRotationDelegate> rotationDelegate;
	
	CATransform3D rotationTransform;
	
	NSPoint previousLocation;
}

@property(readwrite, nonatomic) CATransform3D rotationTransform;
@property(readwrite, assign, nonatomic) id<CPRotationDelegate> rotationDelegate;

@end

@protocol CPRotationDelegate <NSObject>
- (void)rotateObjectUsingTransform:(CATransform3D)rotationTransform;
@end
