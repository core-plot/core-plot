//
//  DetailViewController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ThemeTableViewController.h"
#import "PlotItem.h"

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, 
                                                    UISplitViewControllerDelegate,
                                                    ThemeTableViewControllerDelegate>
{
    UIPopoverController         *popoverController;
    UIToolbar                   *toolbar;

    PlotItem                    *detailItem;

    UIView                      *hostingView;
    UIBarButtonItem             *themeBarButton;
    UIPopoverController         *themePopoverController;
    ThemeTableViewController    *themeTableViewController;

    NSString                    *currentThemeName;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) PlotItem *detailItem;
@property (nonatomic, retain) IBOutlet UIView *hostingView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *themeBarButton;
@property (nonatomic, retain) IBOutlet ThemeTableViewController *themeTableViewController;
@property (nonatomic, copy) NSString *currentThemeName;

- (IBAction)showThemes:(id)sender;

@end
