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

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet RootViewController *rootViewController;

@end
