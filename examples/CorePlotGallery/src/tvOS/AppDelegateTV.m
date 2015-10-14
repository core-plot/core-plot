#import "AppDelegateTV.h"

#import "PlotGallery.h"

@implementation AppDelegateTV

@synthesize window;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    return YES;
}

@end
