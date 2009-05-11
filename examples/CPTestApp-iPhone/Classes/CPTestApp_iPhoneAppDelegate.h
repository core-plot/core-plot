//
//  CPTestApp_iPhoneAppDelegate.h
//  CPTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.

#import <UIKit/UIKit.h>

@interface CPTestApp_iPhoneAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
