//
//  Plot_GalleryAppDelegate.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "Plot_GalleryAppDelegate.h"

#import "DetailViewController.h"
#import "RootViewController.h"

#import "PlotGallery.h"
#import "PlotItem.h"

@implementation Plot_GalleryAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

#pragma mark -
#pragma mark Application lifecycle

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    if ( [self.window respondsToSelector:@selector(setRootViewController:)] ) {
        self.window.rootViewController = self.splitViewController;
    }
    else {
        [self.window addSubview:self.splitViewController.view];
    }
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark -
#pragma mark Memory management

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"AppDelegate:applicationDidReceiveMemoryWarning");
}

-(void)dealloc
{
    [splitViewController release];
    [window release];
    [super dealloc];
}

@end
