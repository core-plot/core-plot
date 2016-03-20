//
// DetailViewController.h
// CorePlotGallery
//

@class PlotItem;

@interface DetailViewController : UIViewController

@property (nonatomic, strong, nonnull) PlotItem *detailItem;
@property (nonatomic, copy, nonnull) NSString *currentThemeName;

@property (nonatomic, strong, nullable) IBOutlet UIView *hostingView;
@property (nonatomic, strong, nullable) IBOutlet UIBarButtonItem *themeBarButton;

-(void)themeSelectedWithName:(nonnull NSString *)themeName;

@end
