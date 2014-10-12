//
//  AAPLotAppDelegate.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import "AAPLotAppDelegate.h"
#import "RootViewController.h"

@implementation AAPLotAppDelegate

@synthesize window;
@synthesize rootViewController;

-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    if ( [self.window respondsToSelector:@selector(setRootViewController:)] ) {
        self.window.rootViewController = self.rootViewController;
    }
    else {
        [self.window addSubview:self.rootViewController.view];
    }
    [self.window makeKeyAndVisible];
}

@end
