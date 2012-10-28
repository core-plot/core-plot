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
    if ( [self.window respondsToSelector:@selector(setRootViewController:)] ) {
        self.window.rootViewController = self.viewController;
    }
    else {
        [self.window addSubview:self.viewController.view];
    }
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

@end
