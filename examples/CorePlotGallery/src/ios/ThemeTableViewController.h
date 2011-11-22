//
//  ThemeTableViewController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kThemeTableViewControllerNoTheme	  @"None"
#define kThemeTableViewControllerDefaultTheme @"Default"

@protocol ThemeTableViewControllerDelegate<NSObject>

-(void)themeSelectedAtIndex:(NSString *)themeName;

@end

@interface ThemeTableViewController : UITableViewController
{
	UIPopoverController *themePopoverController;
	id<ThemeTableViewControllerDelegate> delegate;
	NSMutableArray *themes;
}

@property (nonatomic, retain) UIPopoverController *themePopoverController;
@property (nonatomic, retain) id<ThemeTableViewControllerDelegate> delegate;

@end
