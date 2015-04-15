//
//  CPTTestApp_iPadAppDelegate.m
//  CPTTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import "CPTTestApp_iPadAppDelegate.h"
#import "CPTTestApp_iPadViewController.h"

@implementation CPTTestApp_iPadAppDelegate

@synthesize window;
@synthesize viewController;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
