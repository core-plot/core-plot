#import "AppDelegateTV.h"

#import "PlotGallery.h"

@implementation AppDelegateTV

@synthesize window;

-(BOOL)application:(UIApplication *__unused)application didFinishLaunchingWithOptions:(NSDictionary *__unused)launchOptions
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    return YES;
}

@end
