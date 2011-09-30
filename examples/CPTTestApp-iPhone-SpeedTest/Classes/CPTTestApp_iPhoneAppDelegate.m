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
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

-(void)dealloc
{
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end
