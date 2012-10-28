#import "UITabBarController+LegacyRotation.h"

@implementation UITabBarController(LegacyRotation)

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

@end
