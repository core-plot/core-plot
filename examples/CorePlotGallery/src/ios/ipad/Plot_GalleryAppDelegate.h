//
//  Plot_GalleryAppDelegate.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class DetailViewController;

@interface Plot_GalleryAppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, strong) IBOutlet RootViewController *rootViewController;
@property (nonatomic, strong) IBOutlet DetailViewController *detailViewController;

@end
