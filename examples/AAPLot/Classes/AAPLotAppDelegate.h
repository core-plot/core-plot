//
// AAPLotAppDelegate.h
// AAPLot
//
// Created by Jonathan Saggau on 6/9/09.
// Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AAPLotAppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic, strong, nullable) IBOutlet UIWindow *window;
@property (nonatomic, strong, nullable) IBOutlet RootViewController *rootViewController;

@end
