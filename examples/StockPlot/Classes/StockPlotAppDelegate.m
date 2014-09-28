//
//  StockPlotAppDelegate.m
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "StockPlotAppDelegate.h"

@implementation StockPlotAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    [[self.navigationController navigationBar] setTintColor:[UIColor blackColor]];

    if ( [self.window respondsToSelector:@selector(setRootViewController:)] ) {
        self.window.rootViewController = self.navigationController;
    }
    else {
        [self.window addSubview:self.navigationController.view];
    }
    [self.window makeKeyAndVisible];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    // Save data if appropriate
}

#pragma mark -
#pragma mark Memory management

@end
