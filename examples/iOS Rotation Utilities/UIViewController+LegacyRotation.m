#import "UIViewController+LegacyRotation.h"

@implementation UIViewController(LegacyRotation)

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

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
