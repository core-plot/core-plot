//
//  ThemeTableViewController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kThemeTableViewControllerNoTheme;
extern NSString *const kThemeTableViewControllerDefaultTheme;

@protocol ThemeTableViewControllerDelegate<NSObject>

-(void)themeSelectedAtIndex:(NSString *)themeName;

@end

@interface ThemeTableViewController : UITableViewController

@property (nonatomic, strong) UIPopoverController *themePopoverController;
@property (nonatomic, strong) id<ThemeTableViewControllerDelegate> delegate;

@end
