//
//  ThemeTableViewController.h
//  CorePlotGallery
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
