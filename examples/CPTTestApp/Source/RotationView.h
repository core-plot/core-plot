//
//  RotationView.h
//  CPTTestApp
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@protocol CPTRotationDelegate;

@interface RotationView : NSView

@property (nonatomic, readwrite) CATransform3D rotationTransform;
@property (nonatomic, readwrite, weak) id<CPTRotationDelegate> rotationDelegate;

@end

@protocol CPTRotationDelegate<NSObject>
-(void)rotateObjectUsingTransform:(CATransform3D)rotationTransform;
@end
