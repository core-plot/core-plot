//
//  CPTTestApp_iPhoneAppDelegate.h
//  CPTTestApp-iPhone
//
//  Toolbar icons in the application are courtesy of Joseph Wain / glyphish.com
//  See the license file in the GlyphishIcons directory for more information on these icons

#import <UIKit/UIKit.h>

@interface CPTTestApp_iPhoneAppDelegate : NSObject<UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, readwrite, strong) IBOutlet UIWindow *window;
@property (nonatomic, readwrite, strong) IBOutlet UITabBarController *tabBarController;

@end
