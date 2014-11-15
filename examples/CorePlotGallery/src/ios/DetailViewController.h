//
//  DetailViewController.h
//  CorePlotGallery
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
