#import "UINavigationController+LegacyRotation.h"

@implementation UINavigationController(LegacyRotation)

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

@end
