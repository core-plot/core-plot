#import "UIViewController+LegacyRotation.h"

@implementation UIViewController(LegacyRotation)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

-(NSUInteger)supportedInterfaceOrientations
{
    NSUInteger ret = 0;

    if ( [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait] ) {
        ret |= UIInterfaceOrientationMaskPortrait;
    }
    if ( [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown] ) {
        ret |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if ( [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft] ) {
        ret |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    if ( [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight] ) {
        ret |= UIInterfaceOrientationMaskLandscapeRight;
    }

    return ret;
}

#pragma clang diagnostic pop

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
