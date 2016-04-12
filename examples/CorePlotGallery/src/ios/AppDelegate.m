//
// AppDelegate.m
// CorePlotGallery
//

#import "AppDelegate.h"

#import "DetailViewController.h"
#import "PlotGallery.h"

@interface AppDelegate()<UISplitViewControllerDelegate>

@end

#pragma mark -

@implementation AppDelegate

@synthesize window;

-(BOOL)application:(nonnull UIApplication *)application didFinishLaunchingWithOptions:(nullable CPTDictionary *)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    splitViewController.delegate = self;

    UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;

    return YES;
}

#pragma mark - Split view

-(BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ( [secondaryViewController isKindOfClass:[UINavigationController class]] && [( (UINavigationController *)secondaryViewController ).topViewController isKindOfClass:[DetailViewController class]] && ( ( (DetailViewController *)( (UINavigationController *)secondaryViewController ).topViewController ).detailItem == nil ) ) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    }
    else {
        return NO;
    }
}

@end
