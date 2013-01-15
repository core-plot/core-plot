//
//  RotationView.h
//  CPTTestApp
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@protocol CPTRotationDelegate;

@interface RotationView : NSView {
    id<CPTRotationDelegate> __unsafe_unretained rotationDelegate;

    CATransform3D rotationTransform;

    NSPoint previousLocation;
}

@property (readwrite, nonatomic) CATransform3D rotationTransform;
@property (readwrite, unsafe_unretained, nonatomic) id<CPTRotationDelegate> rotationDelegate;

@end

@protocol CPTRotationDelegate<NSObject>
-(void)rotateObjectUsingTransform:(CATransform3D)rotationTransform;
@end
