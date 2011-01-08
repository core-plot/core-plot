//
//  PlotGalleryAppDelegate-iPhone.m
//  Plot Gallery-iOS
//
//  Created by Jeff Buck on 10/17/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGalleryAppDelegate-iPhone.h"
#import "PlotGallery.h"

@implementation PlotGalleryAppDelegate_iPhone

@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
