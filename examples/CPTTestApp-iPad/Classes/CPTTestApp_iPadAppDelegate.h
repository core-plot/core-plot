//
//  CPTTestApp_iPadAppDelegate.h
//  CPTTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import <UIKit/UIKit.h>

@class CPTTestApp_iPadViewController;

@interface CPTTestApp_iPadAppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic, readwrite, strong) IBOutlet UIWindow *window;
@property (nonatomic, readwrite, strong) IBOutlet CPTTestApp_iPadViewController *viewController;

@end
