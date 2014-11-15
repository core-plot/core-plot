//
//  PlotGalleryAppDelegate-iPhone.m
//  Plot Gallery-iOS
//

#import "PlotGallery.h"
#import "PlotGalleryAppDelegate-iPhone.h"

@implementation PlotGalleryAppDelegate_iPhone

@synthesize window;
@synthesize navigationController;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application
{
}

@end
