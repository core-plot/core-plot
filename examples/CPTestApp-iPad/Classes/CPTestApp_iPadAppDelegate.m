//
//  CPTestApp_iPadAppDelegate.m
//  CPTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import "CPTestApp_iPadAppDelegate.h"
#import "CPTestApp_iPadViewController.h"

@implementation CPTestApp_iPadAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
