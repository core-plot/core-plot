//
//  CPTTestApp_iPhoneAppDelegate.m
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.

#import "CPTTestApp_iPhoneAppDelegate.h"

@implementation CPTTestApp_iPhoneAppDelegate

@synthesize window;
@synthesize tabBarController;

-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    if ( [self.window respondsToSelector:@selector(setRootViewController:)] ) {
        self.window.rootViewController = self.tabBarController;
    }
    else {
        [self.window addSubview:self.tabBarController.view];
    }
    [self.window makeKeyAndVisible];
}

/*
 * // Optional UITabBarControllerDelegate method
 * - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 * }
 */

/*
 * // Optional UITabBarControllerDelegate method
 * - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 * }
 */

@end
