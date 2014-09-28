//
//  DetailViewController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import "PlotItem.h"
#import "ThemeTableViewController.h"
#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UIPopoverControllerDelegate,
                                                   UISplitViewControllerDelegate,
                                                   ThemeTableViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, strong) IBOutlet UIView *hostingView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeBarButton;
@property (nonatomic, strong) IBOutlet ThemeTableViewController *themeTableViewController;
@property (nonatomic, copy) NSString *currentThemeName;

-(IBAction)showThemes:(id)sender;

@end
