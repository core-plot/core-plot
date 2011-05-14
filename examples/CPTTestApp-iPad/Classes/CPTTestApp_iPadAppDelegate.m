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
