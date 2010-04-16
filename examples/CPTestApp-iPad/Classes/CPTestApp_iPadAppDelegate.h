//
//  CPTestApp_iPadAppDelegate.h
//  CPTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import <UIKit/UIKit.h>

@class CPTestApp_iPadViewController;

@interface CPTestApp_iPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CPTestApp_iPadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CPTestApp_iPadViewController *viewController;

@end

